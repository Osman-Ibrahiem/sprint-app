import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/features/attendance/domain/attendance.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/booking_repository.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/identity/domain/verification.dart';
import 'package:sprint/features/settings/domain/booking_mode.dart';
import 'package:sprint/features/settings/domain/setting_definition.dart';
import 'package:sprint/features/settings/domain/setting_registry.dart';

import '../../helpers/data_env.dart';

void main() {
  late DataEnv env;

  setUp(() => env = DataEnv());

  BookingRequest req(
    String? userId,
    String unitId,
    DateTime start, {
    DateTime? end,
    int seats = 1,
    String? trainerId,
  }) =>
      BookingRequest(
        userId: userId,
        unitId: unitId,
        start: start,
        end: end ?? start.add(const Duration(hours: 1)),
        seats: seats,
        trainerId: trainerId,
      );

  Booking ok(Result<Booking> r) => (r as Ok<Booking>).value;
  Failure fail(Result<Booking> r) => (r as Err<Booking>).failure;

  group('creation', () {
    test('a guest cannot book', () async {
      final r = await env.layer.bookings
          .create(req(null, Ids.futsal2, env.at(2, 18)));
      expect(fail(r), isA<NotPermitted>());
    });

    test('a paid booking starts as PENDING_PAYMENT with a hold (BR-12)',
        () async {
      final b = ok(await env.layer.bookings
          .create(req(Ids.bookerInternal, Ids.futsal2, env.at(2, 18))));
      expect(b.status, BookingStatus.pendingPayment);
      expect(b.holdExpiresAt, env.now.add(const Duration(minutes: 10)));
      expect(b.tierAtBooking, PriceTier.internal);
      expect(b.priceAtBooking, 140);
      expect(b.code, isNotEmpty);
      expect(b.qrToken, isNot(b.code)); // never the raw booking code
      expect(await env.layer.payments.payments(b.id), isEmpty);
    });

    test('an external user pays the full price', () async {
      final b = ok(await env.layer.bookings
          .create(req(Ids.bookerExternal, Ids.futsal2, env.at(2, 18))));
      expect((b.tierAtBooking, b.priceAtBooking), (PriceTier.external, 300));
    });

    test('an expired verification books at the external price (BR-25)',
        () async {
      final b = ok(await env.layer.bookings
          .create(req(Ids.userExpired, Ids.futsal2, env.at(2, 18))));
      expect(b.tierAtBooking, PriceTier.external);
    });

    test('a free facility confirms immediately, with no payment (BR-19)',
        () async {
      final b = ok(await env.layer.bookings.create(req(
        Ids.bookerExternal,
        Ids.hall2,
        env.at(2, 10),
        end: env.at(2, 12),
      )));
      expect(b.status, BookingStatus.confirmed);
      expect(b.priceAtBooking, 0);
      expect(b.holdExpiresAt, isNull);
      expect(await env.layer.payments.payments(b.id), isEmpty);
    });

    test('a closed hour, a past slot and a far-future slot are refused',
        () async {
      // Hall hours are 8:00-22:00.
      expect(
        fail(await env.layer.bookings.create(req(
          Ids.bookerInternal,
          Ids.hall2,
          env.at(2, 6),
          end: env.at(2, 8),
        ))),
        isA<ClosedSlot>(),
      );
      expect(
        fail(await env.layer.bookings
            .create(req(Ids.bookerInternal, Ids.futsal2, env.at(0, 7)))),
        isA<SlotPast>(),
      );
      expect(
        fail(await env.layer.bookings
            .create(req(Ids.bookerInternal, Ids.futsal2, env.at(30, 18)))),
        isA<OutsideWindow>(),
      );
    });

    test('an unknown unit is NotFound', () async {
      expect(
        fail(await env.layer.bookings
            .create(req(Ids.bookerInternal, 'nope', env.at(2, 18)))),
        isA<NotFound>(),
      );
    });
  });

  group('atomic creation (BR-11)', () {
    test('two concurrent creates for the same exclusive slot: one wins',
        () async {
      final slot = env.at(2, 19);
      final results = await Future.wait([
        env.layer.bookings.create(req(Ids.bookerInternal, Ids.futsal2, slot)),
        env.layer.bookings.create(req(Ids.bookerExternal, Ids.futsal2, slot)),
      ]);
      expect(results.whereType<Ok<Booking>>(), hasLength(1));
      final loser = results.whereType<Err<Booking>>().single;
      expect(loser.failure, isA<SlotTaken>());
    });

    test('two concurrent creates for the last shared place: one wins',
        () async {
      await env.layer.settings.set(
        SettingKeys.capacity,
        2,
        const SettingScope.unit(Ids.pool6),
        actorId: Ids.superAdmin,
      );
      final slot = env.at(2, 9);
      ok(await env.layer.bookings.create(req(Ids.bookerInternal, Ids.pool6, slot)));
      final results = await Future.wait([
        env.layer.bookings.create(req(Ids.bookerExternal, Ids.pool6, slot)),
        env.layer.bookings.create(req(Ids.userExpired, Ids.pool6, slot)),
        env.layer.bookings.create(req(Ids.userUnverified, Ids.pool6, slot)),
      ]);
      expect(results.whereType<Ok<Booking>>(), hasLength(1));
      expect(
        results.whereType<Err<Booking>>().map((e) => e.failure),
        everyElement(isA<SlotFull>()),
      );
    });

    test('the same user cannot hold two overlapping slots (BR-13)', () async {
      ok(await env.layer.bookings
          .create(req(Ids.bookerInternal, Ids.futsal2, env.at(2, 18))));
      final r = await env.layer.bookings
          .create(req(Ids.bookerInternal, Ids.tennis2, env.at(2, 18)));
      expect(fail(r), isA<OverlapsOwnBooking>());
    });
  });

  group('payment and confirmation (BR-28)', () {
    test('a paid booking confirms only from a provider status', () async {
      final b = ok(await env.layer.bookings
          .create(req(Ids.bookerInternal, Ids.futsal2, env.at(2, 18))));
      expect(
        ok(await env.layer.bookings.get(b.id)).status,
        BookingStatus.pendingPayment,
        reason: 'creating alone never confirms',
      );

      final paid = ok(await env.layer.bookings.pay(b.id));
      expect(paid.status, BookingStatus.confirmed);
      expect(paid.holdExpiresAt, isNull);

      final payments = await env.layer.payments.payments(b.id);
      expect(payments, hasLength(1));
      expect(payments.single.amount, 140);
      expect(payments.single.owningUnitId, Ids.ouCentral); // BR-33
    });

    test('a failed payment expires the booking and frees the slot', () async {
      final slot = env.at(2, 20);
      final b = ok(await env.layer.bookings
          .create(req(Ids.bookerInternal, Ids.futsal2, slot)));
      env.layer.paymentProvider.failNext = true;
      final r = ok(await env.layer.bookings.pay(b.id));
      expect(r.status, BookingStatus.expired);

      final again = await env.layer.bookings
          .create(req(Ids.bookerExternal, Ids.futsal2, slot));
      expect(again, isA<Ok<Booking>>());
    });

    test('paying a booking that is not pending is refused', () async {
      final b = ok(await env.layer.bookings.create(req(
        Ids.bookerInternal,
        Ids.hall2,
        env.at(2, 10),
        end: env.at(2, 11),
      )));
      expect(fail(await env.layer.bookings.pay(b.id)), isA<InvalidTransition>());
    });

    test('an elapsed hold expires the booking (expireHolds)', () async {
      final slot = env.at(2, 21);
      final b = ok(await env.layer.bookings
          .create(req(Ids.bookerInternal, Ids.futsal2, slot)));
      env.advance(const Duration(minutes: 11));
      // The seed also has a live hold, which has elapsed by now too.
      expect(await env.layer.bookings.expireHolds(), greaterThanOrEqualTo(1));
      expect(ok(await env.layer.bookings.get(b.id)).status, BookingStatus.expired);
      // And paying afterwards is refused.
      expect(fail(await env.layer.bookings.pay(b.id)), isA<InvalidTransition>());
    });

    test('a hold that is still live is kept', () async {
      final b = ok(await env.layer.bookings
          .create(req(Ids.bookerInternal, Ids.futsal2, env.at(2, 21))));
      env.advance(const Duration(minutes: 9));
      await env.layer.bookings.expireHolds();
      expect(ok(await env.layer.bookings.get(b.id)).status,
          BookingStatus.pendingPayment);
    });
  });

  group('frozen price and tier (BR-17)', () {
    test('later price and verification changes do not touch a booking',
        () async {
      final b = ok(await env.layer.bookings
          .create(req(Ids.bookerInternal, Ids.futsal2, env.at(2, 18))));
      await env.layer.catalogue.upsertPrice(
        const Price(unitId: Ids.futsal2, tier: PriceTier.internal, amount: 999),
      );
      await env.layer.identity.putVerification(
        Verification(
          userId: Ids.bookerInternal,
          type: VerificationType.student,
          status: VerificationStatus.rejected,
          method: VerificationMethod.manual,
          reason: 'x',
        ),
      );
      final after = ok(await env.layer.bookings.get(b.id));
      expect((after.tierAtBooking, after.priceAtBooking),
          (PriceTier.internal, 140));
    });
  });

  group('cancellation and refund (BR-30 – BR-32)', () {
    Future<Booking> paidBooking(String user, String unit, DateTime slot) async {
      final b = ok(await env.layer.bookings.create(req(user, unit, slot)));
      return ok(await env.layer.bookings.pay(b.id));
    }

    test('before the cutoff the owner is refunded refundPercent', () async {
      final b = await paidBooking(Ids.bookerInternal, Ids.futsal2, env.at(2, 18));
      final r = ok(await env.layer.bookings.cancel(b.id, Ids.bookerInternal));
      expect(r.status, BookingStatus.cancelled);
      expect(r.cancelledBy, CancelledBy.owner);

      final payment = (await env.layer.payments.payments(b.id)).single;
      final refunds = await env.layer.payments.refunds(payment.id);
      expect(refunds.single.amount, 140);
    });

    test('a lower refundPercent setting refunds less', () async {
      await env.layer.settings.set(
        SettingKeys.refundPercent,
        50,
        const SettingScope.unit(Ids.futsal2),
        actorId: Ids.superAdmin,
      );
      final b = await paidBooking(Ids.bookerInternal, Ids.futsal2, env.at(2, 18));
      ok(await env.layer.bookings.cancel(b.id, Ids.bookerInternal));
      final payment = (await env.layer.payments.payments(b.id)).single;
      expect((await env.layer.payments.refunds(payment.id)).single.amount, 70);
    });

    test('inherited cutoff: the pool facility uses 4 hours', () async {
      // Seed: cutoff 4 h at facility level for the pool.
      final slot = env.at(1, 18);
      final b = await paidBooking(Ids.bookerInternal, Ids.pool6, slot);
      env.setNow(slot.subtract(const Duration(hours: 3)));
      expect(
        fail(await env.layer.bookings.cancel(b.id, Ids.bookerInternal)),
        isA<CancellationClosed>(),
      );
      env.setNow(slot.subtract(const Duration(hours: 5)));
      expect(
        await env.layer.bookings.cancel(b.id, Ids.bookerInternal),
        isA<Ok<Booking>>(),
      );
    });

    test('someone else cannot cancel your booking', () async {
      final b = await paidBooking(Ids.bookerInternal, Ids.futsal2, env.at(2, 18));
      expect(
        fail(await env.layer.bookings.cancel(b.id, Ids.bookerExternal)),
        isA<NotPermitted>(),
      );
    });

    test('an admin cancel refunds 100% and notifies the owner (BR-32, BR-41)',
        () async {
      await env.layer.settings.set(
        SettingKeys.refundPercent,
        0,
        const SettingScope.unit(Ids.futsal2),
        actorId: Ids.superAdmin,
      );
      final slot = env.at(2, 18);
      final b = await paidBooking(Ids.bookerInternal, Ids.futsal2, slot);
      env.setNow(slot.subtract(const Duration(minutes: 20)));
      final r = ok(await env.layer.bookings
          .cancel(b.id, Ids.superAdmin, reason: 'إغلاق طارئ'));
      expect(r.cancelledBy, CancelledBy.admin);
      expect(r.cancelReason, 'إغلاق طارئ');

      final payment = (await env.layer.payments.payments(b.id)).single;
      expect((await env.layer.payments.refunds(payment.id)).single.amount, 140);

      final notes = await env.layer.notifications.list(Ids.bookerInternal);
      expect(notes.any((n) => n.type == 'booking.cancelled_by_admin'), isTrue);
    });
  });

  group('attendance (BR-34, BR-35, BR-37)', () {
    Future<Booking> confirmedAt(DateTime slot) async {
      final b = ok(await env.layer.bookings.create(req(
        Ids.bookerExternal,
        Ids.hall2,
        slot,
        end: slot.add(const Duration(hours: 1)),
      )));
      return b;
    }

    test('a manager records attendance inside the window', () async {
      final slot = env.at(0, 12);
      final b = await confirmedAt(slot);
      env.setNow(slot.subtract(const Duration(minutes: 10)));
      final r = ok(await env.layer.bookings
          .markAttendance(b.id, AttendanceMethod.qr, Ids.hallManager));
      expect(r.status, BookingStatus.attended);
    });

    test('before the window opens it is refused', () async {
      final slot = env.at(0, 12);
      final b = await confirmedAt(slot);
      env.setNow(slot.subtract(const Duration(minutes: 20)));
      expect(
        fail(await env.layer.bookings
            .markAttendance(b.id, AttendanceMethod.qr, Ids.hallManager)),
        isA<CheckInClosed>(),
      );
    });

    test('a plain booker cannot mark attendance', () async {
      final slot = env.at(0, 12);
      final b = await confirmedAt(slot);
      env.setNow(slot);
      expect(
        fail(await env.layer.bookings
            .markAttendance(b.id, AttendanceMethod.qr, Ids.bookerInternal)),
        isA<NotPermitted>(),
      );
    });

    test('manual attendance is flagged as manual', () async {
      final slot = env.at(0, 12);
      final b = await confirmedAt(slot);
      env.setNow(slot);
      ok(await env.layer.bookings
          .markAttendance(b.id, AttendanceMethod.manual, Ids.hallManager));
      final a = await env.layer.attendance.forBooking(b.id);
      expect(a!.method, AttendanceMethod.manual);
      expect(a.markedBy, Ids.hallManager);
    });

    test('a confirmed booking with no attendance becomes NO_SHOW, no penalty',
        () async {
      final slot = env.at(0, 12);
      final b = await confirmedAt(slot);
      env.setNow(slot.add(const Duration(hours: 2)));
      expect(await env.layer.bookings.markNoShows(), 1);
      expect(ok(await env.layer.bookings.get(b.id)).status, BookingStatus.noShow);
      // The user can book again as normal.
      final again = await env.layer.bookings.create(req(
        Ids.bookerExternal,
        Ids.hall2,
        env.at(2, 10),
        end: env.at(2, 11),
      ));
      expect(again, isA<Ok<Booking>>());
    });
  });

  group('lists', () {
    test('listForUser returns the seeded bookings of that user', () async {
      final list = await env.layer.bookings.listForUser(Ids.bookerInternal);
      expect(list, isNotEmpty);
      expect(list.every((b) => b.userId == Ids.bookerInternal), isTrue);
    });

    test('upcoming filters to bookings that have not ended', () async {
      final up = await env.layer.bookings
          .listForUser(Ids.bookerInternal, upcoming: true);
      expect(up.every((b) => b.end.isAfter(env.now)), isTrue);
    });

    test('get of an unknown id is NotFound', () async {
      expect(fail(await env.layer.bookings.get('nope')), isA<NotFound>());
    });
  });

  group('setting changes against bookings (BR-04)', () {
    test('cannot change the booking mode while future bookings exist',
        () async {
      ok(await env.layer.bookings
          .create(req(Ids.bookerInternal, Ids.futsal2, env.at(2, 18))));
      final r = await env.layer.settings.set(
        SettingKeys.bookingMode,
        BookingMode.shared,
        const SettingScope.unit(Ids.futsal2),
        actorId: Ids.superAdmin,
      );
      expect((r as Err<void>).failure, isA<Conflict>());
    });

    test('can change the mode on a unit with no future bookings', () async {
      final r = await env.layer.settings.set(
        SettingKeys.bookingMode,
        BookingMode.shared,
        const SettingScope.unit(Ids.tennis2),
        actorId: Ids.superAdmin,
      );
      expect(r, isA<Ok<void>>());
    });

    test('cannot cut the capacity below the seats already booked', () async {
      final slot = env.at(2, 9);
      for (final u in [Ids.bookerInternal, Ids.bookerExternal, Ids.userExpired]) {
        ok(await env.layer.bookings.create(req(u, Ids.pool6, slot)));
      }
      final tooLow = await env.layer.settings.set(
        SettingKeys.capacity,
        2,
        const SettingScope.unit(Ids.pool6),
        actorId: Ids.superAdmin,
      );
      expect((tooLow as Err<void>).failure, isA<Conflict>());
      final enough = await env.layer.settings.set(
        SettingKeys.capacity,
        3,
        const SettingScope.unit(Ids.pool6),
        actorId: Ids.superAdmin,
      );
      expect(enough, isA<Ok<void>>());
    });
  });

  group('permissions at the repository (SC-009)', () {
    test('a guest can browse availability but any write is NotPermitted',
        () async {
      final slots = await env.layer.availability
          .slots(Ids.futsal2, env.at(1, 0), env.at(2, 0));
      expect(slots, isNotEmpty);
      expect(
        fail(await env.layer.bookings
            .create(req(null, Ids.futsal2, env.at(2, 18)))),
        isA<NotPermitted>(),
      );
    });
  });
}
