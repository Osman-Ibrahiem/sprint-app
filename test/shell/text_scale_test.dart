import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/tokens/sprint_text.g.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('no overflow at 200% text on a compact window, every destination',
      (tester) async {
    await pumpSprintApp(tester, size: const Size(320, 640), textScale: 2);
    for (final path in ['/home', '/facilities', '/bookings', '/profile']) {
      routerOf(tester).go(path);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: path);
    }
  });

  testWidgets('no rendered text is below size 12', (tester) async {
    await pumpSprintApp(tester, size: const Size(360, 700));
    for (final path in ['/home', '/facilities', '/bookings', '/profile']) {
      routerOf(tester).go(path);
      await tester.pumpAndSettle();
      for (final element in find.byType(Text).evaluate()) {
        final text = element.widget as Text;
        final style = DefaultTextStyle.of(element).style.merge(text.style);
        expect(
          style.fontSize,
          greaterThanOrEqualTo(12),
          reason: '"${text.data}" on $path',
        );
      }
    }
  });

  test('every type token is at least 12 and carries an explicit height', () {
    for (final s in [
      SprintText.display,
      SprintText.titleLg,
      SprintText.title,
      SprintText.headline,
      SprintText.button,
      SprintText.numberLg,
      SprintText.number,
      SprintText.body,
      SprintText.bodyStrong,
      SprintText.label,
      SprintText.caption,
      SprintText.micro,
      SprintText.code,
    ]) {
      expect(s.fontSize, greaterThanOrEqualTo(12));
      expect(s.height, isNotNull);
    }
  });
}
