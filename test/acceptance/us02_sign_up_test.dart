import 'package:flutter/widgets.dart' show Size;
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/features/auth/domain/auth_limits.dart';
import 'package:sprint/features/auth/domain/email_code.dart';
import 'package:sprint/features/auth/presentation/confirm_email_screen.dart';
import 'package:sprint/features/auth/presentation/forgot_password_screen.dart';
import 'package:sprint/features/auth/presentation/sign_up_screen.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/identity/domain/role_assignment.dart';

import '../helpers/pump_app.dart';
import '../helpers/sign_in_steps.dart';
import '../helpers/sign_up_steps.dart';

/// BRD US-02 (FR-AUTH-01, BR-21): create an account, confirm the email, land
/// signed in as external. Every scenario runs through the screens against the
/// in-memory repositories; the code is read from the simulated mailbox the way
/// a reviewer would.
void main() {
  late MovableClock clock;

  setUp(() => clock = MovableClock(DateTime.utc(2026, 11, 16, 9)));

  Future<void> pump(WidgetTester tester) => pumpSprintApp(
    tester,
    size: const Size(400, 1100),
    overrides: [appClockProvider.overrideWithValue(clock.value)],
  );

  ConfirmEmailScreen confirmScreen(WidgetTester tester) =>
      tester.widget(find.byType(ConfirmEmailScreen));

  Session sessionOf(WidgetTester tester) =>
      containerOf(tester).read(currentSessionProvider);

  Future<int> userCount(WidgetTester tester) async => (await tester.runAsync(
    () => containerOf(tester).read(identityRepositoryProvider).users(),
  ))!.length;

  testWidgets('a new account is external after confirming, and lands on Home', (
    tester,
  ) async {
    await pump(tester);
    final before = await userCount(tester);
    await signUpNewAccount(tester);

    expect(topUri(tester).path, '/confirm-email');
    expect(confirmScreen(tester).email, newEmail);
    expect(find.text(newEmail), findsWidgets);
    // Not an account yet, and not signed in (FR-001).
    expect(sessionOf(tester).isGuest, isTrue);

    final code = mailboxCode(tester, newEmail)!;
    expect(code, matches(RegExp(r'^\d{6}$')));
    await enterCode(tester, code);
    await tapText(tester, ar.confirmEmailButton);

    expect(sessionOf(tester).user?.email, newEmail);
    expect(sessionOf(tester).user?.name, newName);
    expect(sessionOf(tester).tier, PriceTier.external);
    expect(sessionOf(tester).verification, isNull);
    expect(sessionOf(tester).roles.map((a) => a.role), [Role.booker]);
    expect(currentPath(tester), '/home');
    expect(await userCount(tester), before + 1);
  });

  testWidgets('after confirming the person returns to where they were', (
    tester,
  ) async {
    await pump(tester);
    await signUpNewAccount(tester, from: '/facilities');
    expect(confirmScreen(tester).from, '/facilities');
    await enterCode(tester, mailboxCode(tester, newEmail)!);
    await tapText(tester, ar.confirmEmailButton);
    expect(currentPath(tester), '/facilities');
  });

  group('an email or mobile number that is already registered', () {
    final cases = {
      'email': ('mona@example.test', newPhone, ar.signUpEmailTaken),
      'email in another case': (
        '  MONA@Example.Test ',
        newPhone,
        ar.signUpEmailTaken,
      ),
      'mobile': (newEmail, '01000000001', ar.signUpPhoneTaken),
      'mobile with +20': (newEmail, '+201000000001', ar.signUpPhoneTaken),
    };
    for (final MapEntry(:key, :value) in cases.entries) {
      testWidgets('$key: the message and the way out, nothing is created', (
        tester,
      ) async {
        final (email, phone, message) = value;
        await pump(tester);
        final before = await userCount(tester);
        final mails = containerOf(tester)
            .read(simulatedMailboxProvider)!
            .list()
            .length;
        await openSignUp(tester, from: '/bookings');
        await fillSignUp(tester, email: email, phone: phone);
        await tapText(tester, ar.signUpButton);

        expect(find.text(message), findsOneWidget);
        expect(find.text(ar.signUpTakenActions), findsOneWidget);
        expect(find.byKey(SignUpScreen.takenSignInKey), findsOneWidget);
        expect(find.byKey(SignUpScreen.takenResetKey), findsOneWidget);
        expect(topUri(tester).path, '/sign-up');
        expect(await userCount(tester), before);
        expect(
          containerOf(tester).read(simulatedMailboxProvider)!.list().length,
          mails,
        );

        await tester.tap(find.byKey(SignUpScreen.takenResetKey));
        await tester.pumpAndSettle();
        expect(topUri(tester).path, '/forgot-password');
        expect(
          tester
              .widget<ForgotPasswordScreen>(find.byType(ForgotPasswordScreen))
              .from,
          '/bookings',
        );
      });
    }

    testWidgets('the sign in link goes to the sign-in form', (tester) async {
      await pump(tester);
      await openSignUp(tester);
      await fillSignUp(tester, email: 'mona@example.test');
      await tapText(tester, ar.signUpButton);
      await tester.tap(find.byKey(SignUpScreen.takenSignInKey));
      await tester.pumpAndSettle();
      expect(currentPath(tester), '/sign-in');
    });
  });

  testWidgets(
    'a wrong code says so, counts the tries and keeps the person out',
    (tester) async {
      await pump(tester);
      await signUpNewAccount(tester);
      final real = mailboxCode(tester, newEmail)!;
      await enterCode(tester, wrongCodeFor(real));
      await tapText(tester, ar.confirmEmailButton);

      expect(
        find.text(ar.confirmCodeWrong(AuthLimits.maxCodeTries - 1)),
        findsOneWidget,
      );
      expect(sessionOf(tester).isGuest, isTrue);
      expect(topUri(tester).path, '/confirm-email');

      // The right code still works afterwards.
      await enterCode(tester, real);
      await tapText(tester, ar.confirmEmailButton);
      expect(sessionOf(tester).user?.email, newEmail);
    },
  );

  testWidgets('five wrong codes kill it; a new one works', (tester) async {
    await pump(tester);
    await signUpNewAccount(tester);
    final real = mailboxCode(tester, newEmail)!;
    for (var i = 0; i < AuthLimits.maxCodeTries; i++) {
      await enterCode(tester, wrongCodeFor(real));
      await tapText(tester, ar.confirmEmailButton);
    }
    await enterCode(tester, real);
    await tapText(tester, ar.confirmEmailButton);
    expect(find.text(ar.confirmCodeDead), findsOneWidget);
    expect(sessionOf(tester).isGuest, isTrue);

    clock.advance(AuthLimits.resendWait);
    await tester.pump(const Duration(seconds: 2));
    await tapText(tester, ar.codeEntryResend);
    final fresh = mailboxCode(tester, newEmail)!;
    await enterCode(tester, fresh);
    await tapText(tester, ar.confirmEmailButton);
    expect(sessionOf(tester).user?.email, newEmail);
  });

  testWidgets('an expired code says so; resending gives a working one', (
    tester,
  ) async {
    await pump(tester);
    await signUpNewAccount(tester);
    final old = mailboxCode(tester, newEmail)!;
    clock.advance(AuthLimits.codeLife + const Duration(minutes: 1));
    await enterCode(tester, old);
    await tapText(tester, ar.confirmEmailButton);
    expect(find.text(ar.confirmCodeExpired), findsOneWidget);
    expect(sessionOf(tester).isGuest, isTrue);

    await tester.pump(const Duration(seconds: 2));
    await tapText(tester, ar.codeEntryResend);
    expect(find.text(ar.confirmResent), findsOneWidget);
    await enterCode(tester, mailboxCode(tester, newEmail)!);
    await tapText(tester, ar.confirmEmailButton);
    expect(sessionOf(tester).user?.email, newEmail);
  });

  testWidgets('resend waits 60 seconds, then sends a new email', (
    tester,
  ) async {
    await pump(tester);
    await signUpNewAccount(tester);
    final mailbox = containerOf(tester).read(simulatedMailboxProvider)!;
    expect(
      find.text(ar.codeEntryResendIn(AuthLimits.resendWait.inSeconds)),
      findsOneWidget,
    );
    expect(find.text(ar.codeEntryResend), findsNothing);
    final sent = mailbox
        .list()
        .where((e) => e.purpose == CodePurpose.confirmEmail && e.to == newEmail)
        .length;
    expect(sent, 1);

    clock.advance(const Duration(seconds: 30));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text(ar.codeEntryResend), findsNothing);

    clock.advance(const Duration(seconds: 31));
    await tester.pump(const Duration(seconds: 2));
    await tapText(tester, ar.codeEntryResend);
    expect(
      mailbox
          .list()
          .where(
            (e) => e.purpose == CodePurpose.confirmEmail && e.to == newEmail,
          )
          .length,
      2,
    );
    // The wait starts again.
    expect(find.text(ar.codeEntryResendIn(60)), findsOneWidget);
  });

  testWidgets('leaving before confirming: signing in leads back to the code', (
    tester,
  ) async {
    await pump(tester);
    await signUpNewAccount(tester);
    expect(sessionOf(tester).isGuest, isTrue);

    // The person walks away from the code step and tries to sign in later.
    clock.advance(AuthLimits.resendWait);
    await openSignIn(tester);
    await signInWith(tester, identifier: newEmail, password: newPassword);
    expect(sessionOf(tester).isGuest, isTrue);
    expect(topUri(tester).path, '/confirm-email');
    expect(confirmScreen(tester).email, newEmail);

    // A fresh code was sent; it confirms the account.
    final mails = containerOf(tester).read(simulatedMailboxProvider)!.list();
    expect(mails.where((e) => e.to == newEmail).length, 2);
    await enterCode(tester, mailboxCode(tester, newEmail)!);
    await tapText(tester, ar.confirmEmailButton);
    expect(sessionOf(tester).user?.email, newEmail);
    expect(sessionOf(tester).tier, PriceTier.external);
  });

  testWidgets('a seeded unconfirmed account cannot skip confirmation', (
    tester,
  ) async {
    await pump(tester);
    await openSignIn(tester);
    await signInWith(
      tester,
      identifier: 'ahmed@example.test',
      password: SeedIds.demoPassword,
    );
    expect(sessionOf(tester).isGuest, isTrue);
    expect(topUri(tester).path, '/confirm-email');
  });
}
