import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/data/in_memory_data_layer.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_booking_extras.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/features/booking/domain/booking_path.dart';
import 'package:sprint/features/booking/domain/booking_repository.dart';
import 'package:sprint/features/booking/domain/facility_schedule.dart';
import 'package:sprint/features/booking/domain/slot.dart';
import 'package:sprint/features/booking/presentation/providers/booking_providers.dart';

/// The schedule provider (contracts/providers.md). "Now" is Saturday
/// 2026-11-14 08:00 in Cairo unless a test moves it.
void main() {
  CairoTime.ensureInitialized();
  var now = CairoTime.atWallClock(2026, 11, 14, 8);

  ProviderContainer container() {
    final layer = InMemoryDataLayer.create(
      clock: Clock(() => now),
      paymentDelay: Duration.zero,
    );
    final c = ProviderContainer(
      overrides: [
        dataLayerProvider.overrideWithValue(layer),
        appClockProvider.overrideWithValue(Clock(() => now)),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  setUp(() => now = CairoTime.atWallClock(2026, 11, 14, 8));

  DateTime at(int day, int hour) =>
      CairoTime.atWallClock(2026, 11, 14 + day, hour);

  Slot? slotAt(FacilitySchedule s, String unit, int day, int hour) {
    final list = s.slotsFor(unit, DateTime(2026, 11, 14 + day));
    return list.where((x) => x.start == at(day, hour)).firstOrNull;
  }

  Future<FacilitySchedule?> load(
    ProviderContainer c,
    String facility, [
    String? trainer,
  ]) async {
    final p = facilityScheduleProvider(facility, trainer);
    c.listen(p, (_, _) {});
    return c.read(p.future);
  }

  test('a missing or unpublished facility is null', () async {
    final c = container();
    expect(await load(c, 'nope'), isNull);
  });

  test('one load covers every day of the window for every active unit', () async {
    final c = container();
    final s = (await load(c, SeedIds.poolFacility))!;
    expect(s.path, BookingPath.slot);
    expect(s.days, hasLength(7));
    expect(s.days.first.date, DateTime(2026, 11, 14));
    expect(s.units.map((u) => u.id), [
      SeedIds.pool1,
      SeedIds.pool2,
      SeedIds.pool3,
      SeedIds.pool4,
      SeedIds.pool5,
      SeedIds.pool6,
    ]);
    // Lane 2: capacity 3, full on day +3 at 10:00; few-left on day +2 at 12:00.
    expect(slotAt(s, SeedIds.pool2, 3, 10)!.state, SlotState.full);
    expect(
      slotAt(s, SeedIds.pool2, seedFewLeftDayOffset, seedFewLeftHour)!.state,
      SlotState.fewLeft,
    );
    expect(s.unit(SeedIds.pool2)!.capacity, 3);
    expect(s.unit(SeedIds.pool1)!.priceInternal, 20);
    // The pitch closure removes the slots of pitch A on day +3 only.
    final futsal = (await load(c, SeedIds.futsalFacility))!;
    expect(futsal.slotsFor(SeedIds.futsal1, DateTime(2026, 11, 17)), isEmpty);
    expect(
      futsal.slotsFor(SeedIds.futsal2, DateTime(2026, 11, 17)),
      isNotEmpty,
    );
    expect(futsal.days[3].isClosed, isFalse);
  });

  test('the hall is closed on Friday and uses the range path', () async {
    final c = container();
    final s = (await load(c, SeedIds.hallFacility))!;
    expect(s.path, BookingPath.range);
    // 2026-11-20 is a Friday: day +6.
    expect(s.days[6].isClosed, isTrue);
    expect(s.days[5].isClosed, isFalse);
  });

  test('another booking changes the slot without a manual refresh', () async {
    final c = container();
    final p = facilityScheduleProvider(SeedIds.futsalFacility, null);
    final s = (await load(c, SeedIds.futsalFacility))!;
    expect(slotAt(s, SeedIds.futsal2, 2, 18)!.state, SlotState.available);

    final layer = c.read(dataLayerProvider);
    await layer.bookings.create(
      BookingRequest(
        userId: SeedIds.bookerInternal,
        unitId: SeedIds.futsal2,
        start: at(2, 18),
        end: at(2, 19),
      ),
    );
    await Future<void>.delayed(Duration.zero);
    final after = (await c.read(p.future))!;
    expect(slotAt(after, SeedIds.futsal2, 2, 18)!.state, SlotState.full);
  });

  test('the timer turns a slot past without a tap', () {
    fakeAsync((async) {
      final layer = InMemoryDataLayer.create(
        clock: Clock(() => now),
        paymentDelay: Duration.zero,
      );
      final c = ProviderContainer(
        overrides: [
          dataLayerProvider.overrideWithValue(layer),
          appClockProvider.overrideWithValue(Clock(() => now)),
        ],
      );
      final p = facilityScheduleProvider(SeedIds.futsalFacility, null);
      c.listen(p, (_, _) {});
      async.flushMicrotasks();
      expect(
        slotAt(c.read(p).value!, SeedIds.futsal2, 0, 9)!.state,
        SlotState.available,
      );

      now = CairoTime.atWallClock(2026, 11, 14, 9, 30);
      async.elapse(const Duration(hours: 2));
      async.flushMicrotasks();
      expect(
        slotAt(c.read(p).value!, SeedIds.futsal2, 0, 9)!.state,
        SlotState.past,
      );
      c.dispose();
    });
  });

  test(
    'moving past Cairo midnight drops yesterday and adds a new last day',
    () {
      fakeAsync((async) {
        final layer = InMemoryDataLayer.create(
          clock: Clock(() => now),
          paymentDelay: Duration.zero,
        );
        final c = ProviderContainer(
          overrides: [
            dataLayerProvider.overrideWithValue(layer),
            appClockProvider.overrideWithValue(Clock(() => now)),
          ],
        );
        final p = facilityScheduleProvider(SeedIds.futsalFacility, null);
        c.listen(p, (_, _) {});
        async.flushMicrotasks();
        expect(c.read(p).value!.days.first.date, DateTime(2026, 11, 14));

        now = CairoTime.atWallClock(2026, 11, 15, 0, 5);
        c.invalidate(p);
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        final days = c.read(p).value!.days;
        expect(days.first.date, DateTime(2026, 11, 15));
        expect(days.last.date, DateTime(2026, 11, 21));
        c.dispose();
      });
    },
  );

  group('trainer path', () {
    test('before a trainer is chosen: the trainers, and no slots', () async {
      final c = container();
      final s = (await load(c, SeedIds.academyFacility))!;
      expect(s.path, BookingPath.trainer);
      expect(s.needsTrainer, isTrue);
      expect(s.trainers.map((t) => t.id), [
        SeedIds.trainerRecord1,
        SeedIds.trainerRecord2,
        SeedIds.trainerRecord3,
      ]);
      expect(s.trainers.every((t) => t.hasSessionsInWindow), isTrue);
      expect(s.trainers.first.name, isNotNull);
      expect(s.trainers.first.capacity, 3);
    });

    test('with trainer 1: one unit, sessions, and one full session', () async {
      final c = container();
      final s = (await load(
        c,
        SeedIds.academyFacility,
        SeedIds.trainerRecord1,
      ))!;
      expect(s.needsTrainer, isFalse);
      expect(s.units.map((u) => u.id), [SeedIds.room1]);
      final day = seedTrainerFullDayOffset(now);
      final session = s
          .sessionsOn(DateTime(2026, 11, 14 + day))
          .firstWhere((x) => x.startMinutes == seedTrainerFullHour * 60);
      expect(session.slot.state, SlotState.full);
      expect(session.unitId, SeedIds.room1);
    });

    test('an unknown trainer is no trainer', () async {
      final c = container();
      final s = (await load(c, SeedIds.academyFacility, 'gone'))!;
      expect(s.needsTrainer, isTrue);
    });
  });

  group('my upcoming bookings', () {
    test('empty for a guest', () async {
      final c = container();
      c.listen(myUpcomingBookingsProvider, (_, _) {});
      expect(await c.read(myUpcomingBookingsProvider.future), isEmpty);
    });

    test('the signed-in booker\'s bookings that have not ended', () async {
      final c = container();
      await c.read(sessionProvider.notifier).actAs(SeedIds.bookerInternal);
      c.listen(myUpcomingBookingsProvider, (_, _) {});
      final list = await c.read(myUpcomingBookingsProvider.future);
      expect(list, isNotEmpty);
      expect(list.every((b) => b.userId == SeedIds.bookerInternal), isTrue);
      expect(list.every((b) => b.end.isAfter(now)), isTrue);
    });
  });
}
