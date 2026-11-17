import 'package:sprint/features/booking/domain/booking_path.dart';
import 'package:sprint/features/booking/domain/facility_schedule.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';

/// The selection to show, and whether something the address carried had to be
/// dropped (so the screen can say the earlier choice is no longer available).
class ResolvedSelection {
  const ResolvedSelection(this.selection, {required this.droppedChoice});

  final ScheduleSelection selection;

  /// True when a day, unit, trainer or time that was asked for is not valid
  /// any more. Filling in a missing value does not count.
  final bool droppedChoice;
}

/// Checks a selection read from the address against the loaded schedule and
/// falls back to the defaults (FR-003, FR-010, FR-012). Pure.
abstract final class SelectionResolver {
  static ResolvedSelection resolve(
    ScheduleSelection asked,
    FacilitySchedule schedule,
  ) {
    var dropped = false;

    // Trainer.
    String? trainerId;
    if (schedule.path == BookingPath.trainer) {
      trainerId = schedule.trainer?.id;
      if (asked.trainerId != null && trainerId != asked.trainerId) {
        dropped = true;
      }
      if (trainerId == null) {
        // The trainer step: only the day is kept, so choosing a trainer keeps
        // it when it is still valid (FR-019).
        return ResolvedSelection(
          ScheduleSelection(day: asked.day),
          droppedChoice: dropped,
        );
      }
    } else if (asked.trainerId != null) {
      dropped = true;
    }

    // Day.
    final askedDay = schedule.day(asked.day);
    final DateTime day;
    if (askedDay != null && !askedDay.isClosed) {
      day = askedDay.date;
    } else {
      if (asked.day != null) dropped = true;
      day = schedule.defaultDay;
    }
    final dayChanged = asked.day == null || askedDay == null || askedDay.isClosed;

    // Unit (the trainer path takes the unit from the session).
    String? unitId;
    var unitChanged = false;
    if (schedule.path != BookingPath.trainer) {
      if (schedule.unit(asked.unitId) != null) {
        unitId = asked.unitId;
      } else {
        if (asked.unitId != null) dropped = true;
        unitId = schedule.defaultUnit(day);
        unitChanged = true;
      }
    }

    var out = ScheduleSelection(day: day, unitId: unitId, trainerId: trainerId);
    if (!asked.hasTime) return ResolvedSelection(out, droppedChoice: dropped);

    // Time: must be a run of bookable slots of that day (and unit).
    if (dayChanged || unitChanged) {
      return ResolvedSelection(out, droppedChoice: true);
    }
    final time = _validTime(asked, out, schedule);
    if (time == null) return ResolvedSelection(out, droppedChoice: true);
    out = time;
    return ResolvedSelection(out, droppedChoice: dropped);
  }

  static ScheduleSelection? _validTime(
    ScheduleSelection asked,
    ScheduleSelection base,
    FacilitySchedule schedule,
  ) {
    final start = asked.startMinutes!;
    final end = asked.endMinutes!;
    final grid = schedule.gridFor(base);

    if (schedule.path == BookingPath.trainer) {
      for (final s in grid) {
        if (s.startMinutes == start && s.endMinutes == end && s.isBookable) {
          if (asked.unitId != null && asked.unitId != s.unitId) return null;
          return base.withTime(
            unitId: s.unitId,
            startMinutes: start,
            endMinutes: end,
          );
        }
      }
      return null;
    }

    final unit = schedule.unit(base.unitId);
    if (unit == null) return null;
    var cursor = start;
    var count = 0;
    while (cursor < end) {
      ScheduleSlot? next;
      for (final s in grid) {
        if (s.startMinutes == cursor) next = s;
      }
      if (next == null || !next.isBookable) return null;
      cursor = next.endMinutes;
      count++;
    }
    if (cursor != end || count == 0) return null;
    if (schedule.path == BookingPath.slot && count != 1) return null;
    if (schedule.path == BookingPath.range &&
        end - start > unit.maxRangeHours * 60) {
      return null;
    }
    return base.withTime(unitId: unit.id, startMinutes: start, endMinutes: end);
  }
}
