import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/destinations.dart';
import 'package:sprint/app/router/destinations_provider.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/app/shell/placeholders/not_found_screen.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/features/auth/presentation/account_card.dart';
import 'package:sprint/features/identity/domain/app_section.dart';

import '../helpers/pump_app.dart';
import '../helpers/sign_in_steps.dart';

/// The shell follows the session: sections by role after a real sign in, and
/// the staff ones go away at sign out (FR-016, FR-017, FR-AUTH-04).
void main() {
  ShellDestination stub(AppSection s, String name, String path) =>
      ShellDestination(
        name: name,
        path: path,
        icon: Icons.verified_outlined,
        selectedIcon: Icons.verified,
        label: (_) => name,
        builder: () => Center(child: Text('screen-$name')),
        access: RouteAccess(requiredSection: s),
      );

  final registry = {
    ...baseRegistry,
    AppSection.verification: stub(
      AppSection.verification,
      'Verification',
      '/verification',
    ),
    AppSection.administration: stub(
      AppSection.administration,
      'Administration',
      '/administration',
    ),
  };
  final overrides = [destinationRegistryProvider.overrideWithValue(registry)];

  Future<void> signIn(WidgetTester tester, String id) async {
    await openSignIn(tester);
    await signInWith(tester, identifier: id, password: SeedIds.demoPassword);
  }

  testWidgets('a booker signs in and sees the four base sections', (
    tester,
  ) async {
    await pumpSprintApp(tester, overrides: overrides);
    await signIn(tester, 'mona@example.test');
    for (final l in [
      ar.navHome,
      ar.navFacilities,
      ar.navBookings,
      ar.navProfile,
    ]) {
      expect(find.text(l), findsWidgets, reason: l);
    }
    expect(find.text('Verification'), findsNothing);
    expect(find.text('Administration'), findsNothing);
  });

  testWidgets('a verifier signing in gains Verification', (tester) async {
    await pumpSprintApp(
      tester,
      size: const Size(1000, 800),
      overrides: overrides,
    );
    await signIn(tester, '01000000007');
    expect(find.text('Verification'), findsWidgets);
    expect(find.text('Administration'), findsNothing);
  });

  testWidgets('a super admin gains both, with the overflow on compact', (
    tester,
  ) async {
    await pumpSprintApp(tester, overrides: overrides);
    await signIn(tester, 'hala@example.test');
    // Six sections do not fit a compact tab bar: the rest sit behind More.
    expect(find.text(ar.navMore), findsWidgets);
    await tester.tap(find.text(ar.navMore).first);
    await tester.pumpAndSettle();
    expect(find.text('Verification'), findsWidgets);
    expect(find.text('Administration'), findsWidgets);
  });

  testWidgets('sign out drops staff sections and their deep links', (
    tester,
  ) async {
    await pumpSprintApp(
      tester,
      size: const Size(1000, 800),
      overrides: overrides,
    );
    await signIn(tester, '01000000007');
    routerOf(tester).go('/verification');
    await tester.pumpAndSettle();
    expect(find.text('screen-Verification'), findsOneWidget);

    // Sign out from Profile, through the confirmation.
    routerOf(tester).go('/profile');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(AccountCard.signOutKey));
    await tester.pumpAndSettle();
    expect(find.text(ar.signOutTitle), findsOneWidget);
    await tester.tap(find.text(ar.signOutKeep));
    await tester.pumpAndSettle();
    expect(containerOf(tester).read(currentSessionProvider).isGuest, isFalse);

    await tester.tap(find.byKey(AccountCard.signOutKey));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.text(ar.signOutConfirm),
      ),
    );
    await tester.pumpAndSettle();
    expect(containerOf(tester).read(currentSessionProvider).isGuest, isTrue);
    expect(find.text('Verification'), findsNothing);

    routerOf(tester).go('/verification');
    await tester.pumpAndSettle();
    // The staff screen is no longer in navigation, and a deep link to it now
    // sends the guest to sign-in (FR-018).
    expect(find.text('screen-Verification'), findsNothing);
    expect(find.byType(NotFoundScreen), findsNothing);
    expect(
      routerOf(tester).routerDelegate.currentConfiguration.uri.toString(),
      '/sign-in?from=%2Fverification',
    );
  });
}
