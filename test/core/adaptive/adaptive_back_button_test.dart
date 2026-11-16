import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/adaptive/adaptive_back_button.dart';

Future<void> _pump(WidgetTester t, TextDirection d, TargetPlatform p) =>
    t.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: p),
        home: Directionality(
          textDirection: d,
          child: Scaffold(body: AdaptiveBackButton(onPressed: () {})),
        ),
      ),
    );

void main() {
  for (final p in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('mirrors in RTL and not in LTR on $p', (tester) async {
      await _pump(tester, TextDirection.ltr, p);
      final ltr = tester
          .widgetList<Transform>(
            find.descendant(
              of: find.byType(AdaptiveBackButton),
              matching: find.byType(Transform),
            ),
          )
          .where((t) => t.transform.storage[0] < 0)
          .length;
      await _pump(tester, TextDirection.rtl, p);
      final rtl = tester
          .widgetList<Transform>(
            find.descendant(
              of: find.byType(AdaptiveBackButton),
              matching: find.byType(Transform),
            ),
          )
          .where((t) => t.transform.storage[0] < 0)
          .length;
      expect(ltr, 0);
      expect(rtl, 1);
    });
  }
}
