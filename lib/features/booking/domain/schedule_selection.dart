import 'package:sprint/core/time/cairo_time.dart';

/// Minutes since Cairo midnight of the Cairo day [instant] falls on.
int cairoMinutesOf(DateTime instant) {
  final c = CairoTime.toCairo(instant);
  return c.hour * 60 + c.minute;
}

/// The Cairo calendar day of [instant], as a date-only `DateTime`.
DateTime cairoDayOf(DateTime instant) {
  final c = CairoTime.toCairo(instant);
  return DateTime(c.year, c.month, c.day);
}

/// What the person has chosen on the schedule: the state the address carries
/// (feature 005 research R2, FR-012). Days are Cairo dates; times are Cairo
/// wall-clock minutes since midnight. Never stored anywhere else.
class ScheduleSelection {
  const ScheduleSelection({
    this.day,
    this.unitId,
    this.trainerId,
    this.startMinutes,
    this.endMinutes,
  });

  static const empty = ScheduleSelection();

  /// Reads the query parameters, dropping anything it cannot parse, a start
  /// without an end, and an end that is not after its start.
  factory ScheduleSelection.fromQuery(Map<String, String> query) {
    String? text(String key) {
      final v = query[key];
      return v == null || v.isEmpty ? null : v;
    }

    var start = _parseTime(query['start']);
    var end = _parseTime(query['end']);
    if (start == null || end == null || end <= start) {
      start = null;
      end = null;
    }
    return ScheduleSelection(
      day: _parseDay(query['day']),
      unitId: text('unit'),
      trainerId: text('trainer'),
      startMinutes: start,
      endMinutes: end,
    );
  }

  /// Date only (year, month, day), in Cairo.
  final DateTime? day;
  final String? unitId;
  final String? trainerId;
  final int? startMinutes;
  final int? endMinutes;

  bool get hasTime => startMinutes != null && endMinutes != null;

  /// Whether a booking request can be built from it.
  bool get isComplete => day != null && unitId != null && hasTime;

  int? get lengthMinutes => hasTime ? endMinutes! - startMinutes! : null;

  /// The chosen start as a UTC instant.
  DateTime? get startInstant => _instant(startMinutes);

  /// The chosen end as a UTC instant.
  DateTime? get endInstant => _instant(endMinutes);

  DateTime? _instant(int? minutes) {
    final d = day;
    if (d == null || minutes == null) return null;
    return CairoTime.atWallClock(d.year, d.month, d.day, minutes ~/ 60, minutes % 60);
  }

  /// Only what is set, in a fixed key order.
  Map<String, String> toQuery() => {
        if (day != null) 'day': _formatDay(day!),
        'unit': ?unitId,
        'trainer': ?trainerId,
        if (hasTime) 'start': _formatTime(startMinutes!),
        if (hasTime) 'end': _formatTime(endMinutes!),
      };

  ScheduleSelection clearTime() =>
      ScheduleSelection(day: day, unitId: unitId, trainerId: trainerId);

  /// A new day keeps the unit and the trainer and clears the time (FR-019).
  ScheduleSelection withDay(DateTime newDay) => ScheduleSelection(
        day: DateTime(newDay.year, newDay.month, newDay.day),
        unitId: unitId,
        trainerId: trainerId,
      );

  /// A new unit clears the time.
  ScheduleSelection withUnit(String? newUnitId) =>
      ScheduleSelection(day: day, unitId: newUnitId, trainerId: trainerId);

  /// A new trainer clears the time and the unit; the day is kept.
  ScheduleSelection withTrainer(String? newTrainerId) =>
      ScheduleSelection(day: day, trainerId: newTrainerId);

  ScheduleSelection withTime({
    required String unitId,
    required int startMinutes,
    required int endMinutes,
  }) =>
      ScheduleSelection(
        day: day,
        unitId: unitId,
        trainerId: trainerId,
        startMinutes: startMinutes,
        endMinutes: endMinutes,
      );

  static DateTime? _parseDay(String? raw) {
    if (raw == null) return null;
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(raw);
    if (m == null) return null;
    final y = int.parse(m.group(1)!);
    final mo = int.parse(m.group(2)!);
    final d = int.parse(m.group(3)!);
    final date = DateTime(y, mo, d);
    // Reject overflow such as 2026-02-31.
    if (date.year != y || date.month != mo || date.day != d) return null;
    return date;
  }

  static int? _parseTime(String? raw) {
    if (raw == null || !RegExp(r'^\d{4}$').hasMatch(raw)) return null;
    final h = int.parse(raw.substring(0, 2));
    final m = int.parse(raw.substring(2));
    if (h > 24 || m > 59 || (h == 24 && m != 0)) return null;
    return h * 60 + m;
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
  static String _formatDay(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${_two(d.month)}-${_two(d.day)}';
  static String _formatTime(int minutes) =>
      '${_two(minutes ~/ 60)}${_two(minutes % 60)}';

  @override
  bool operator ==(Object other) =>
      other is ScheduleSelection &&
      other.day == day &&
      other.unitId == unitId &&
      other.trainerId == trainerId &&
      other.startMinutes == startMinutes &&
      other.endMinutes == endMinutes;

  @override
  int get hashCode =>
      Object.hash(day, unitId, trainerId, startMinutes, endMinutes);

  @override
  String toString() => 'ScheduleSelection(${toQuery()})';
}
