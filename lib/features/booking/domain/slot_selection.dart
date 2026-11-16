import 'package:sprint/features/booking/domain/facility_schedule.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';

/// The single-slot path: one bookable slot at a time (FR-014). Pure.
abstract final class SlotSelection {
  /// Selects [tapped], moves the selection to it, or clears it when it is the
  /// selected slot. A slot that cannot be booked changes nothing.
  static ScheduleSelection tap(ScheduleSelection current, ScheduleSlot tapped) {
    if (!tapped.isBookable) return current;
    final same = current.hasTime &&
        current.unitId == tapped.unitId &&
        current.startMinutes == tapped.startMinutes &&
        current.endMinutes == tapped.endMinutes;
    if (same) return current.clearTime();
    return current.withTime(
      unitId: tapped.unitId,
      startMinutes: tapped.startMinutes,
      endMinutes: tapped.endMinutes,
    );
  }
}
