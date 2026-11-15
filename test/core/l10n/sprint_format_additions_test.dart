import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/time/cairo_time.dart';

/// Research R13: the ticket and slot time formats.
void main() {
  const ar = SprintFormat('ar');
  const en = SprintFormat('en');
  final arabicIndic = RegExp('[٠-٩۰-۹]');

  setUpAll(() async {
    CairoTime.ensureInitialized();
    await initializeDateFormatting();
  });

  // Cairo wall-clock, as the widgets receive it.
  final start = DateTime(2026, 11, 10, 17);
  final end = DateTime(2026, 11, 10, 18);

  test('timeRange shows the period once when both ends share it', () {
    expect(ar.timeRange(start, end), '5:00 – 6:00 م');
    expect(en.timeRange(start, end), '5:00 – 6:00 PM');
  });

  test('timeRange shows the period on both ends when they differ', () {
    final morning = DateTime(2026, 11, 10, 11);
    final afternoon = DateTime(2026, 11, 10, 13);
    expect(ar.timeRange(morning, afternoon), '11:00 ص – 1:00 م');
    expect(en.timeRange(morning, afternoon), '11:00 AM – 1:00 PM');
  });

  test('dateTimeLine: Arabic and English', () {
    expect(
      ar.dateTimeLine(start, end),
      'التلات 10 نوفمبر · 5:00 – 6:00 م',
    );
    expect(
      en.dateTimeLine(start, end),
      'Tue 10 Nov · 5:00 – 6:00 PM',
    );
  });

  test('dayName short and full in both languages', () {
    expect(ar.dayName(start, short: true), 'التلات');
    expect(ar.dayName(start), 'الثلاثاء');
    expect(en.dayName(start, short: true), 'Tue');
    expect(en.dayName(start), 'Tuesday');
  });

  test('compactCount caps at 99', () {
    expect(ar.compactCount(0), '0');
    expect(ar.compactCount(99), '99');
    expect(ar.compactCount(100), '99+');
    expect(en.compactCount(1250), '99+');
  });

  test('percent rounds to a whole number', () {
    expect(ar.percent(73.4), '73%');
    expect(en.percent(73.6), '74%');
    expect(en.percent(100), '100%');
  });

  test('the additions keep Western digits in both languages', () {
    for (final f in [ar, en]) {
      for (final out in [
        f.timeRange(start, end),
        f.dateTimeLine(start, end),
        f.compactCount(1250),
        f.percent(73.4),
        f.dayName(start, short: true),
        f.dayName(start),
      ]) {
        expect(arabicIndic.hasMatch(out), isFalse, reason: out);
      }
    }
  });
}
