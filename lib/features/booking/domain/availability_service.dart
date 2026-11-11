import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/slot.dart';
import 'package:sprint/features/booking/domain/unit_settings.dart';
import 'package:sprint/features/catalogue/domain/bookable_unit.dart';
import 'package:sprint/features/catalogue/domain/closure.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/domain/operating_hours.dart';
import 'package:sprint/features/catalogue/domain/trainer.dart';
import 'package:sprint/features/catalogue/domain/trainer_availability.dart';

/// Computes slots and checks the structure of a booking request (BR-05 –
/// BR-09). Pure: no I/O, "now" is a parameter, every number comes from
/// [UnitSettings]. Capacity conflicts at creation time are the
/// `ConflictChecker`'s job.
///
/// Days are Cairo calendar days, given as `DateTime`s whose year, month and day
/// are read (the time of day is ignored).
class AvailabilityService {
  const AvailabilityService({this.fewLeftThreshold = 2});

  /// A shared slot with this many places or fewer left shows as "few left".
  /// A display hint, not a BRD setting (README: "فاضل مكانين").
  final int fewLeftThreshold;

  List<Slot> slots({
    required Facility facility,
    required BookableUnit unit,
    required List<OperatingHours> hours,
    required List<Closure> closures,
    required List<Booking> bookings,
    required UnitSettings settings,
    required DateTime now,
    required DateTime fromDay,
    required DateTime toDay,
    Trainer? trainer,
    List<TrainerAvailability> trainerAvailability = const [],
  }) {
    final windowEnd = _windowEnd(settings, now);
    final length = facility.requiresTrainer
        ? settings.sessionMinutes
        : settings.slotGranularityMinutes;
    final lead = Duration(minutes: settings.minLeadMinutes);

    final out = <Slot>[];
    var day = DateTime(fromDay.year, fromDay.month, fromDay.day);
    final last = DateTime(toDay.year, toDay.month, toDay.day);
    while (!day.isAfter(last)) {
      for (final (open, close) in _intervals(
        facility: facility,
        unit: unit,
        hours: hours,
        day: day,
        trainer: trainer,
        trainerAvailability: trainerAvailability,
      )) {
        for (var t = open; t + length <= close; t += length) {
          final start = _at(day, t);
          final end = _at(day, t + length);
          if (!start.isBefore(windowEnd)) continue;
          if (_closed(closures, facility.id, unit.id, start, end)) continue;
          out.add(_slot(
            start: start,
            end: end,
            unit: unit,
            bookings: bookings,
            settings: settings,
            now: now,
            lead: lead,
            trainer: trainer,
          ));
        }
      }
      day = DateTime(day.year, day.month, day.day + 1);
    }
    return out;
  }

  /// Whether [start]..[end] is one valid request: inside the window, not past,
  /// on the slot grid, within opening hours and closures, and no longer than
  /// allowed. Returns null when it is.
  Failure? checkRequest({
    required Facility facility,
    required BookableUnit unit,
    required List<OperatingHours> hours,
    required List<Closure> closures,
    required UnitSettings settings,
    required DateTime now,
    required DateTime start,
    required DateTime end,
    Trainer? trainer,
    List<TrainerAvailability> trainerAvailability = const [],
  }) {
    if (!start.isBefore(_windowEnd(settings, now))) {
      return const OutsideWindow();
    }
    final lead = Duration(minutes: settings.minLeadMinutes);
    if (!start.isAfter(now.add(lead))) return const SlotPast();
    if (!unit.isActive) return const ClosedSlot();

    final first = CairoTime.toCairo(start);
    final lastMoment = CairoTime.toCairo(end.subtract(const Duration(minutes: 1)));
    final grid = slots(
      facility: facility,
      unit: unit,
      hours: hours,
      closures: closures,
      bookings: const [],
      settings: settings,
      now: now,
      fromDay: DateTime(first.year, first.month, first.day),
      toDay: DateTime(lastMoment.year, lastMoment.month, lastMoment.day),
      trainer: trainer,
      trainerAvailability: trainerAvailability,
    );

    // The request must be an exact run of consecutive slots.
    var cursor = start;
    var count = 0;
    while (cursor.isBefore(end)) {
      Slot? next;
      for (final s in grid) {
        if (s.start == cursor) next = s;
      }
      if (next == null) return const ClosedSlot();
      cursor = next.end;
      count++;
    }
    if (cursor != end) return const ClosedSlot();

    final single = !facility.isFree || facility.requiresTrainer;
    if (single && count > 1) return const RangeTooLong();
    if (!single &&
        end.difference(start) > Duration(hours: settings.maxRangeHours)) {
      return const RangeTooLong();
    }
    return null;
  }

  // ---------------------------------------------------------------- helpers

  /// The first instant that is no longer bookable: the start of the Cairo day
  /// after the last allowed day (today counts as the first of the window).
  DateTime _windowEnd(UnitSettings s, DateTime now) {
    final today = CairoTime.toCairo(now);
    return CairoTime.atWallClock(
      today.year,
      today.month,
      today.day + s.bookingWindowDays,
    );
  }

  DateTime _at(DateTime day, int minutes) => CairoTime.atWallClock(
        day.year,
        day.month,
        day.day,
        minutes ~/ 60,
        minutes % 60,
      );

  /// (open, close) minute pairs for [day]. Unit hours replace facility hours;
  /// trainer sessions are limited to the trainer's availability.
  List<(int, int)> _intervals({
    required Facility facility,
    required BookableUnit unit,
    required List<OperatingHours> hours,
    required DateTime day,
    Trainer? trainer,
    required List<TrainerAvailability> trainerAvailability,
  }) {
    final weekday = day.weekday;
    final unitHours = hours.where((h) => h.ownerId == unit.id).toList();
    final source = unitHours.isNotEmpty
        ? unitHours
        : hours.where((h) => h.ownerId == facility.id).toList();
    final open = [
      for (final h in source)
        if (h.dayOfWeek == weekday) (h.openMinutes, h.closeMinutes),
    ];
    if (!facility.requiresTrainer || trainer == null) return open;

    final windows = [
      for (final a in trainerAvailability)
        if (a.trainerId == trainer.id &&
            a.unitId == unit.id &&
            a.dayOfWeek == weekday)
          (a.fromMinutes, a.toMinutes),
    ];
    final clipped = <(int, int)>[];
    for (final (wFrom, wTo) in windows) {
      for (final (oFrom, oTo) in open) {
        final from = wFrom > oFrom ? wFrom : oFrom;
        final to = wTo < oTo ? wTo : oTo;
        if (from < to) clipped.add((from, to));
      }
    }
    return clipped;
  }

  bool _closed(
    List<Closure> closures,
    String facilityId,
    String unitId,
    DateTime start,
    DateTime end,
  ) {
    for (final c in closures) {
      final applies = switch (c.scope) {
        ClosureScope.facility => c.scopeId == facilityId,
        ClosureScope.unit => c.scopeId == unitId,
      };
      if (applies && c.from.isBefore(end) && start.isBefore(c.to)) return true;
    }
    return false;
  }

  Slot _slot({
    required DateTime start,
    required DateTime end,
    required BookableUnit unit,
    required List<Booking> bookings,
    required UnitSettings settings,
    required DateTime now,
    required Duration lead,
    Trainer? trainer,
  }) {
    final unitCap =
        settings.bookingMode == BookingMode.exclusive ? 1 : settings.capacity;
    final capacity = trainer != null && trainer.trainerCapacity < unitCap
        ? trainer.trainerCapacity
        : unitCap;

    var unitTaken = 0;
    var trainerTaken = 0;
    for (final b in bookings) {
      if (b.unitId != unit.id || !b.holdsPlace(now)) continue;
      if (!b.overlaps(start, end)) continue;
      unitTaken += b.seats;
      if (trainer != null && b.trainerId == trainer.id) trainerTaken += b.seats;
    }
    var remaining = unitCap - unitTaken;
    if (trainer != null) {
      final byTrainer = trainer.trainerCapacity - trainerTaken;
      if (byTrainer < remaining) remaining = byTrainer;
    }
    if (remaining < 0) remaining = 0;

    final SlotState state;
    if (!unit.isActive) {
      state = SlotState.closed;
    } else if (!start.isAfter(now.add(lead))) {
      state = SlotState.past;
    } else if (remaining == 0) {
      state = SlotState.full;
    } else if (capacity > 1 && remaining <= fewLeftThreshold) {
      state = SlotState.fewLeft;
    } else {
      state = SlotState.available;
    }
    final bookable = state == SlotState.available || state == SlotState.fewLeft;
    return Slot(
      start: start,
      end: end,
      state: state,
      remaining: bookable || state == SlotState.full ? remaining : 0,
      capacity: capacity,
    );
  }
}
