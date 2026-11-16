import 'package:sprint/features/booking/domain/booking_path.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';
import 'package:sprint/features/booking/domain/slot.dart';
import 'package:sprint/features/booking/domain/unit_settings.dart';
import 'package:sprint/features/catalogue/domain/bookable_unit.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/domain/price.dart';

/// One day of the booking window on the day strip (FR-002 – FR-004).
class ScheduleDay {
  const ScheduleDay({
    required this.date,
    required this.hasAvailability,
    required this.isClosed,
  });

  /// Cairo date only.
  final DateTime date;

  /// Some unit has a bookable slot that day.
  final bool hasAvailability;

  /// No unit has any slot that day (closure or no operating hours, BR-05).
  final bool isClosed;
}

/// One bookable unit with the settings its slots follow, already resolved
/// unit -> facility -> university (constitution III).
class ScheduleUnit {
  const ScheduleUnit({
    required this.id,
    required this.name,
    required this.mode,
    required this.capacity,
    required this.maxParticipants,
    required this.fewLeftThreshold,
    required this.maxRangeHours,
    required this.granularityMinutes,
    required this.sessionMinutes,
    required this.priceInternal,
    required this.priceExternal,
  });

  final String id;
  final String name;
  final BookingMode mode;
  final int capacity;
  final int? maxParticipants;
  final int fewLeftThreshold;
  final int maxRangeHours;
  final int granularityMinutes;
  final int sessionMinutes;

  /// Whole EGP per slot (exclusive) or per place (shared); null when not set.
  final int? priceInternal;
  final int? priceExternal;

  bool get isShared => mode == BookingMode.shared;

  int? priceFor(PriceTier tier) =>
      tier == PriceTier.internal ? priceInternal : priceExternal;
}

/// A trainer on the trainer step (FR-017).
class ScheduleTrainer {
  const ScheduleTrainer({
    required this.id,
    required this.name,
    required this.bio,
    required this.capacity,
    required this.hasSessionsInWindow,
  });

  final String id;

  /// Null when the trainer's profile has no name.
  final String? name;
  final String bio;
  final int capacity;
  final bool hasSessionsInWindow;
}

/// A slot as the grid draws it: the slot and the unit it belongs to.
class ScheduleSlot {
  const ScheduleSlot({
    required this.unitId,
    required this.unitName,
    required this.slot,
  });

  final String unitId;
  final String unitName;
  final Slot slot;

  int get startMinutes => cairoMinutesOf(slot.start);

  /// Minutes since the start day's midnight; past 1440 when it crosses it.
  int get endMinutes =>
      startMinutes + slot.end.difference(slot.start).inMinutes;

  bool get isBookable => slot.isBookable;
}

/// Everything the schedule screen shows for one facility over the booking
/// window, built once per load (feature 005 research R4). Never stored.
class FacilitySchedule {
  const FacilitySchedule({
    required this.facility,
    required this.path,
    required this.today,
    required this.days,
    required this.units,
    required this.trainers,
    required this.trainer,
    required this.slotsByUnitAndDay,
  });

  final Facility facility;
  final BookingPath path;

  /// Cairo date only.
  final DateTime today;
  final List<ScheduleDay> days;

  /// Active units in catalogue order. In the trainer path with a trainer
  /// chosen: only the units that trainer has sessions in.
  final List<ScheduleUnit> units;

  /// Trainer path only.
  final List<ScheduleTrainer> trainers;

  /// The chosen trainer, when there is one.
  final ScheduleTrainer? trainer;

  /// unit id -> Cairo day -> slots in time order.
  final Map<String, Map<DateTime, List<Slot>>> slotsByUnitAndDay;

  /// The trainer path before a trainer is chosen: only the trainer list shows.
  bool get needsTrainer => path == BookingPath.trainer && trainer == null;

  ScheduleUnit? unit(String? id) {
    for (final u in units) {
      if (u.id == id) return u;
    }
    return null;
  }

  ScheduleDay? day(DateTime? date) {
    if (date == null) return null;
    for (final d in days) {
      if (_sameDay(d.date, date)) return d;
    }
    return null;
  }

  List<Slot> slotsFor(String unitId, DateTime day) =>
      slotsByUnitAndDay[unitId]?[DateTime(day.year, day.month, day.day)] ?? const [];

  bool unitHasPlacesOn(String unitId, DateTime day) =>
      slotsFor(unitId, day).any((s) => s.isBookable);

  /// The chosen trainer's sessions on [day] across their units, by start
  /// time. Equal starts keep the first bookable in catalogue order.
  List<ScheduleSlot> sessionsOn(DateTime day) {
    final byStart = <DateTime, ScheduleSlot>{};
    for (final u in units) {
      for (final s in slotsFor(u.id, day)) {
        final existing = byStart[s.start];
        if (existing == null || (!existing.isBookable && s.isBookable)) {
          byStart[s.start] =
              ScheduleSlot(unitId: u.id, unitName: u.name, slot: s);
        }
      }
    }
    final out = byStart.values.toList()
      ..sort((a, b) => a.slot.start.compareTo(b.slot.start));
    return out;
  }

  /// What the grid draws for [selection]: the trainer's sessions in the
  /// trainer path, the selected unit's slots otherwise.
  List<ScheduleSlot> gridFor(ScheduleSelection selection) {
    final d = selection.day;
    if (d == null) return const [];
    if (path == BookingPath.trainer) return sessionsOn(d);
    final u = unit(selection.unitId);
    if (u == null) return const [];
    return [
      for (final s in slotsFor(u.id, d))
        ScheduleSlot(unitId: u.id, unitName: u.name, slot: s),
    ];
  }

  /// First day with availability, else the first day that is not closed, else
  /// today (FR-003).
  DateTime get defaultDay {
    for (final d in days) {
      if (d.hasAvailability) return d.date;
    }
    for (final d in days) {
      if (!d.isClosed) return d.date;
    }
    return today;
  }

  /// First unit with places on [day], else the first unit, else null.
  String? defaultUnit(DateTime day) {
    for (final u in units) {
      if (unitHasPlacesOn(u.id, day)) return u.id;
    }
    return units.isEmpty ? null : units.first.id;
  }

  /// The start of the next slot after [now], for the "past" timer.
  DateTime? nextSlotStartAfter(DateTime now) {
    DateTime? next;
    for (final byDay in slotsByUnitAndDay.values) {
      for (final list in byDay.values) {
        for (final s in list) {
          if (s.start.isAfter(now) && (next == null || s.start.isBefore(next))) {
            next = s.start;
          }
        }
      }
    }
    return next;
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Builds a [FacilitySchedule] from what the repositories returned. Pure.
abstract final class ScheduleBuilder {
  static FacilitySchedule build({
    required Facility facility,

    /// Active units, in catalogue order.
    required List<BookableUnit> units,
    required Map<String, UnitSettings> settingsByUnit,
    required Map<String, int> fewLeftByUnit,

    /// Every generated slot of each unit over the window.
    required Map<String, List<Slot>> slotsByUnit,
    required Map<String, List<Price>> pricesByUnit,

    /// Days to show when there is no unit to take a window from.
    required int fallbackWindowDays,
    List<ScheduleTrainer> trainers = const [],
    ScheduleTrainer? trainer,
    required DateTime now,
  }) {
    final path = BookingPath.of(facility);
    final today = cairoDayOf(now);

    var windowDays = 0;
    for (final u in units) {
      final w = settingsByUnit[u.id]?.bookingWindowDays ?? 0;
      if (w > windowDays) windowDays = w;
    }
    if (windowDays <= 0) windowDays = fallbackWindowDays;

    // unit -> day -> slots.
    final grouped = <String, Map<DateTime, List<Slot>>>{};
    for (final u in units) {
      final byDay = <DateTime, List<Slot>>{};
      final list = [...?slotsByUnit[u.id]]
        ..sort((a, b) => a.start.compareTo(b.start));
      for (final s in list) {
        if (s.state == SlotState.closed) continue; // never drawn
        byDay.putIfAbsent(cairoDayOf(s.start), () => []).add(s);
      }
      grouped[u.id] = byDay;
    }

    // With a trainer chosen, only the units that trainer has sessions in.
    final shown = path == BookingPath.trainer && trainer != null
        ? units.where((u) => grouped[u.id]!.isNotEmpty).toList()
        : units;

    final scheduleUnits = [
      for (final u in shown)
        if (settingsByUnit[u.id] case final cfg?)
          ScheduleUnit(
            id: u.id,
            name: u.name,
            mode: cfg.bookingMode,
            capacity: cfg.capacity,
            maxParticipants: cfg.maxParticipants,
            fewLeftThreshold: fewLeftByUnit[u.id] ?? 0,
            maxRangeHours: cfg.maxRangeHours,
            granularityMinutes: cfg.slotGranularityMinutes,
            sessionMinutes: cfg.sessionMinutes,
            priceInternal: _price(pricesByUnit[u.id], PriceTier.internal),
            priceExternal: _price(pricesByUnit[u.id], PriceTier.external),
          ),
    ];

    final days = <ScheduleDay>[];
    for (var i = 0; i < windowDays; i++) {
      final date = DateTime(today.year, today.month, today.day + i);
      var any = false;
      var bookable = false;
      for (final u in scheduleUnits) {
        final list = grouped[u.id]?[date] ?? const <Slot>[];
        if (list.isNotEmpty) any = true;
        if (list.any((s) => s.isBookable)) bookable = true;
      }
      days.add(ScheduleDay(
        date: date,
        hasAvailability: bookable,
        isClosed: !any,
      ));
    }

    return FacilitySchedule(
      facility: facility,
      path: path,
      today: today,
      days: days,
      units: scheduleUnits,
      trainers: trainers,
      trainer: trainer,
      slotsByUnitAndDay: {for (final u in scheduleUnits) u.id: grouped[u.id]!},
    );
  }

  static int? _price(List<Price>? prices, PriceTier tier) {
    for (final p in prices ?? const <Price>[]) {
      if (p.tier == tier) return p.amount;
    }
    return null;
  }
}
