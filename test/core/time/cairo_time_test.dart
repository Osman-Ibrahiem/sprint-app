import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/time/cairo_time.dart';

void main() {
  setUpAll(CairoTime.ensureInitialized);

  test('winter is UTC+2 and summer is UTC+3', () {
    expect(CairoTime.toCairo(DateTime.utc(2026, 1, 15, 10)).hour, 12);
    expect(CairoTime.toCairo(DateTime.utc(2026, 7, 15, 10)).hour, 13);
  });

  test('wall-clock to UTC round-trips', () {
    final utc = CairoTime.atWallClock(2026, 7, 15, 17, 30);
    expect(utc.isUtc, isTrue);
    final back = CairoTime.toCairo(utc);
    expect((back.hour, back.minute), (17, 30));
  });

  group('daylight-saving change days', () {
    // Find the real change days by measuring every day of 2026 against the
    // tz database instead of hard-coding dates, so the test follows the data.
    DateTime? dayOfLength(Duration length) {
      var d = DateTime(2026, 1, 1);
      while (d.year == 2026) {
        final (start, end) = CairoTime.dayBounds(d.year, d.month, d.day);
        if (end.difference(start) == length) return d;
        d = DateTime(d.year, d.month, d.day + 1);
      }
      return null;
    }

    DateTime? transitionDay({required bool forward}) =>
        dayOfLength(Duration(hours: forward ? 23 : 25));

    test('the calendar day is 23 hours long when clocks go forward', () {
      final day = transitionDay(forward: true);
      expect(day, isNotNull, reason: 'Egypt observes DST in 2026');
      final (start, end) = CairoTime.dayBounds(day!.year, day.month, day.day);
      expect(end.difference(start), const Duration(hours: 23));
    });

    test('the calendar day is 25 hours long when clocks go back', () {
      final day = transitionDay(forward: false);
      expect(day, isNotNull);
      final (start, end) = CairoTime.dayBounds(day!.year, day.month, day.day);
      expect(end.difference(start), const Duration(hours: 25));
    });

    test('an 8:00 am slot keeps its wall-clock time across the change', () {
      final day = transitionDay(forward: true)!;
      final before = day.subtract(const Duration(days: 1));
      final slotBefore =
          CairoTime.atWallClock(before.year, before.month, before.day, 8);
      final slotOn = CairoTime.atWallClock(day.year, day.month, day.day, 8);
      // Same wall-clock hour, so the UTC gap is 23h (not 24h).
      expect(slotOn.difference(slotBefore), const Duration(hours: 23));
      expect(CairoTime.toCairo(slotOn).hour, 8);
    });
  });
}
