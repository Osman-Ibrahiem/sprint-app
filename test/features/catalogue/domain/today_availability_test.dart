import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/widgets/facility_card/facility_card_data.dart';
import 'package:sprint/features/booking/domain/slot.dart';
import 'package:sprint/features/catalogue/domain/today_availability.dart';

Slot slot(SlotState state, int remaining) => Slot(
  start: DateTime.utc(2026, 11, 14, 8),
  end: DateTime.utc(2026, 11, 14, 9),
  state: state,
  remaining: remaining,
  capacity: 8,
);

void main() {
  group('TodayAvailability.fromSlots', () {
    test('an empty list is closed today and none', () {
      final today = TodayAvailability.fromSlots(const [], fewLeftThreshold: 2);
      expect(today.closedToday, isTrue);
      expect(today.count, 0);
      expect(today.level, AvailabilityLevel.none);
    });

    test('all past, full or closed counts nothing and is not closed today', () {
      final today = TodayAvailability.fromSlots([
        slot(SlotState.past, 0),
        slot(SlotState.full, 0),
        slot(SlotState.closed, 0),
      ], fewLeftThreshold: 2);
      expect(today.closedToday, isFalse);
      expect(today.count, 0);
      expect(today.level, AvailabilityLevel.none);
    });

    test('exactly the threshold is few', () {
      final today = TodayAvailability.fromSlots([
        slot(SlotState.available, 2),
      ], fewLeftThreshold: 2);
      expect(today.count, 2);
      expect(today.level, AvailabilityLevel.few);
    });

    test('one above the threshold is plenty', () {
      final today = TodayAvailability.fromSlots([
        slot(SlotState.available, 3),
      ], fewLeftThreshold: 2);
      expect(today.count, 3);
      expect(today.level, AvailabilityLevel.plenty);
    });

    test('shared slots with different remaining sum up', () {
      final today = TodayAvailability.fromSlots([
        slot(SlotState.available, 3),
        slot(SlotState.fewLeft, 1),
        slot(SlotState.full, 0),
        slot(SlotState.past, 5),
      ], fewLeftThreshold: 2);
      expect(today.count, 4);
      expect(today.level, AvailabilityLevel.plenty);
    });

    test('a threshold of 0 still makes a booked-out day none', () {
      final none = TodayAvailability.fromSlots(const [], fewLeftThreshold: 0);
      expect(none.level, AvailabilityLevel.none);

      final one = TodayAvailability.fromSlots([
        slot(SlotState.available, 1),
      ], fewLeftThreshold: 0);
      expect(one.count, 1);
      expect(one.level, AvailabilityLevel.plenty);
    });
  });
}
