import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/features/booking/domain/facility_schedule.dart';
import 'package:sprint/features/booking/domain/range_selection.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';
import 'package:sprint/features/booking/domain/slot.dart';

import '../../../helpers/domain_builders.dart';
import 'schedule_fixtures.dart';

void main() {
  final base = ScheduleSelection(day: dayPlus(1), unitId: 'u1');

  List<ScheduleSlot> day({Map<int, SlotState> states = const {}, int capacity = 1, Set<int> missing = const {}}) => [
        for (var h = 9; h < 16; h++)
          if (!missing.contains(h))
            gridSlot(slotAt(1, h, state: states[h] ?? SlotState.available, capacity: capacity)),
      ];

  ScheduleSlot at(List<ScheduleSlot> d, int hour) =>
      d.firstWhere((s) => s.startMinutes == hour * 60);

  ScheduleSelection ok(Result<ScheduleSelection> r) => (r as Ok<ScheduleSelection>).value;
  Failure fail(Result<ScheduleSelection> r) => (r as Err<ScheduleSelection>).failure;

  test('the first tap is a one-slot range (FR-015)', () {
    final d = day();
    final s = ok(RangeSelection.tap(base, at(d, 10), d, 3));
    expect((s.startMinutes, s.endMinutes), (600, 660));
  });

  test('a later second tap extends to the end of that slot', () {
    final d = day();
    final one = ok(RangeSelection.tap(base, at(d, 10), d, 3));
    final s = ok(RangeSelection.tap(one, at(d, 12), d, 3));
    expect((s.startMinutes, s.endMinutes), (600, 780));
  });

  test('an earlier second tap runs from the earlier to the later', () {
    final d = day();
    final one = ok(RangeSelection.tap(base, at(d, 12), d, 3));
    final s = ok(RangeSelection.tap(one, at(d, 10), d, 3));
    expect((s.startMinutes, s.endMinutes), (600, 780));
  });

  test('a tap with a longer range chosen starts a new one-slot range', () {
    final d = day();
    var s = ok(RangeSelection.tap(base, at(d, 10), d, 3));
    s = ok(RangeSelection.tap(s, at(d, 11), d, 3));
    s = ok(RangeSelection.tap(s, at(d, 14), d, 3));
    expect((s.startMinutes, s.endMinutes), (840, 900));
  });

  test('the only selected slot again clears it', () {
    final d = day();
    final one = ok(RangeSelection.tap(base, at(d, 10), d, 3));
    expect(ok(RangeSelection.tap(one, at(d, 10), d, 3)).hasTime, isFalse);
  });

  test('a taken hour inside is refused, naming the hour (US-08)', () {
    final d = day(states: {11: SlotState.full});
    final one = ok(RangeSelection.tap(base, at(d, 10), d, 3));
    final f = fail(RangeSelection.tap(one, at(d, 12), d, 3));
    expect(f, isA<SlotTaken>());
    expect((f as SlotTaken).at, cairo(2026, 11, 15, 11));
  });

  test('a full hour in a shared unit is SlotFull', () {
    final d = day(states: {11: SlotState.full}, capacity: 6);
    final one = ok(RangeSelection.tap(base, at(d, 10), d, 3));
    expect(fail(RangeSelection.tap(one, at(d, 12), d, 3)), isA<SlotFull>());
  });

  test('a missing hour inside is refused as closed, naming it', () {
    final d = day(missing: {11});
    final one = ok(RangeSelection.tap(base, at(d, 10), d, 3));
    final f = fail(RangeSelection.tap(one, at(d, 12), d, 3));
    expect(f, isA<ClosedSlot>());
    expect((f as ClosedSlot).at, cairo(2026, 11, 15, 11));
  });

  test('longer than the maximum is refused, stating it (US-08)', () {
    final d = day();
    final one = ok(RangeSelection.tap(base, at(d, 9), d, 3));
    final f = fail(RangeSelection.tap(one, at(d, 12), d, 3));
    expect(f, isA<RangeTooLong>());
    expect((f as RangeTooLong).maxHours, 3);
    // Exactly the maximum is fine.
    expect(ok(RangeSelection.tap(one, at(d, 11), d, 3)).lengthMinutes, 180);
  });

  test('hours are counted by duration, whatever the granularity', () {
    final d = [
      for (var i = 0; i < 8; i++)
        gridSlot(slotAt(1, 9, minutes: 30).copyStart(i * 30)),
    ];
    final one = ok(RangeSelection.tap(base, d[0], d, 2));
    expect(ok(RangeSelection.tap(one, d[3], d, 2)).lengthMinutes, 120);
    expect(fail(RangeSelection.tap(one, d[4], d, 2)), isA<RangeTooLong>());
  });

  test('a slot that cannot be booked is ignored', () {
    final d = day(states: {11: SlotState.past});
    final one = ok(RangeSelection.tap(base, at(d, 10), d, 3));
    expect(ok(RangeSelection.tap(one, at(d, 11), d, 3)), one);
  });

  test('a shared unit accepts a range while every hour has a place', () {
    final d = [
      gridSlot(slotAt(1, 9, remaining: 1, capacity: 6, state: SlotState.fewLeft)),
      gridSlot(slotAt(1, 10, remaining: 5, capacity: 6)),
      gridSlot(slotAt(1, 11, remaining: 2, capacity: 6, state: SlotState.fewLeft)),
    ];
    final one = ok(RangeSelection.tap(base, d[0], d, 3));
    expect(ok(RangeSelection.tap(one, d[2], d, 3)).lengthMinutes, 180);
  });
}

extension on Slot {
  /// The same slot moved [minutes] later.
  Slot copyStart(int minutes) => Slot(
        start: start.add(Duration(minutes: minutes)),
        end: end.add(Duration(minutes: minutes)),
        state: state,
        remaining: remaining,
        capacity: capacity,
      );
}
