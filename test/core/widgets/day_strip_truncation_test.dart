import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/widgets/day_strip/day_strip.dart';
import 'package:sprint/core/widgets/day_strip/day_strip_day.dart';

import '../../helpers/no_truncation.dart';
import '../../helpers/widget_harness.dart';

/// Decision T1 of refactor 000 on the DayStrip: every day name in full, never
/// an ellipsis, at 100%, 150% and 200%. The v2 day item (decision 18) fixed
/// the old pill, which cut six of seven names at 150% and 200%.
void main() {
  setUpAll(loadSprintFonts);

  final today = DateTime(2026, 11, 14);
  final week = [
    for (var i = 0; i < 7; i++)
      DayStripDay(date: DateTime(2026, 11, 14 + i), hasAvailability: true),
  ];

  for (final lang in ['ar', 'en']) {
    for (final scale in truncationScales) {
      testWidgets('DayStrip: no day name cut short, $lang x$scale', (
        tester,
      ) async {
        await pumpWidgetUnderAndSettle(
          tester,
          DayStrip(days: week, today: today, onSelected: (_) {}),
          size: const Size(390, 800),
          locale: Locale(lang),
          textScale: scale,
        );
        expectNoTruncation(tester, reason: 'DayStrip $lang x$scale');
        expect(tester.takeException(), isNull);
      });
    }
  }
}
