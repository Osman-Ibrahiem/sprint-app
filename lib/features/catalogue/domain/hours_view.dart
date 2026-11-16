import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/features/catalogue/domain/closure.dart';
import 'package:sprint/features/catalogue/domain/operating_hours.dart';

/// One weekday's opening times in Cairo minutes from midnight; null times mean
/// closed that day.
class DayHours {
  const DayHours({
    required this.dayOfWeek,
    this.openMinutes,
    this.closeMinutes,
  });

  final int dayOfWeek;
  final int? openMinutes;
  final int? closeMinutes;

  bool get isClosed => openMinutes == null || closeMinutes == null;

  @override
  bool operator ==(Object other) =>
      other is DayHours &&
      other.dayOfWeek == dayOfWeek &&
      other.openMinutes == openMinutes &&
      other.closeMinutes == closeMinutes;

  @override
  int get hashCode => Object.hash(dayOfWeek, openMinutes, closeMinutes);
}

/// A facility's weekly hours with today marked, whether it is closed right now
/// and the units whose hours differ (FR-015, FR-016, FR-021, BR-05).
class HoursView {
  const HoursView({
    required this.days,
    required this.todayDayOfWeek,
    required this.closedNow,
    required this.unitOverrides,
  });

  final List<DayHours> days;
  final int todayDayOfWeek;
  final bool closedNow;
  final Map<String, List<DayHours>> unitOverrides;

  /// [allUnitIds] lets a set of unit closures that covers every unit count as
  /// the facility being closed.
  factory HoursView.build({
    required List<OperatingHours> facilityHours,
    required Map<String, List<OperatingHours>> unitHours,
    required List<Closure> closures,
    required DateTime now,
    List<String> allUnitIds = const [],
  }) {
    final days = _week(facilityHours);
    final overrides = <String, List<DayHours>>{};
    for (final entry in unitHours.entries) {
      final week = _week(entry.value);
      if (!_sameWeek(week, days)) overrides[entry.key] = week;
    }

    final cairo = CairoTime.toCairo(now);
    final today = cairo.weekday;
    final minutes = cairo.hour * 60 + cairo.minute;
    final todayHours = days.firstWhere((d) => d.dayOfWeek == today);
    final outsideHours =
        todayHours.isClosed ||
        minutes < todayHours.openMinutes! ||
        minutes >= todayHours.closeMinutes!;

    bool active(Closure c) => !now.isBefore(c.from) && now.isBefore(c.to);
    final facilityClosed = closures.any(
      (c) => c.scope == ClosureScope.facility && active(c),
    );
    final closedUnits = {
      for (final c in closures)
        if (c.scope == ClosureScope.unit && active(c)) c.scopeId,
    };
    final allUnitsClosed =
        allUnitIds.isNotEmpty && allUnitIds.every(closedUnits.contains);

    return HoursView(
      days: days,
      todayDayOfWeek: today,
      closedNow: facilityClosed || allUnitsClosed || outsideHours,
      unitOverrides: overrides,
    );
  }

  static List<DayHours> _week(List<OperatingHours> hours) => [
    for (var day = 1; day <= 7; day++)
      () {
        final match = hours.where((h) => h.dayOfWeek == day).firstOrNull;
        return DayHours(
          dayOfWeek: day,
          openMinutes: match?.openMinutes,
          closeMinutes: match?.closeMinutes,
        );
      }(),
  ];

  static bool _sameWeek(List<DayHours> a, List<DayHours> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
