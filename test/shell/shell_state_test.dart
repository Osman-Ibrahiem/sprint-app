import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/catalogue/presentation/home/home_screen.dart';

import '../helpers/pump_app.dart';

void main() {
  const widths = <double>[400, 700, 900, 1300];

  testWidgets('destination and scroll offset survive every resize',
      (tester) async {
    await pumpSprintApp(tester, size: const Size(400, 800));

    // The home page is taller than the window, so it scrolls.
    routerOf(tester).go('/home');
    await tester.pumpAndSettle();
    final scroller = find
        .descendant(
          of: find.byType(HomeScreen),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.drag(scroller, const Offset(0, -120));
    await tester.pumpAndSettle();

    double offset() =>
        tester.state<ScrollableState>(scroller).position.pixels;
    final before = offset();
    expect(before, greaterThan(0));

    // Cross every boundary up and down (400 -> 700 -> 900 -> 1300 -> 400).
    for (final w in [...widths.skip(1), widths.first]) {
      tester.view.physicalSize = Size(w, 800);
      await tester.pumpAndSettle();
      expect(currentPath(tester), '/home', reason: 'width $w');
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(offset(), before, reason: 'scroll kept at $w');
    }
  });

  testWidgets('the selected destination stays selected across resizes',
      (tester) async {
    await pumpSprintApp(tester, size: const Size(400, 800));
    routerOf(tester).go('/bookings');
    await tester.pumpAndSettle();

    for (final w in [700.0, 900.0, 1300.0, 400.0]) {
      tester.view.physicalSize = Size(w, 800);
      await tester.pumpAndSettle();
      expect(currentPath(tester), '/bookings', reason: 'width $w');
      expect(find.text(ar.signInPromptTitle), findsOneWidget);
    }
  });
}
