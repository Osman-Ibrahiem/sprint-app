import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';
import 'package:sprint/features/booking/domain/slot.dart';
import 'package:sprint/features/booking/domain/slot_selection.dart';

import 'schedule_fixtures.dart';

void main() {
  final base = ScheduleSelection(day: dayPlus(1), unitId: 'u1');
  final nine = gridSlot(slotAt(1, 9));
  final ten = gridSlot(slotAt(1, 10));

  test('selects a bookable slot (FR-014)', () {
    final s = SlotSelection.tap(base, nine);
    expect((s.unitId, s.startMinutes, s.endMinutes), ('u1', 540, 600));
    expect(s.day, base.day);
  });

  test('another slot moves the selection', () {
    final s = SlotSelection.tap(SlotSelection.tap(base, nine), ten);
    expect(s.startMinutes, 600);
  });

  test('the selected slot again clears it', () {
    final s = SlotSelection.tap(SlotSelection.tap(base, nine), nine);
    expect(s.hasTime, isFalse);
  });

  test('full and past slots change nothing', () {
    final chosen = SlotSelection.tap(base, nine);
    for (final state in [SlotState.full, SlotState.past]) {
      expect(SlotSelection.tap(chosen, gridSlot(slotAt(1, 11, state: state))), chosen);
    }
  });

  test('a session sets its own unit', () {
    final s = SlotSelection.tap(base, gridSlot(slotAt(1, 9), unitId: 'u2'));
    expect(s.unitId, 'u2');
  });
}
