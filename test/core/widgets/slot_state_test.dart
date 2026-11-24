import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/widgets/slot_chip/slot_state.dart';

/// data-model.md, research R11: the precedence and its boundaries.
void main() {
  SlotState resolve({
    int? remaining,
    int threshold = 2,
    bool past = false,
    bool selected = false,
    bool full = false,
    bool inRange = false,
  }) =>
      resolveSlotState(
        remaining: remaining,
        fewLeftThreshold: threshold,
        isPast: past,
        isSelected: selected,
        isFull: full,
        isInRange: inRange,
      );

  test('precedence past > full > selected > fewLeft > available', () {
    expect(resolve(remaining: 5, past: true, selected: true, full: true),
        SlotState.past);
    expect(resolve(remaining: 0, selected: true), SlotState.full);
    expect(resolve(remaining: 1, selected: true), SlotState.selected);
    expect(resolve(remaining: 1), SlotState.fewLeft);
    expect(resolve(remaining: 4), SlotState.available);
  });

  test('in-range sits below selected and above few-left (decision 3)', () {
    expect(resolve(remaining: 1, selected: true, inRange: true),
        SlotState.selected);
    expect(resolve(remaining: 1, inRange: true), SlotState.inRange);
    expect(resolve(remaining: 0, inRange: true), SlotState.full);
    expect(resolve(remaining: 4, past: true, inRange: true), SlotState.past);
  });

  test('boundaries: 0, threshold, threshold + 1', () {
    expect(resolve(remaining: 0), SlotState.full);
    expect(resolve(remaining: 2), SlotState.fewLeft);
    expect(resolve(remaining: 3), SlotState.available);
  });

  test('an exclusive unit (null remaining) is available unless full or past',
      () {
    expect(resolve(), SlotState.available);
    expect(resolve(full: true), SlotState.full);
    expect(resolve(past: true), SlotState.past);
    expect(resolve(selected: true), SlotState.selected);
  });

  test('a selected chip that becomes full is full', () {
    expect(resolve(remaining: 0, selected: true), SlotState.full);
  });

  test('past wins even while selected', () {
    expect(resolve(remaining: 5, selected: true, past: true), SlotState.past);
  });

  test('the threshold is the setting value, not a constant', () {
    expect(resolve(remaining: 4, threshold: 4), SlotState.fewLeft);
    expect(resolve(remaining: 5, threshold: 4), SlotState.available);
  });
}
