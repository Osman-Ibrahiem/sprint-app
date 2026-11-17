import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/features/booking/domain/facility_schedule.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';
import 'package:sprint/features/booking/domain/slot.dart';

/// The free-facility path: a run of consecutive slots on one day of one unit,
/// up to `maxRangeHours` (BR-08, FR-015, FR-016). Pure.
abstract final class RangeSelection {
  /// * nothing chosen: [tapped] alone;
  /// * one slot chosen: the range from the earlier to the later of the two
  ///   (the same slot again clears it);
  /// * a longer range chosen: a new one-slot range from [tapped].
  ///
  /// Refuses, naming the hour, when a slot inside is not bookable or missing,
  /// and refuses, stating the maximum, when the range is too long.
  /// [daySlots] are the unit's slots of that day in time order.
  static Result<ScheduleSelection> tap(
    ScheduleSelection current,
    ScheduleSlot tapped,
    List<ScheduleSlot> daySlots,
    int maxRangeHours,
  ) {
    if (!tapped.isBookable) return Ok(current);

    ScheduleSelection single() => current.withTime(
          unitId: tapped.unitId,
          startMinutes: tapped.startMinutes,
          endMinutes: tapped.endMinutes,
        );

    if (!current.hasTime || current.unitId != tapped.unitId) {
      return Ok(single());
    }
    final isOneSlot = daySlots.any(
      (s) =>
          s.startMinutes == current.startMinutes &&
          s.endMinutes == current.endMinutes,
    );
    if (!isOneSlot) return Ok(single());
    if (tapped.startMinutes == current.startMinutes) {
      return Ok(current.clearTime());
    }

    final start = tapped.startMinutes < current.startMinutes!
        ? tapped.startMinutes
        : current.startMinutes!;
    final end = tapped.endMinutes > current.endMinutes!
        ? tapped.endMinutes
        : current.endMinutes!;

    if (end - start > maxRangeHours * 60) {
      return Err(RangeTooLong(maxHours: maxRangeHours));
    }

    // Every slot from start to end must exist, touch the next, and be bookable.
    var cursor = start;
    while (cursor < end) {
      ScheduleSlot? next;
      for (final s in daySlots) {
        if (s.startMinutes == cursor) next = s;
      }
      if (next == null) {
        return Err(ClosedSlot(at: _instant(current, cursor)));
      }
      if (!next.isBookable) return Err(_failureOf(next));
      cursor = next.endMinutes;
    }
    return Ok(current.withTime(
      unitId: tapped.unitId,
      startMinutes: start,
      endMinutes: end,
    ));
  }

  static Failure _failureOf(ScheduleSlot s) => switch (s.slot.state) {
        SlotState.past => SlotPast(at: s.slot.start),
        SlotState.closed => ClosedSlot(at: s.slot.start),
        _ => s.slot.capacity <= 1
            ? SlotTaken(at: s.slot.start)
            : SlotFull(at: s.slot.start),
      };

  static DateTime? _instant(ScheduleSelection selection, int minutes) =>
      ScheduleSelection(day: selection.day, startMinutes: minutes, endMinutes: minutes + 1)
          .startInstant;
}
