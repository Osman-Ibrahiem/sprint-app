import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/booking/domain/booking_path.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';
import 'package:sprint/features/booking/domain/slot.dart';
import 'package:sprint/features/booking/domain/unit_settings.dart';
import 'package:sprint/features/catalogue/domain/price.dart';

import '../../../helpers/domain_builders.dart';
import 'schedule_fixtures.dart';

void main() {
  group('days (FR-002 – FR-004)', () {
    test(
      'one day per day of the longest window among the units, from today',
      () {
        final s = buildSchedule(
          unitIds: ['u1', 'u2'],
          settingsByUnit: {
            'u1': settings(bookingWindowDays: 3),
            'u2': settings(bookingWindowDays: 5),
          },
        );
        expect(s.days, hasLength(5));
        expect(s.days.first.date, fixtureToday);
        expect(s.days.last.date, dayPlus(4));
        expect(s.today, fixtureToday);
      },
    );

    test('with no units the fallback window is used', () {
      final s = buildSchedule(unitIds: const [], fallbackWindowDays: 4);
      expect(s.days, hasLength(4));
      expect(s.units, isEmpty);
      expect(s.defaultUnit(fixtureToday), isNull);
    });

    test(
      'closed when no unit has any slot; available when one is bookable',
      () {
        final s = buildSchedule(
          unitIds: ['u1', 'u2'],
          slots: {
            'u1': [
              slotAt(0, 9, state: SlotState.past),
              slotAt(1, 9, state: SlotState.full),
            ],
            'u2': [
              slotAt(1, 10),
              slotAt(3, 10, state: SlotState.fewLeft, remaining: 1),
            ],
          },
        );
        final d = s.days;
        // Today: only a past slot. Not closed, nothing to book.
        expect((d[0].isClosed, d[0].hasAvailability), (false, false));
        expect((d[1].isClosed, d[1].hasAvailability), (false, true));
        expect((d[2].isClosed, d[2].hasAvailability), (true, false));
        expect((d[3].isClosed, d[3].hasAvailability), (false, true));
      },
    );

    test('closed slots are never kept', () {
      final s = buildSchedule(
        slots: {
          'u1': [slotAt(1, 9, state: SlotState.closed)],
        },
      );
      expect(s.slotsFor('u1', dayPlus(1)), isEmpty);
      expect(s.days[1].isClosed, isTrue);
    });
  });

  group('defaults (FR-003, FR-008)', () {
    test('first day with availability, then first open day, then today', () {
      final withRoom = buildSchedule(
        slots: {
          'u1': [slotAt(1, 9, state: SlotState.full), slotAt(2, 9)],
        },
      );
      expect(withRoom.defaultDay, dayPlus(2));

      final onlyFull = buildSchedule(
        slots: {
          'u1': [slotAt(1, 9, state: SlotState.full)],
        },
      );
      expect(onlyFull.defaultDay, dayPlus(1));

      expect(buildSchedule().defaultDay, fixtureToday);
    });

    test('first unit with places that day, else the first unit', () {
      final s = buildSchedule(
        unitIds: ['u1', 'u2'],
        slots: {
          'u1': [slotAt(1, 9, state: SlotState.full)],
          'u2': [slotAt(1, 9)],
        },
      );
      expect(s.defaultUnit(dayPlus(1)), 'u2');
      expect(s.defaultUnit(dayPlus(2)), 'u1');
      expect(s.unitHasPlacesOn('u1', dayPlus(1)), isFalse);
      expect(s.unitHasPlacesOn('u2', dayPlus(1)), isTrue);
    });
  });

  group('units', () {
    test('carry their resolved settings and both prices', () {
      final s = buildSchedule(
        settingsByUnit: {
          'u1': settings(
            mode: BookingMode.exclusive,
            maxRangeHours: 2,
            slotGranularityMinutes: 30,
            sessionMinutes: 90,
          ),
        },
        prices: {
          'u1': const [
            Price(unitId: 'u1', tier: PriceTier.internal, amount: 20),
            Price(unitId: 'u1', tier: PriceTier.external, amount: 40),
          ],
        },
      );
      final u = s.units.single;
      expect(u.mode, BookingMode.exclusive);
      expect(u.isShared, isFalse);
      expect(
        (u.maxRangeHours, u.granularityMinutes, u.sessionMinutes),
        (2, 30, 90),
      );
      expect(u.fewLeftThreshold, 2);
      expect(
        (u.priceFor(PriceTier.internal), u.priceFor(PriceTier.external)),
        (20, 40),
      );
      expect(s.unit('u1'), same(u));
      expect(s.unit('nope'), isNull);
    });

    test('a missing price is null, not zero', () {
      expect(buildSchedule().units.single.priceInternal, isNull);
    });
  });

  group('grid', () {
    test('slot and range paths list the selected unit in time order', () {
      final s = buildSchedule(
        slots: {
          'u1': [slotAt(1, 11), slotAt(1, 9), slotAt(2, 9)],
        },
      );
      final grid = s.gridFor(ScheduleSelection(day: dayPlus(1), unitId: 'u1'));
      expect(grid.map((g) => g.startMinutes), [9 * 60, 11 * 60]);
      expect(grid.first.endMinutes, 10 * 60);
      expect(grid.first.unitId, 'u1');
      expect(s.gridFor(ScheduleSelection(day: dayPlus(1))), isEmpty);
      expect(s.gridFor(const ScheduleSelection(unitId: 'u1')), isEmpty);
    });

    test('a slot that crosses midnight belongs to the day it starts on', () {
      final s = buildSchedule(
        slots: {
          'u1': [slotAt(1, 23, minutes: 120)],
        },
      );
      final g = s
          .gridFor(ScheduleSelection(day: dayPlus(1), unitId: 'u1'))
          .single;
      expect((g.startMinutes, g.endMinutes), (23 * 60, 25 * 60));
      expect(s.slotsFor('u1', dayPlus(2)), isEmpty);
    });
  });

  group('trainer path (FR-017, FR-018)', () {
    test('before a trainer is chosen only the trainer step applies', () {
      final s = buildSchedule(
        requiresTrainer: true,
        trainers: const [trainerA],
      );
      expect(s.path, BookingPath.trainer);
      expect(s.needsTrainer, isTrue);
    });

    test('with a trainer, only units with sessions show, merged by start', () {
      final s = buildSchedule(
        requiresTrainer: true,
        unitIds: ['u1', 'u2', 'u3'],
        trainers: const [trainerA],
        trainer: trainerA,
        slots: {
          'u1': [slotAt(1, 12), slotAt(1, 10)],
          'u2': [slotAt(1, 11)],
          'u3': const [],
        },
      );
      expect(s.needsTrainer, isFalse);
      expect(s.units.map((u) => u.id), ['u1', 'u2']);
      final sessions = s.sessionsOn(dayPlus(1));
      expect(sessions.map((x) => (x.unitId, x.startMinutes ~/ 60)), [
        ('u1', 10),
        ('u2', 11),
        ('u1', 12),
      ]);
      expect(s.gridFor(ScheduleSelection(day: dayPlus(1))), hasLength(3));
    });

    test('equal starts keep the first bookable in catalogue order', () {
      final s = buildSchedule(
        requiresTrainer: true,
        unitIds: ['u1', 'u2'],
        trainers: const [trainerA],
        trainer: trainerA,
        slots: {
          'u1': [slotAt(1, 10, state: SlotState.full)],
          'u2': [slotAt(1, 10)],
        },
      );
      expect(s.sessionsOn(dayPlus(1)).single.unitId, 'u2');
    });
  });

  test('nextFlipAfter finds the next instant a slot turns to past', () {
    final s = buildSchedule(
      slots: {
        'u1': [slotAt(0, 7, state: SlotState.past), slotAt(0, 9), slotAt(1, 9)],
      },
    );
    expect(s.nextFlipAfter(fixtureNow), cairo(2026, 11, 14, 9));
    expect(
      s.nextFlipAfter(fixtureNow, lead: const Duration(minutes: 30)),
      cairo(2026, 11, 14, 8, 30),
    );
    expect(s.nextFlipAfter(cairo(2026, 11, 20)), isNull);
  });
}
