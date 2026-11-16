import 'package:sprint/core/widgets/facility_card/facility_card_data.dart';
import 'package:sprint/features/booking/domain/slot.dart';

/// Today's availability of a facility, in the words the card and the details
/// page use (FR-011, BR-45). Pure: "now" is already applied by the availability
/// repository, which returns past slots as `past`.
class TodayAvailability {
  const TodayAvailability({
    required this.level,
    required this.count,
    required this.closedToday,
  });

  final AvailabilityLevel level;

  /// Places left today over the bookable slots that have not started.
  final int count;

  /// True when the facility (or all its units) has no operating slot today.
  final bool closedToday;

  static const noneToday =
      TodayAvailability(level: AvailabilityLevel.none, count: 0, closedToday: true);

  /// `count` sums `remaining` over slots where [Slot.isBookable]; the level is
  /// `none` at 0, `few` at or below [fewLeftThreshold] (BR-45) and `plenty`
  /// above it. An empty list means the facility is closed today.
  factory TodayAvailability.fromSlots(
    List<Slot> slots, {
    required int fewLeftThreshold,
  }) {
    final count = slots
        .where((s) => s.isBookable)
        .fold<int>(0, (sum, s) => sum + s.remaining);
    final level = count == 0
        ? AvailabilityLevel.none
        : count <= fewLeftThreshold
            ? AvailabilityLevel.few
            : AvailabilityLevel.plenty;
    return TodayAvailability(
      level: level,
      count: count,
      closedToday: slots.isEmpty,
    );
  }
}
