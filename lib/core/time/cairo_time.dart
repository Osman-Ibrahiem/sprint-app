import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Cairo wall-clock handling on top of UTC storage (NFR-03, research R13).
///
/// Domain code stores UTC `DateTime`s; this class converts for display and for
/// building slot boundaries, so a daylight-saving change never shifts a slot.
abstract final class CairoTime {
  static bool _initialised = false;

  /// Loads the time zone database once.
  static void ensureInitialized() {
    if (_initialised) return;
    tzdata.initializeTimeZones();
    _initialised = true;
  }

  static tz.Location get _cairo {
    ensureInitialized();
    return tz.getLocation('Africa/Cairo');
  }

  /// Converts an instant to Cairo wall-clock time.
  static tz.TZDateTime toCairo(DateTime instant) =>
      tz.TZDateTime.from(instant.toUtc(), _cairo);

  /// The UTC instant of a Cairo wall-clock moment.
  static DateTime atWallClock(
    int year,
    int month,
    int day, [
    int hour = 0,
    int minute = 0,
  ]) =>
      tz.TZDateTime(_cairo, year, month, day, hour, minute).toUtc();

  /// UTC start (inclusive) and end (exclusive) of a Cairo calendar day.
  static (DateTime, DateTime) dayBounds(int year, int month, int day) => (
        atWallClock(year, month, day),
        atWallClock(year, month, day + 1),
      );

  /// The Cairo calendar day (midnight, as a Cairo date) of an instant.
  static tz.TZDateTime startOfDay(DateTime instant) {
    final c = toCairo(instant);
    return tz.TZDateTime(_cairo, c.year, c.month, c.day);
  }
}
