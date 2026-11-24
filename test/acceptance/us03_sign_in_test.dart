import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/core/adaptive/adaptive_loader.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/features/auth/presentation/confirm_email_screen.dart';
import 'package:sprint/features/auth/presentation/sign_in_screen.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/identity/domain/role_assignment.dart';

import '../helpers/gated_auth_repository.dart';
import '../helpers/pump_app.dart';
import '../helpers/sign_in_steps.dart';

/// BRD US-03 (FR-AUTH-02, FR-AUTH-04), plus the account states the form must
/// tell apart only after a right password (FR-010, FR-011).
void main() {
  final pw = SeedIds.demoPassword;

  Session sessionOf(WidgetTester tester) =>
      containerOf(tester).read(currentSessionProvider);

  testWidgets('email and password open the app for that person', (
    tester,
  ) async {
    await pumpSprintApp(tester);
    await openSignIn(tester);
    await signInWith(tester, identifier: 'mona@example.test', password: pw);

    expect(sessionOf(tester).user?.id, SeedIds.bookerInternal);
    expect(sessionOf(tester).tier, PriceTier.internal);
    expect(currentPath(tester), '/home');
    expect(find.text(ar.navAccount), findsWidgets);
  });

  testWidgets('a mobile number works too, in any case or spacing', (
    tester,
  ) async {
    await pumpSprintApp(tester);
    await openSignIn(tester);
    await signInWith(tester, identifier: ' 01000000007 ', password: pw);

    expect(sessionOf(tester).user?.id, SeedIds.verifier);
    expect(sessionOf(tester).roles.map((a) => a.role), contains(Role.verifier));
  });

  testWidgets('the button shows loading, then the right place opens', (
    tester,
  ) async {
    late GatedAuthRepository gated;
    await pumpSprintApp(
      tester,
      overrides: [
        authRepositoryProvider.overrideWith(
          (ref) =>
              gated = GatedAuthRepository(ref.watch(dataLayerProvider).auth),
        ),
      ],
    );
    await openSignIn(tester, from: '/facilities');
    await fillSignIn(tester, identifier: 'mona@example.test', password: pw);
    await tester.tap(find.byType(SprintButton).first);
    await tester.pump();
    expect(find.byType(AdaptiveLoader), findsOneWidget);
    expect(currentPath(tester), '/sign-in');

    gated.release();
    await tester.pumpAndSettle();
    expect(currentPath(tester), '/facilities');
  });

  group('the same message for every wrong detail', () {
    final cases = {
      'wrong password': ('mona@example.test', 'not-it-12'),
      'unknown email': ('nobody@example.test', 'Sprint2026'),
      'unknown mobile': ('01099999999', 'Sprint2026'),
    };
    for (final MapEntry(:key, :value) in cases.entries) {
      testWidgets(key, (tester) async {
        await pumpSprintApp(tester);
        await openSignIn(tester);
        await signInWith(tester, identifier: value.$1, password: value.$2);

        expect(find.text(ar.signInBadCredentials), findsOneWidget);
        expect(find.byKey(SignInScreen.errorKey), findsOneWidget);
        expect(sessionOf(tester).isGuest, isTrue);
        expect(currentPath(tester), '/sign-in');
      });
    }
  });

  testWidgets('a suspended account is named only after the right password', (
    tester,
  ) async {
    await pumpSprintApp(tester);
    await openSignIn(tester);
    await signInWith(tester, identifier: 'heba@example.test', password: 'x');
    expect(find.text(ar.signInBadCredentials), findsOneWidget);

    await signInWith(tester, identifier: 'heba@example.test', password: pw);
    expect(find.text(ar.signInSuspended), findsOneWidget);
    expect(sessionOf(tester).isGuest, isTrue);
  });

  testWidgets('an unconfirmed account goes on to confirm its email', (
    tester,
  ) async {
    await pumpSprintApp(tester);
    await openSignIn(tester, from: '/bookings');
    await signInWith(tester, identifier: 'ahmed@example.test', password: pw);

    expect(sessionOf(tester).isGuest, isTrue);
    expect(topUri(tester).path, '/confirm-email');
    final screen = tester.widget<ConfirmEmailScreen>(
      find.byType(ConfirmEmailScreen),
    );
    expect(screen.email, 'ahmed@example.test');
    expect(screen.from, '/bookings');
  });

  testWidgets('five wrong passwords lock sign in, with the time left', (
    tester,
  ) async {
    await pumpSprintApp(tester);
    await openSignIn(tester);
    for (var i = 0; i < 5; i++) {
      await signInWith(
        tester,
        identifier: 'mona@example.test',
        password: 'no$i',
      );
    }
    expect(find.text(ar.signInLocked(5)), findsOneWidget);

    // Even the right password waits.
    await signInWith(tester, identifier: 'mona@example.test', password: pw);
    expect(find.text(ar.signInLocked(5)), findsOneWidget);
    expect(sessionOf(tester).isGuest, isTrue);
  });

  testWidgets('the session survives and sign out returns to a guest', (
    tester,
  ) async {
    await pumpSprintApp(tester);
    await openSignIn(tester);
    await signInWith(tester, identifier: 'mona@example.test', password: pw);
    expect(sessionOf(tester).isGuest, isFalse);

    await tester.runAsync(
      () => containerOf(tester).read(sessionProvider.notifier).signOut(),
    );
    await tester.pumpAndSettle();
    expect(sessionOf(tester).isGuest, isTrue);
  });
}
