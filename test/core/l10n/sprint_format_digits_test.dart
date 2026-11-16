import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Western digits under the app's own localisation delegates, where the plain
/// `ar` date symbols print Arabic-Indic digits (research R5).
void main() {
  final arabicIndic = RegExp('[٠-٩۰-۹]');

  for (final code in ['ar', 'en']) {
    testWidgets('every SprintFormat output keeps Western digits in $code',
        (tester) async {
      CairoTime.ensureInitialized();
      late List<String> out;
      await tester.pumpWidget(MaterialApp(
        locale: Locale(code),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (context) {
          final f = SprintFormat.of(context);
          final start = DateTime(2026, 11, 19, 17);
          final end = DateTime(2026, 11, 19, 18);
          out = [
            f.date(DateTime.utc(2026, 11, 19, 12)),
            f.time(DateTime.utc(2026, 11, 19, 14)),
            f.localTime(start),
            f.timeRange(start, end),
            f.dateTimeLine(start, end),
            f.number(1234567),
            f.price(120),
          ];
          return const SizedBox();
        }),
      ));
      for (final s in out) {
        expect(arabicIndic.hasMatch(s), isFalse, reason: s);
        expect(RegExp('[0-9]').hasMatch(s), isTrue, reason: s);
      }
    });
  }
}
