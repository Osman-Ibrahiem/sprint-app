import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/shell/placeholders/home_placeholder.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('/ redirects to /home', (tester) async {
    await pumpSprintApp(tester);
    expect(currentPath(tester), '/home');
    expect(find.byType(HomePlaceholder), findsOneWidget);
  });

  testWidgets('unknown path shows not-found with a way back to Home',
      (tester) async {
    await pumpSprintApp(tester);
    routerOf(tester).go('/nothing');
    await tester.pumpAndSettle();
    expect(find.text(ar.notFoundTitle), findsOneWidget);

    await tester.tap(find.text(ar.backToHome));
    await tester.pumpAndSettle();
    expect(currentPath(tester), '/home');
    expect(find.byType(HomePlaceholder), findsOneWidget);
  });

  for (final path in ['/bookings', '/profile']) {
    testWidgets('guest on $path sees the sign-in placeholder, no redirect',
        (tester) async {
      await pumpSprintApp(tester);
      routerOf(tester).go(path);
      await tester.pumpAndSettle();
      expect(currentPath(tester), path);
      expect(find.text(ar.signInPromptTitle), findsOneWidget);
    });
  }

  testWidgets('the four destinations are reachable in order', (tester) async {
    await pumpSprintApp(tester, size: const Size(400, 800));
    final labels = [ar.navHome, ar.navFacilities, ar.navBookings, ar.navProfile];
    final xs = <double>[for (final l in labels) tester.getCenter(find.text(l)).dx];
    // Arabic RTL: Home is at the start (right) edge, so x decreases.
    expect(xs, orderedEquals(<double>[...xs]..sort((a, b) => b.compareTo(a))));
    await tester.tap(find.text(ar.navProfile));
    await tester.pumpAndSettle();
    expect(currentPath(tester), '/profile');
  });
}
