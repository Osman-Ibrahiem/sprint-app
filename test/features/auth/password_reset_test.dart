import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/l10n/locale_notifier.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/theme/theme_mode_notifier.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/features/auth/domain/auth_limits.dart';
import 'package:sprint/features/auth/domain/email_code.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

import '../../helpers/data_env.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/sign_in_steps.dart';
import '../../helpers/sign_up_steps.dart';

const _email = 'mona@example.test';
const _newPassword = 'Fresh2026x';

/// Password reset by emailed code (US-04, FR-AUTH-03, FR-020 – FR-022).
void main() {
  group('repository rules', () {
    test(
      'same answer for a known and an unknown identifier (FR-021)',
      () async {
        final env = DataEnv();
        final auth = env.layer.auth;
        final known = await auth.requestPasswordReset(_email);
        final unknown = await auth.requestPasswordReset('nobody@example.test');
        expect(known.isOk, isTrue);
        expect(unknown.isOk, isTrue);
        expect(
          env.layer.mailbox.latestCodeFor(_email, CodePurpose.resetPassword),
          isNotNull,
        );
        expect(
          env.layer.mailbox.latestCodeFor(
            'nobody@example.test',
            CodePurpose.resetPassword,
          ),
          isNull,
        );
      },
    );

    test('a wrong code counts down, an expired one is refused', () async {
      final env = DataEnv();
      final auth = env.layer.auth;
      await auth.requestPasswordReset(_email);
      final wrong = await auth.resetPassword(
        identifier: _email,
        code: '000000',
        newPassword: _newPassword,
      );
      expect(wrong, isA<Err<Object?>>());
      expect(
        (wrong as Err).failure,
        isA<CodeWrong>().having((f) => f.triesLeft, 'triesLeft', 4),
      );

      final code = env.layer.mailbox.latestCodeFor(
        _email,
        CodePurpose.resetPassword,
      )!;
      env.advance(AuthLimits.codeLife + const Duration(minutes: 1));
      final late = await auth.resetPassword(
        identifier: _email,
        code: code,
        newPassword: _newPassword,
      );
      expect((late as Err).failure, isA<CodeExpired>());
    });

    test('the new password must meet the rules', () async {
      final env = DataEnv();
      final auth = env.layer.auth;
      await auth.requestPasswordReset(_email);
      final code = env.layer.mailbox.latestCodeFor(
        _email,
        CodePurpose.resetPassword,
      )!;
      for (final bad in ['short1', 'nodigitshere', '1234567890']) {
        final r = await auth.resetPassword(
          identifier: _email,
          code: code,
          newPassword: bad,
        );
        expect((r as Err).failure, isA<InvalidField>(), reason: bad);
      }
    });

    test('old password rejected, new accepted, lockout cleared', () async {
      final env = DataEnv();
      final auth = env.layer.auth;
      for (var i = 0; i < AuthLimits.maxPasswordFailures; i++) {
        await auth.signIn(identifier: _email, password: 'wrong$i');
      }
      final locked = await auth.signIn(
        identifier: _email,
        password: SeedIds.demoPassword,
      );
      expect((locked as Err).failure, isA<LockedOut>());

      await auth.requestPasswordReset(_email);
      final code = env.layer.mailbox.latestCodeFor(
        _email,
        CodePurpose.resetPassword,
      )!;
      final reset = await auth.resetPassword(
        identifier: _email,
        code: code,
        newPassword: _newPassword,
      );
      expect(reset.isOk, isTrue);
      await auth.signOut();

      final old = await auth.signIn(
        identifier: _email,
        password: SeedIds.demoPassword,
      );
      expect((old as Err).failure, isA<BadCredentials>());
      final fresh = await auth.signIn(
        identifier: _email,
        password: _newPassword,
      );
      expect(fresh.isOk, isTrue);
    });
  });

  group('screens', () {
    final sizes = {
      'compact': const Size(400, 800),
      'expanded': const Size(1000, 800),
    };
    for (final lang in ['ar', 'en']) {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        for (final MapEntry(key: sizeName, value: size) in sizes.entries) {
          for (final scale in [1.0, 2.0]) {
            testWidgets('renders: $lang $mode $sizeName x$scale, no overflow', (
              tester,
            ) async {
              await pumpSprintApp(tester, size: size, textScale: scale);
              containerOf(tester)
                ..read(localeProvider.notifier).set(Locale(lang))
                ..read(themeModeProvider.notifier).set(mode);
              final l10n = lookupAppLocalizations(Locale(lang));

              routerOf(tester).go('/forgot-password');
              await tester.pumpAndSettle();
              expect(find.text(l10n.forgotSendButton), findsOneWidget);
              expect(tester.takeException(), isNull);

              routerOf(tester).go('/reset-password?identifier=$_email');
              await tester.pumpAndSettle();
              expect(find.text(l10n.resetSaveButton), findsOneWidget);
              expect(find.text(l10n.resetNewPasswordLabel), findsOneWidget);
              expect(tester.takeException(), isNull);
            });
          }
        }
      }
    }

    Future<void> submitForgot(WidgetTester tester, String identifier) async {
      await tester.enterText(find.byType(TextField).first, identifier);
      await tester.pump();
      await tester.tap(find.byType(SprintButton).first);
      await tester.pumpAndSettle();
    }

    testWidgets('same neutral message for known and unknown identifiers', (
      tester,
    ) async {
      await pumpSprintApp(tester);
      for (final id in [_email, 'nobody@example.test']) {
        routerOf(tester).go('/forgot-password');
        await tester.pumpAndSettle();
        await submitForgot(tester, id);
        expect(topUri(tester).path, '/reset-password');
        expect(find.text(ar.resetSentNeutral), findsOneWidget);
      }
    });

    testWidgets('full flow: wrong code, weak password, then signed in', (
      tester,
    ) async {
      await pumpSprintApp(tester);
      await openSignIn(tester, from: '/bookings');
      await tester.tap(find.text(ar.signInForgot));
      await tester.pumpAndSettle();
      await submitForgot(tester, _email);
      expect(topUri(tester).path, '/reset-password');
      expect(
        routerOf(tester)
            .routerDelegate
            .currentConfiguration
            .uri
            .queryParameters['from'],
        '/bookings',
      );

      final mailbox = containerOf(tester).read(dataLayerProvider).mailbox;
      final code = mailbox.latestCodeFor(_email, CodePurpose.resetPassword)!;

      // Wrong code first: message, stays on the screen.
      final password = find.byType(TextField);
      await tester.enterText(codeInput, '000000');
      await tester.enterText(password, _newPassword);
      await tester.pump();
      await tester.tap(find.text(ar.resetSaveButton));
      await tester.pumpAndSettle();
      expect(find.text(ar.resetCodeWrong(4)), findsOneWidget);
      expect(topUri(tester).path, '/reset-password');

      // Weak password: message, no call.
      await tester.enterText(codeInput, code);
      await tester.enterText(password, 'short');
      await tester.pump();
      await tester.tap(find.text(ar.resetSaveButton));
      await tester.pumpAndSettle();
      expect(find.text(ar.resetPasswordTooShort), findsOneWidget);

      await tester.enterText(password, _newPassword);
      await tester.pump();
      await tester.tap(find.text(ar.resetSaveButton));
      await tester.pumpAndSettle();
      expect(containerOf(tester).read(currentSessionProvider).isGuest, isFalse);
      expect(currentPath(tester), '/bookings');
    });

    testWidgets('success without from goes Home', (tester) async {
      await pumpSprintApp(tester);
      routerOf(tester).go('/forgot-password');
      await tester.pumpAndSettle();
      await submitForgot(tester, _email);
      final code = containerOf(tester)
          .read(dataLayerProvider)
          .mailbox
          .latestCodeFor(_email, CodePurpose.resetPassword)!;
      await tester.enterText(codeInput, code);
      await tester.enterText(find.byType(TextField), _newPassword);
      await tester.pump();
      await tester.tap(find.text(ar.resetSaveButton));
      await tester.pumpAndSettle();
      expect(currentPath(tester), '/home');
    });

    testWidgets('new password field has newPassword autofill and is hidden', (
      tester,
    ) async {
      await pumpSprintApp(tester);
      routerOf(tester).go('/reset-password?identifier=$_email');
      await tester.pumpAndSettle();
      final fields = tester
          .widgetList<TextField>(find.byType(TextField))
          .toList();
      expect(fields.single.obscureText, isTrue);
      expect(fields.single.autofillHints, contains(AutofillHints.newPassword));
    });

    testWidgets('/reset-password without an identifier goes to forgot', (
      tester,
    ) async {
      await pumpSprintApp(tester);
      routerOf(tester).go('/reset-password');
      await tester.pumpAndSettle();
      expect(currentPath(tester), '/forgot-password');
    });
  });
}
