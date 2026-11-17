import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/booking_quote.dart';
import 'package:sprint/features/booking/domain/booking_repository.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/settings/domain/booking_mode.dart';
import 'package:sprint/features/settings/domain/setting_definition.dart';
import 'package:sprint/features/settings/domain/setting_registry.dart';

import '../../../helpers/data_env.dart';

/// `BookingRepository.quote` (research R6): every check `create` runs, and no
/// write. Seed days are relative to the env's "now", a Saturday at 8:00.
void main() {
  late DataEnv env;

  setUp(() => env = DataEnv());

  BookingRequest req(
    String? userId,
    String unitId,
    DateTime start, {
    DateTime? end,
    String? trainerId,
  }) => BookingRequest(
    userId: userId,
    unitId: unitId,
    start: start,
    end: end ?? start.add(const Duration(hours: 1)),
    trainerId: trainerId,
  );

  Future<Failure> refusal(BookingRequest r) async =>
      (await env.layer.bookings.quote(r) as Err<BookingQuote>).failure;
  Future<BookingQuote> quoted(BookingRequest r) async =>
      (await env.layer.bookings.quote(r) as Ok<BookingQuote>).value;

  group('refusals, in the order of the contract', () {
    test('a guest is not permitted', () async {
      expect(
        await refusal(req(null, Ids.futsal2, env.at(2, 18))),
        isA<NotPermitted>(),
      );
    });

    test('an unknown unit is not found', () async {
      expect(
        await refusal(req(Ids.bookerInternal, 'nope', env.at(2, 18))),
        isA<NotFound>(),
      );
    });

    test('a trainer facility needs its trainer', () async {
      expect(
        await refusal(req(Ids.bookerInternal, Ids.room2, env.at(2, 9))),
        isA<NotFound>(),
      );
    });

    test('outside the booking window (BR-06)', () async {
      expect(
        await refusal(req(Ids.bookerInternal, Ids.futsal2, env.at(30, 18))),
        isA<OutsideWindow>(),
      );
    });

    test('a past slot (BR-07)', () async {
      expect(
        await refusal(req(Ids.bookerInternal, Ids.futsal2, env.at(0, 7))),
        isA<SlotPast>(),
      );
    });

    test('a closed hour (BR-05)', () async {
      expect(
        await refusal(
          req(Ids.bookerInternal, Ids.hall2, env.at(2, 6), end: env.at(2, 8)),
        ),
        isA<ClosedSlot>(),
      );
    });

    test(
      'a range longer than the maximum states the maximum (BR-08)',
      () async {
        final f = await refusal(
          req(Ids.bookerInternal, Ids.hall2, env.at(2, 10), end: env.at(2, 14)),
        );
        expect(f, isA<RangeTooLong>());
        expect((f as RangeTooLong).maxHours, 3);
      },
    );

    test(
      'two slots in a paid facility are refused without a range maximum',
      () async {
        final f = await refusal(
          req(
            Ids.bookerInternal,
            Ids.futsal2,
            env.at(2, 18),
            end: env.at(2, 20),
          ),
        );
        expect(f, isA<RangeTooLong>());
        expect(
          (f as RangeTooLong).maxHours,
          isNull,
          reason: 'the limit there is one slot, not maxRangeHours',
        );
      },
    );

    test(
      'an overlap with the booker\'s own booking names it (BR-13)',
      () async {
        // The internal booker holds lane 1 on day +3 at 18:00.
        final f = await refusal(
          req(Ids.bookerInternal, Ids.futsal2, env.at(3, 18)),
        );
        expect(f, isA<OverlapsOwnBooking>());
        final id = (f as OverlapsOwnBooking).bookingId;
        final mine = await env.layer.bookings.listForUser(Ids.bookerInternal);
        expect(mine.map((b) => b.id), contains(id));
      },
    );

    test('the active-bookings cap states the cap (BR-14)', () async {
      await env.layer.settings.set(
        SettingKeys.maxActiveBookingsPerUser,
        1,
        const SettingScope.university(),
        actorId: Ids.superAdmin,
      );
      final f = await refusal(
        req(Ids.bookerInternal, Ids.futsal2, env.at(2, 18)),
      );
      expect(f, isA<TooManyActiveBookings>());
      expect((f as TooManyActiveBookings).max, 1);
    });

    test(
      'an exclusive slot under a live hold is taken (BR-02, BR-12)',
      () async {
        // Tennis court 1, day +3 at 17:00, is held by another user.
        final f = await refusal(
          req(Ids.bookerExternal, Ids.tennis1, env.at(3, 17)),
        );
        expect(f, isA<SlotTaken>());
        expect(
          (f as SlotTaken).at,
          isNull,
          reason: 'a single slot is refused plainly',
        );
      },
    );

    test('a shared slot with no places is full (BR-03)', () async {
      // Lane 2 (capacity 3), day +3 at 10:00, has three bookings.
      final f = await refusal(
        req(Ids.userUnverified, Ids.pool2, env.at(3, 10)),
      );
      expect(f, isA<SlotFull>());
    });
  });

  group('a quote', () {
    test('matches what create then stores', () async {
      final r = req(Ids.bookerInternal, Ids.futsal2, env.at(2, 18));
      final q = await quoted(r);
      expect(q.tier, PriceTier.internal);
      expect(q.amount, 140);
      expect(q.requiresPayment, isTrue);
      expect(q.mode, BookingMode.exclusive);
      expect(q.maxParticipants, 22);
      expect(q.cancellationCutoffHours, 2);
      expect(q.refundPercent, 100);
      expect((q.facilityId, q.unitId), (Ids.futsalFacility, Ids.futsal2));

      final b = (await env.layer.bookings.create(r) as Ok<Booking>).value;
      expect((b.tierAtBooking, b.priceAtBooking), (q.tier, q.amount));
    });

    test(
      'carries the facility-level cutoff and the unit-level refund',
      () async {
        final pool = await quoted(
          req(Ids.bookerExternal, Ids.pool5, env.at(2, 9)),
        );
        expect(pool.cancellationCutoffHours, 4);
        expect(pool.mode, BookingMode.shared);
        expect(pool.amount, 40);
        final gym = await quoted(
          req(Ids.bookerExternal, Ids.gym1, env.at(2, 9)),
        );
        expect(gym.refundPercent, 50);
      },
    );

    test('a free facility quotes zero and needs no payment (BR-19)', () async {
      final q = await quoted(
        req(Ids.bookerExternal, Ids.hall2, env.at(2, 10), end: env.at(2, 12)),
      );
      expect(q.amount, 0);
      expect(q.requiresPayment, isFalse);
    });

    test('writes nothing and signals nothing', () async {
      final before = env.layer.bookings.allBookings.length;
      var events = 0;
      final sub = env.layer.bookings.changes.listen((_) => events++);
      await quoted(req(Ids.bookerInternal, Ids.futsal2, env.at(2, 18)));
      await refusal(req(Ids.bookerInternal, Ids.futsal2, env.at(30, 18)));
      await Future<void>.delayed(Duration.zero);
      expect(env.layer.bookings.allBookings, hasLength(before));
      expect(events, 0);
      await sub.cancel();
    });

    test('is stable when nothing changed', () async {
      final r = req(Ids.bookerInternal, Ids.futsal2, env.at(2, 18));
      expect(await quoted(r), await quoted(r));
    });
  });

  test('changes fires after a successful create', () async {
    var events = 0;
    final sub = env.layer.bookings.changes.listen((_) => events++);
    await env.layer.bookings.create(
      req(Ids.bookerExternal, Ids.hall2, env.at(2, 10), end: env.at(2, 12)),
    );
    await Future<void>.delayed(Duration.zero);
    expect(events, 1);
    await sub.cancel();
  });

  group('offers are off until the offers feature (decisions 2026-11-17)', () {
    // The pool has 20% off for the internal tier on Thursdays, 14:00-18:00.
    // The env's "now" is a Saturday, so Thursday is day +5.
    test('quote and create ignore the seeded offer by default', () async {
      final r = req(Ids.bookerInternal, Ids.pool5, env.at(5, 15));
      expect((await quoted(r)).amount, 20);
      final b = (await env.layer.bookings.create(r) as Ok<Booking>).value;
      expect(b.priceAtBooking, 20);
    });

    test('with applyOffers on, both use the discounted price', () async {
      env = DataEnv(null, true);
      final r = req(Ids.bookerInternal, Ids.pool5, env.at(5, 15));
      expect((await quoted(r)).amount, 16);
      final b = (await env.layer.bookings.create(r) as Ok<Booking>).value;
      expect(b.priceAtBooking, 16);
    });
  });
}
