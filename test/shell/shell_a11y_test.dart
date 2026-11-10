import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/shell/nav/sprint_nav_rail.dart';
import 'package:sprint/app/shell/nav/sprint_sidebar.dart';
import 'package:sprint/app/shell/nav/sprint_tab_bar.dart';

import '../helpers/pump_app.dart';

void main() {
  final labels = [ar.navHome, ar.navFacilities, ar.navBookings, ar.navProfile];

  final forms = <Size, Type>{
    const Size(400, 800): SprintTabBar,
    const Size(700, 800): SprintNavRail,
    const Size(1000, 800): SprintSidebar,
  };
  for (final MapEntry(key: size, value: form) in forms.entries) {
    testWidgets('destinations have spoken labels and 48dp targets at $size',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpSprintApp(tester, size: size);
      for (final label in labels) {
        final finder = find.descendant(
          of: find.byType(form),
          matching: find.bySemanticsLabel(label),
        );
        expect(finder, findsWidgets, reason: label);
        final node = tester.getSemantics(finder.first);
        expect(node.rect.size.width, greaterThanOrEqualTo(48), reason: label);
        expect(node.rect.size.height, greaterThanOrEqualTo(48), reason: label);
      }
      handle.dispose();
    });
  }

  testWidgets('keyboard focus shows a visible focus ring', (tester) async {
    await pumpSprintApp(tester, size: const Size(1000, 800));
    expect(find.byKey(const ValueKey('focus-ring-visible')), findsNothing);
    // Keyboard platforms use traditional highlights. (Tab reaching the nav
    // from an empty page is checked by hand on web, see tasks T030.)
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(
      () => FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic,
    );
    final item = find
        .descendant(
          of: find.byType(SprintSidebar),
          matching: find.byType(GestureDetector),
        )
        .first;
    Focus.of(tester.element(item)).requestFocus();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('focus-ring-visible')), findsOneWidget);
  });

  testWidgets('labels survive 200% text scale at compact width',
      (tester) async {
    final handle = tester.ensureSemantics();
    await pumpSprintApp(tester, size: const Size(320, 640), textScale: 2);
    expect(tester.takeException(), isNull);
    for (final label in labels) {
      expect(find.bySemanticsLabel(label), findsWidgets, reason: label);
    }
    handle.dispose();
  });
}
