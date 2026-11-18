import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';
import 'package:sprint/features/booking/domain/selection_resolver.dart';
import 'package:sprint/features/booking/domain/slot.dart';

import '../../../helpers/domain_builders.dart';
import 'schedule_fixtures.dart';

void main() {
  final paid = buildSchedule(
    unitIds: ['u1', 'u2'],
    slots: {
      'u1': [slotAt(1, 9), slotAt(1, 10, state: SlotState.full), slotAt(2, 9)],
      'u2': [slotAt(2, 9)],
    },
  );

  ScheduleSelection sel({
    int? day,
    String? unit,
    String? trainer,
    int? from,
    int? to,
  }) => ScheduleSelection(
    day: day == null ? null : dayPlus(day),
    unitId: unit,
    trainerId: trainer,
    startMinutes: from == null ? null : from * 60,
    endMinutes: to == null ? null : to * 60,
  );

  test('an empty address gets the defaults and no notice (FR-003)', () {
    final r = SelectionResolver.resolve(ScheduleSelection.empty, paid);
    expect(r.selection, sel(day: 1, unit: 'u1'));
    expect(r.droppedChoice, isFalse);
  });

  test('a valid day and unit are kept', () {
    final r = SelectionResolver.resolve(sel(day: 2, unit: 'u2'), paid);
    expect(r.selection, sel(day: 2, unit: 'u2'));
    expect(r.droppedChoice, isFalse);
  });

  test(
    'a day outside the window or closed falls back with a notice (FR-012)',
    () {
      for (final bad in [
        sel(day: 30, unit: 'u1'),
        sel(day: -1, unit: 'u1'),
        sel(day: 4, unit: 'u1'),
      ]) {
        final r = SelectionResolver.resolve(bad, paid);
        expect(r.selection.day, dayPlus(1));
        expect(r.droppedChoice, isTrue);
      }
    },
  );

  test('an unknown unit falls back to the first with places that day', () {
    final r = SelectionResolver.resolve(sel(day: 2, unit: 'gone'), paid);
    expect(r.selection, sel(day: 2, unit: 'u1'));
    expect(r.droppedChoice, isTrue);
  });

  test('a bookable slot is kept', () {
    final r = SelectionResolver.resolve(
      sel(day: 1, unit: 'u1', from: 9, to: 10),
      paid,
    );
    expect(r.selection.hasTime, isTrue);
    expect(r.droppedChoice, isFalse);
  });

  test(
    'a full, missing or two-slot time is cleared with a notice (FR-010)',
    () {
      for (final bad in [
        sel(day: 1, unit: 'u1', from: 10, to: 11), // full
        sel(day: 1, unit: 'u1', from: 14, to: 15), // not on the grid
        sel(day: 1, unit: 'u1', from: 9, to: 11), // two slots on the slot path
      ]) {
        final r = SelectionResolver.resolve(bad, paid);
        expect(r.selection, sel(day: 1, unit: 'u1'));
        expect(r.droppedChoice, isTrue);
      }
    },
  );

  test('a time on a day that had to change is dropped', () {
    final r = SelectionResolver.resolve(
      sel(day: 30, unit: 'u1', from: 9, to: 10),
      paid,
    );
    expect(r.selection.hasTime, isFalse);
    expect(r.droppedChoice, isTrue);
  });

  test('a trainer parameter on a facility without trainers is dropped', () {
    final r = SelectionResolver.resolve(
      sel(day: 1, unit: 'u1', trainer: 't1'),
      paid,
    );
    expect(r.selection.trainerId, isNull);
    expect(r.droppedChoice, isTrue);
  });

  group('range path (BR-08)', () {
    final free = buildSchedule(
      isFree: true,
      settingsByUnit: {'u1': settings(maxRangeHours: 3)},
      slots: {
        'u1': [for (var h = 9; h < 15; h++) slotAt(1, h)],
      },
    );

    test('a run of bookable slots within the maximum is kept', () {
      final r = SelectionResolver.resolve(
        sel(day: 1, unit: 'u1', from: 9, to: 12),
        free,
      );
      expect(r.selection.lengthMinutes, 180);
      expect(r.droppedChoice, isFalse);
    });

    test('longer than the maximum is cleared', () {
      final r = SelectionResolver.resolve(
        sel(day: 1, unit: 'u1', from: 9, to: 13),
        free,
      );
      expect(r.selection.hasTime, isFalse);
      expect(r.droppedChoice, isTrue);
    });
  });

  group('trainer path (BR-09)', () {
    test('no trainer chosen: nothing else applies, and no notice', () {
      final s = buildSchedule(
        requiresTrainer: true,
        trainers: const [trainerA],
      );
      final r = SelectionResolver.resolve(sel(day: 1, from: 9, to: 10), s);
      expect(r.selection, sel(day: 1), reason: 'only the day is kept');
      expect(r.droppedChoice, isFalse);
    });

    test('an unknown trainer is dropped with a notice', () {
      final s = buildSchedule(
        requiresTrainer: true,
        trainers: const [trainerA],
      );
      final r = SelectionResolver.resolve(sel(trainer: 'gone'), s);
      expect(r.selection, ScheduleSelection.empty);
      expect(r.droppedChoice, isTrue);
    });

    test('a chosen session takes its unit from the session (FR-018)', () {
      final s = buildSchedule(
        requiresTrainer: true,
        unitIds: ['u1', 'u2'],
        trainers: const [trainerA],
        trainer: trainerA,
        slots: {
          'u1': [slotAt(1, 10)],
          'u2': [slotAt(1, 11)],
        },
      );
      final r = SelectionResolver.resolve(
        sel(day: 1, trainer: 't1', from: 11, to: 12),
        s,
      );
      expect(r.selection.unitId, 'u2');
      expect(r.selection.trainerId, 't1');
      expect(r.droppedChoice, isFalse);

      final noUnit = SelectionResolver.resolve(sel(day: 1, trainer: 't1'), s);
      expect(noUnit.selection.unitId, isNull);
      expect(noUnit.droppedChoice, isFalse);

      final wrongUnit = SelectionResolver.resolve(
        sel(day: 1, trainer: 't1', unit: 'u1', from: 11, to: 12),
        s,
      );
      expect(wrongUnit.selection.hasTime, isFalse);
      expect(wrongUnit.droppedChoice, isTrue);
    });
  });

  test('cairo helper sanity', () {
    expect(cairo(2026, 11, 15, 9).isUtc, isTrue);
  });
}
