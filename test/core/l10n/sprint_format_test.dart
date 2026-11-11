import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/time/cairo_time.dart';

void main() {
  const ar = SprintFormat('ar');
  const en = SprintFormat('en');
  final arabicIndic = RegExp('[٠-٩۰-۹]');

  setUpAll(() async {
    CairoTime.ensureInitialized();
    await initializeDateFormatting();
  });

  test('price: "120 ج.م" in Arabic and "EGP 120" in English', () {
    expect(ar.price(120), '120 ج.م');
    expect(en.price(120), 'EGP 120');
    expect(ar.price(1234), '1,234 ج.م');
    expect(en.price(0), 'EGP 0');
  });

  test('time: 12-hour in Cairo time (ص/م and AM/PM)', () {
    // 15:00 UTC in January is 17:00 in Cairo (UTC+2).
    final winter = DateTime.utc(2026, 1, 15, 15);
    expect(ar.time(winter), '5:00 م');
    expect(en.time(winter), '5:00 PM');
    // The same UTC instant in July is 18:00 in Cairo (UTC+3).
    final summer = DateTime.utc(2026, 7, 15, 15);
    expect(en.time(summer), '6:00 PM');
    expect(ar.time(DateTime.utc(2026, 1, 15, 6)), '8:00 ص');
  });

  test('date: weekday, day and month', () {
    final d = DateTime.utc(2026, 11, 14, 10); // a Saturday in Cairo
    expect(ar.date(d), 'السبت 14 نوفمبر');
    expect(en.date(d), 'Sat, 14 Nov');
  });

  test('a late-evening UTC instant lands on the next Cairo day', () {
    final d = DateTime.utc(2026, 11, 13, 23, 30);
    expect(en.date(d), 'Sat, 14 Nov');
  });

  test('digits are Western (0-9) in every output, in both languages', () {
    final instant = DateTime.utc(2026, 11, 14, 15, 5);
    for (final f in [ar, en]) {
      for (final out in [
        f.price(1234567),
        f.time(instant),
        f.date(instant),
        f.number(9876.5),
        f.number(0),
      ]) {
        expect(arabicIndic.hasMatch(out), isFalse, reason: out);
        expect(RegExp(r'[0-9]').hasMatch(out), isTrue, reason: out);
      }
    }
  });

  test('unknown language codes fall back to Arabic', () {
    expect(const SprintFormat('fr').price(5), '5 ج.م');
  });
}
