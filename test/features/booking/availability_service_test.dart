import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/features/booking/domain/availability_service.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/slot.dart';
import 'package:sprint/features/booking/domain/unit_settings.dart';
import 'package:sprint/features/catalogue/domain/closure.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/domain/trainer.dart';
import 'package:sprint/features/catalogue/domain/trainer_availability.dart';

import '../../helpers/domain_builders.dart';

/// Table-driven checks of slot generation (BR-05 – BR-09). Cairo wall-clock
/// times are written with `cairo(y, m, d, h, min)`; 2026-11-14 is a Saturday.
void main() {
  const service = AvailabilityService();
  final f = facility();
  final u = unit();
  final day = DateTime(2026, 11, 14);

  List<Slot> slots({
    List<Closure> closures = const [],
    List<Booking> bookings = const [],
    UnitSettings? s,
    DateTime? now,
    DateTime? from,
    DateTime? to,
    int open = 480,
    int close = 720,
    Trainer? trainer,
    List<TrainerAvailability> trainerAvailability = const [],
    bool inactive = false,
    Facility? fac,
  }) =>
      service.slots(
        facility: fac ?? f,
        unit: inactive ? unit(isActive: false) : u,
        hours: dailyHours('f1', open: open, close: close),
        closures: closures,
        bookings: bookings,
        settings: s ?? settings(bookingWindowDays: 30),
        now: now ?? cairo(2026, 11, 13, 6),
        fromDay: from ?? day,
        toDay: to ?? day,
        trainer: trainer,
        trainerAvailability: trainerAvailability,
      );

  String hhmm(DateTime utc) {
    final c = cairo(2026, 11, 14); // ensures tz init
    expect(c, isNotNull);
    return '${utc.toUtc().hour}';
  }

  group('hours minus closures (BR-05)', () {
    test('slots fill the opening hours at the granularity', () {
      final s = slots();
      expect(s, hasLength(4)); // 8:00-12:00 hourly
      expect(s.first.start, cairo(2026, 11, 14, 8));
      expect(s.last.end, cairo(2026, 11, 14, 12));
      expect(s.every((x) => x.state == SlotState.available), isTrue);
      expect(hhmm(s.first.start), isNotEmpty);
    });

    test('a partial last slot is dropped', () {
      expect(slots(open: 480, close: 690), hasLength(3)); // 8:00-11:30
    });

    test('a closure removes every slot it overlaps', () {
      final s = slots(closures: [
        Closure(
          id: 'c1',
          scope: ClosureScope.unit,
          scopeId: 'u1',
          from: cairo(2026, 11, 14, 9, 30),
          to: cairo(2026, 11, 14, 10, 30),
          reason: 'صيانة',
        ),
      ]);
      expect(s.map((x) => x.start), [
        cairo(2026, 11, 14, 8),
        cairo(2026, 11, 14, 11),
      ]);
    });

    test('a facility closure applies to its units', () {
      final s = slots(closures: [
        Closure(
          id: 'c2',
          scope: ClosureScope.facility,
          scopeId: 'f1',
          from: cairo(2026, 11, 14),
          to: cairo(2026, 11, 15),
          reason: 'إغلاق',
        ),
      ]);
      expect(s, isEmpty);
    });

    test('a closure on another unit does not apply', () {
      final s = slots(closures: [
        Closure(
          id: 'c3',
          scope: ClosureScope.unit,
          scopeId: 'other',
          from: cairo(2026, 11, 14),
          to: cairo(2026, 11, 15),
          reason: 'x',
        ),
      ]);
      expect(s, hasLength(4));
    });

    test('an inactive unit has no available slots', () {
      expect(slots(inactive: true).every((x) => x.state == SlotState.closed),
          isTrue);
    });

    test('unit hours replace facility hours for that unit', () {
      final s = service.slots(
        facility: f,
        unit: u,
        hours: [
          ...dailyHours('f1', open: 480, close: 720),
          ...dailyHours('u1', open: 600, close: 720),
        ],
        closures: const [],
        bookings: const [],
        settings: settings(bookingWindowDays: 30),
        now: cairo(2026, 11, 13, 6),
        fromDay: day,
        toDay: day,
      );
      expect(s, hasLength(2)); // 10:00-12:00 only
    });

    test('a day with no hours has no slots', () {
      final s = service.slots(
        facility: f,
        unit: u,
        hours: dailyHours('f1', days: const [1]), // Mondays only
        closures: const [],
        bookings: const [],
        settings: settings(bookingWindowDays: 30),
        now: cairo(2026, 11, 13, 6),
        fromDay: day,
        toDay: day,
      );
      expect(s, isEmpty);
    });
  });

  group('booking window (BR-06)', () {
    test('slots beyond the window are not offered', () {
      final s = slots(
        s: settings(bookingWindowDays: 3),
        now: cairo(2026, 11, 14, 6),
        from: DateTime(2026, 11, 14),
        to: DateTime(2026, 11, 20),
      );
      final days = s.map((x) => x.start).toSet();
      expect(days.any((d) => d.isAfter(cairo(2026, 11, 17))), isFalse);
      expect(s.map((x) => x.start).where((d) => d.isBefore(cairo(2026, 11, 15))),
          isNotEmpty);
      // Nov 14, 15 and 16 only: 3 days x 4 slots.
      expect(s, hasLength(12));
    });
  });

  group('past slots and lead time (BR-07)', () {
    test('slots that already started are past', () {
      final s = slots(now: cairo(2026, 11, 14, 10));
      expect(s.map((x) => x.state), [
        SlotState.past, // 8:00
        SlotState.past, // 9:00
        SlotState.past, // 10:00 starts now
        SlotState.available, // 11:00
      ]);
    });

    test('minLeadMinutes blocks slots that start too soon', () {
      final now = cairo(2026, 11, 14, 7, 45);
      expect(slots(now: now).first.state, SlotState.available);
      final withLead = slots(now: now, s: settings(minLeadMinutes: 30));
      expect(withLead.first.state, SlotState.past); // 8:00 is 15 min away
      expect(withLead[1].state, SlotState.available);
    });
  });

  group('exclusive and shared capacity (BR-02, BR-03, BR-12)', () {
    final nine = cairo(2026, 11, 14, 9);

    test('exclusive: one booking fills the slot', () {
      final s = slots(
        s: settings(mode: BookingMode.exclusive, bookingWindowDays: 30),
        bookings: [booking(start: nine)],
      );
      final slot = s.firstWhere((x) => x.start == nine);
      expect(slot.state, SlotState.full);
      expect(slot.remaining, 0);
      expect(s.firstWhere((x) => x.start == cairo(2026, 11, 14, 8)).state,
          SlotState.available);
    });

    test('shared: remaining places count down and become full', () {
      UnitSettings sh() =>
          settings(mode: BookingMode.shared, capacity: 4, bookingWindowDays: 30);
      Slot at(List<Booking> b) =>
          slots(s: sh(), bookings: b).firstWhere((x) => x.start == nine);

      expect(at([]).remaining, 4);
      expect(at([booking(start: nine)]).state, SlotState.available);
      final two = at([booking(start: nine), booking(start: nine)]);
      expect((two.state, two.remaining), (SlotState.fewLeft, 2));
      final one = at([for (var i = 0; i < 3; i++) booking(start: nine)]);
      expect((one.state, one.remaining), (SlotState.fewLeft, 1));
      final full = at([for (var i = 0; i < 4; i++) booking(start: nine)]);
      expect((full.state, full.remaining), (SlotState.full, 0));
    });

    test('only bookings that hold a place count', () {
      final now = cairo(2026, 11, 13, 6);
      final s = slots(
        s: settings(mode: BookingMode.shared, capacity: 2, bookingWindowDays: 30),
        now: now,
        bookings: [
          booking(start: nine, status: BookingStatus.cancelled),
          booking(start: nine, status: BookingStatus.expired),
          // hold already elapsed
          booking(
            start: nine,
            status: BookingStatus.pendingPayment,
            holdExpiresAt: now.subtract(const Duration(minutes: 1)),
          ),
        ],
      );
      expect(s.firstWhere((x) => x.start == nine).remaining, 2);
    });

    test('a live hold counts as taken', () {
      final now = cairo(2026, 11, 13, 6);
      final s = slots(
        s: settings(mode: BookingMode.exclusive, bookingWindowDays: 30),
        now: now,
        bookings: [
          booking(
            start: nine,
            status: BookingStatus.pendingPayment,
            holdExpiresAt: now.add(const Duration(minutes: 5)),
          ),
        ],
      );
      expect(s.firstWhere((x) => x.start == nine).state, SlotState.full);
    });

    test('seats of one booking count together', () {
      final s = slots(
        s: settings(mode: BookingMode.shared, capacity: 4, bookingWindowDays: 30),
        bookings: [booking(start: nine, seats: 3)],
      );
      expect(s.firstWhere((x) => x.start == nine).remaining, 1);
    });
  });

  group('free facility ranges (BR-08)', () {
    final hall = facility(isFree: true, type: FacilityType.hall);
    final cfg = settings(bookingWindowDays: 30); // granularity 60, max 3 h
    final now = cairo(2026, 11, 13, 6);

    Failure? check(
      DateTime start,
      DateTime end, {
      List<Booking> bookings = const [],
      UnitSettings? s,
    }) =>
        service.checkRequest(
          facility: hall,
          unit: u,
          hours: dailyHours('f1', open: 480, close: 1320),
          closures: const [],
          settings: s ?? cfg,
          now: now,
          start: start,
          end: end,
        );

    test('a range within the limit is fine', () {
      expect(check(cairo(2026, 11, 14, 9), cairo(2026, 11, 14, 12)), isNull);
    });

    test('longer than maxRangeHours is refused', () {
      expect(check(cairo(2026, 11, 14, 9), cairo(2026, 11, 14, 13)),
          isA<RangeTooLong>());
    });

    test('a longer limit allows it', () {
      expect(
        check(
          cairo(2026, 11, 14, 9),
          cairo(2026, 11, 14, 13),
          s: settings(maxRangeHours: 5, bookingWindowDays: 30),
        ),
        isNull,
      );
    });

    test('a range that is not a multiple of the granularity is refused', () {
      expect(check(cairo(2026, 11, 14, 9), cairo(2026, 11, 14, 10, 30)),
          isA<ClosedSlot>());
    });

    test('a range outside opening hours is refused', () {
      expect(check(cairo(2026, 11, 14, 7), cairo(2026, 11, 14, 9)),
          isA<ClosedSlot>());
    });

    test('a range in the past is refused', () {
      expect(
        service.checkRequest(
          facility: hall,
          unit: u,
          hours: dailyHours('f1', open: 480, close: 1320),
          closures: const [],
          settings: cfg,
          now: cairo(2026, 11, 14, 10),
          start: cairo(2026, 11, 14, 9),
          end: cairo(2026, 11, 14, 11),
        ),
        isA<SlotPast>(),
      );
    });

    test('a range beyond the window is refused', () {
      expect(
        check(
          cairo(2026, 12, 20, 9),
          cairo(2026, 12, 20, 11),
          s: settings(bookingWindowDays: 7),
        ),
        isA<OutsideWindow>(),
      );
    });

    test('a range crossing a closure is refused', () {
      expect(
        service.checkRequest(
          facility: hall,
          unit: u,
          hours: dailyHours('f1', open: 480, close: 1320),
          closures: [
            Closure(
              id: 'c',
              scope: ClosureScope.unit,
              scopeId: 'u1',
              from: cairo(2026, 11, 14, 10),
              to: cairo(2026, 11, 14, 11),
              reason: 'x',
            ),
          ],
          settings: cfg,
          now: now,
          start: cairo(2026, 11, 14, 9),
          end: cairo(2026, 11, 14, 12),
        ),
        isA<ClosedSlot>(),
      );
    });

    test('a paid facility accepts exactly one slot, not a longer range', () {
      Failure? paid(DateTime start, DateTime end) => service.checkRequest(
            facility: f,
            unit: u,
            hours: dailyHours('f1'),
            closures: const [],
            settings: cfg,
            now: now,
            start: start,
            end: end,
          );
      expect(paid(cairo(2026, 11, 14, 9), cairo(2026, 11, 14, 10)), isNull);
      expect(paid(cairo(2026, 11, 14, 9), cairo(2026, 11, 14, 11)),
          isA<RangeTooLong>());
    });
  });

  group('trainer sessions (BR-09)', () {
    final academy = facility(requiresTrainer: true, type: FacilityType.training);
    const t = Trainer(
      id: 't1',
      userId: 'tu1',
      facilityIds: ['f1'],
      bio: 'مدرب',
      trainerCapacity: 3,
    );
    final avail = [
      const TrainerAvailability(
        trainerId: 't1',
        unitId: 'u1',
        dayOfWeek: DateTime.saturday,
        fromMinutes: 600,
        toMinutes: 720,
      ),
    ];

    test('sessions exist only inside the trainer availability', () {
      final s = slots(
        fac: academy,
        trainer: t,
        trainerAvailability: avail,
        s: settings(mode: BookingMode.shared, capacity: 8, bookingWindowDays: 30),
      );
      expect(s.map((x) => x.start), [
        cairo(2026, 11, 14, 10),
        cairo(2026, 11, 14, 11),
      ]);
    });

    test('capacity is the smaller of the unit and the trainer', () {
      List<Slot> with_(int unitCap) => slots(
            fac: academy,
            trainer: t,
            trainerAvailability: avail,
            s: settings(
              mode: BookingMode.shared,
              capacity: unitCap,
              bookingWindowDays: 30,
            ),
          );
      expect(with_(8).first.capacity, 3); // trainer is the limit
      expect(with_(2).first.capacity, 2); // unit is the limit
    });

    test("the trainer's own bookings fill the session", () {
      final ten = cairo(2026, 11, 14, 10);
      final s = slots(
        fac: academy,
        trainer: t,
        trainerAvailability: avail,
        s: settings(mode: BookingMode.shared, capacity: 8, bookingWindowDays: 30),
        bookings: [for (var i = 0; i < 3; i++) booking(start: ten, trainerId: 't1')],
      );
      expect(s.first.state, SlotState.full);
      expect(s[1].state, SlotState.available);
    });

    test('a different session length is used for sessions', () {
      final s = slots(
        fac: academy,
        trainer: t,
        trainerAvailability: [
          const TrainerAvailability(
            trainerId: 't1',
            unitId: 'u1',
            dayOfWeek: DateTime.saturday,
            fromMinutes: 600,
            toMinutes: 690,
          ),
        ],
        s: settings(
          mode: BookingMode.shared,
          capacity: 8,
          sessionMinutes: 45,
          bookingWindowDays: 30,
        ),
      );
      expect(s, hasLength(2)); // 10:00-10:45 and 10:45-11:30
      expect(s[1].start, cairo(2026, 11, 14, 10, 45));
    });
  });

  test('a daylight-saving day keeps wall-clock slots', () {
    // Find Egypt's spring-forward day from the data: the 23-hour day.
    final spring = DateTime(2026, 4, 24);
    final s = service.slots(
      facility: f,
      unit: u,
      hours: dailyHours('f1', open: 480, close: 720),
      closures: const [],
      bookings: const [],
      settings: settings(bookingWindowDays: 60),
      now: cairo(2026, 4, 20, 6),
      fromDay: spring,
      toDay: spring,
    );
    expect(s, hasLength(4));
    expect(s.first.start, cairo(2026, 4, 24, 8));
    expect(s.every((x) => x.end.difference(x.start) == const Duration(hours: 1)),
        isTrue);
  });
}
