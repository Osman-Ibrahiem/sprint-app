import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/destinations.dart';
import 'package:sprint/app/router/destinations_provider.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/app/shell/placeholders/no_access_screen.dart';
import 'package:sprint/app/shell/placeholders/not_found_screen.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/features/identity/domain/app_section.dart';

import '../helpers/pump_app.dart';
import '../helpers/sign_in_steps.dart';

/// Deep links to routes that need an account or a section (FR-018,
/// contracts/routes.md rules 1 to 3). `/verification` is a test destination
/// here; the real screen arrives with the verifier work.
void main() {
  final registry = {
    ...baseRegistry,
    AppSection.verification: ShellDestination(
      name: 'verification',
      path: AppPaths.verification,
      icon: Icons.verified_outlined,
      selectedIcon: Icons.verified,
      label: (_) => 'Verification',
      builder: () => const Center(child: Text('screen-verification')),
      access: const RouteAccess(requiredSection: AppSection.verification),
    ),
  };
  final overrides = [destinationRegistryProvider.overrideWithValue(registry)];

  String where(WidgetTester tester) =>
      routerOf(tester).routerDelegate.currentConfiguration.uri.toString();

  testWidgets('a guest deep link goes to sign-in and back after sign in', (
    tester,
  ) async {
    await pumpSprintApp(
      tester,
      size: const Size(1000, 800),
      overrides: overrides,
    );
    routerOf(tester).go(AppPaths.verification);
    await tester.pumpAndSettle();
    expect(where(tester), '/sign-in?from=%2Fverification');
    expect(find.byType(NotFoundScreen), findsNothing);

    await signInWith(
      tester,
      identifier: 'reem@example.test',
      password: SeedIds.demoPassword,
    );
    expect(where(tester), AppPaths.verification);
    expect(find.text('screen-verification'), findsWidgets);
  });

  testWidgets('a booker opening the staff route sees NoAccessScreen in place', (
    tester,
  ) async {
    await pumpSprintApp(tester, overrides: overrides);
    await containerOf(tester)
        .read(sessionProvider.notifier)
        .actAs(SeedIds.bookerInternal);
    await tester.pumpAndSettle();
    routerOf(tester).go(AppPaths.verification);
    await tester.pumpAndSettle();
    expect(where(tester), AppPaths.verification);
    expect(find.byType(NoAccessScreen), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(find.text(ar.noAccessTitle), findsOneWidget);
  });

  testWidgets('an unsafe or unknown from goes to Home after sign in', (
    tester,
  ) async {
    for (final from in [
      'https://evil.example/x',
      '/nowhere',
      '//evil.example',
    ]) {
      await pumpSprintApp(tester, overrides: overrides);
      await openSignIn(tester, from: from);
      await signInWith(
        tester,
        identifier: 'mona@example.test',
        password: SeedIds.demoPassword,
      );
      expect(where(tester), AppPaths.home, reason: from);
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('base tabs never redirect a guest', (tester) async {
    await pumpSprintApp(tester, overrides: overrides);
    for (final p in [
      AppPaths.bookings,
      AppPaths.profile,
      AppPaths.facilities,
    ]) {
      routerOf(tester).go(p);
      await tester.pumpAndSettle();
      expect(where(tester), p);
    }
  });

  testWidgets('a path nobody registered is still not found', (tester) async {
    await pumpSprintApp(tester, overrides: overrides);
    routerOf(tester).go('/nowhere');
    await tester.pumpAndSettle();
    expect(find.byType(NotFoundScreen), findsOneWidget);
  });
}
