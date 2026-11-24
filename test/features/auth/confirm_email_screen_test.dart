import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/l10n/locale_notifier.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/theme/theme_mode_notifier.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/core/widgets/code_field/sprint_code_field.dart';
import 'package:sprint/features/auth/domain/auth_limits.dart';
import 'package:sprint/features/auth/presentation/widgets/demo_code_notice.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/sign_up_steps.dart';

/// The confirmation step across the cross-cutting matrix, its code field and
/// its messages (FR-005, FR-047, NFR-10).
void main() {
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
            routerOf(tester).go('/confirm-email?email=nora.new%40example.test');
            await tester.pumpAndSettle();
            final l10n = lookupAppLocalizations(Locale(lang));
            expect(find.text(l10n.confirmEmailTitle), findsWidgets);
            expect(find.text(l10n.codeEntrySentTo), findsOneWidget);
            expect(find.text('nora.new@example.test'), findsOneWidget);
            expect(find.text(l10n.codeEntryLabel), findsOneWidget);
            expect(tester.takeException(), isNull);
          });
        }
      }
    }
  }

  testWidgets('without an email there is nothing to confirm: sign up opens', (
    tester,
  ) async {
    await pumpSprintApp(tester);
    routerOf(tester).go('/confirm-email');
    await tester.pumpAndSettle();
    expect(find.text(ar.signUpNameLabel), findsOneWidget);
  });

  testWidgets('the code is six boxes on one input: its label read as a '
      'whole, digits only (decision 2)', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpSprintApp(tester, size: const Size(400, 1100));
    await signUpNewAccount(tester);

    expect(find.byType(SprintCodeField), findsOneWidget);
    expect(codeInput, findsOneWidget);
    for (var i = 0; i < sprintCodeLength; i++) {
      expect(find.byKey(SprintCodeField.boxKey(i)), findsOneWidget);
    }
    expect(find.bySemanticsLabel(RegExp(ar.codeEntryLabel)), findsOneWidget);
    final field = tester.widget<EditableText>(codeInput);
    expect(field.autofillHints, contains(AutofillHints.oneTimeCode));
    expect(field.keyboardType, TextInputType.number);

    await tester.enterText(codeInput, '١٢٣a٤٥٦٧٨');
    await tester.pump();
    expect(tester.widget<EditableText>(codeInput).controller.text, '123456');
    handle.dispose();
  });

  testWidgets('Enter submits; an incomplete code is explained in words', (
    tester,
  ) async {
    await pumpSprintApp(tester, size: const Size(400, 1100));
    await signUpNewAccount(tester);
    await enterCode(tester, '123');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text(ar.confirmCodeEmpty), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);

    await enterCode(tester, mailboxCode(tester, newEmail)!);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(containerOf(tester).read(currentSessionProvider).isGuest, isFalse);
  });

  testWidgets('the error clears when the person types again', (tester) async {
    await pumpSprintApp(tester, size: const Size(400, 1100));
    await signUpNewAccount(tester);
    await enterCode(tester, '123');
    await tapText(tester, ar.confirmEmailButton);
    expect(find.text(ar.confirmCodeEmpty), findsOneWidget);
    await enterCode(tester, '1234');
    expect(find.text(ar.confirmCodeEmpty), findsNothing);
  });

  testWidgets('the resend countdown runs on the app clock and then opens', (
    tester,
  ) async {
    final clock = MovableClock(DateTime.utc(2026, 11, 16, 9));
    await pumpSprintApp(
      tester,
      size: const Size(400, 1100),
      overrides: [appClockProvider.overrideWithValue(clock.value)],
    );
    await signUpNewAccount(tester);
    expect(find.text(ar.codeEntryResendIn(60)), findsOneWidget);
    clock.advance(const Duration(seconds: 10));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text(ar.codeEntryResendIn(50)), findsOneWidget);
    clock.advance(AuthLimits.resendWait);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text(ar.codeEntryResend), findsOneWidget);
  });

  testWidgets(
    'the demo notice shows the code, in an isolate, and can be hidden',
    (tester) async {
      await pumpSprintApp(tester, size: const Size(400, 1100));
      await signUpNewAccount(tester);
      final code = mailboxCode(tester, newEmail)!;
      expect(find.text(ar.demoNoticeTitle), findsOneWidget);
      expect(find.textContaining(code), findsOneWidget);
      await tester.tap(find.byKey(DemoCodeNotice.dismissKey));
      await tester.pump();
      expect(find.text(ar.demoNoticeTitle), findsNothing);
    },
  );

  testWidgets('the field and labels keep 48 high targets', (tester) async {
    await pumpSprintApp(tester, size: const Size(400, 1100));
    await signUpNewAccount(tester);
    for (var i = 0; i < sprintCodeLength; i++) {
      final box = tester.getSize(find.byKey(SprintCodeField.boxKey(i)));
      expect(box.height, greaterThanOrEqualTo(48));
    }
  });
}
