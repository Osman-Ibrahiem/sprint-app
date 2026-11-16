import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/app_router.dart';
import 'package:sprint/core/l10n/locale_notifier.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/theme/sprint_theme.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/features/auth/domain/auth_limits.dart';
import 'package:sprint/features/auth/domain/email_code.dart';
import 'package:sprint/features/auth/presentation/widgets/demo_code_notice.dart';
import 'package:sprint/features/demo/presentation/demo_screen.dart';
import 'package:sprint/features/demo/presentation/mailbox_screen.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/sign_in_steps.dart';
import '../../helpers/sign_up_steps.dart';

/// FR-023: the simulated mailbox screen and the demo code notice, both only
/// while the demo release switch is on.
void main() {
  Future<void> openMailbox(WidgetTester tester) async {
    routerOf(tester).push('/demo/mailbox');
    await tester.pumpAndSettle();
  }

  testWidgets('an empty mailbox says so', (tester) async {
    await pumpSprintApp(tester);
    await openMailbox(tester);
    expect(find.text(ar.mailboxTitle), findsWidgets);
    expect(find.byKey(MailboxScreen.emptyKey), findsOneWidget);
    expect(find.text(ar.mailboxEmptyTitle), findsOneWidget);
  });

  testWidgets('the demo screen has an entry to the mailbox', (tester) async {
    await pumpSprintApp(tester, size: const Size(500, 1400));
    routerOf(tester).push('/demo');
    await tester.pumpAndSettle();
    final entry = find.text(ar.mailboxTitle);
    await tester.scrollUntilVisible(
      entry,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(entry);
    await tester.pumpAndSettle();
    expect(find.byType(MailboxScreen), findsOneWidget);
  });

  testWidgets(
    'the code email is listed with recipient, subject, time and code',
    (tester) async {
      final clock = MovableClock(DateTime.utc(2026, 11, 16, 14, 5));
      await pumpSprintApp(
        tester,
        size: const Size(400, 1100),
        overrides: [appClockProvider.overrideWithValue(clock.value)],
      );
      await signUpNewAccount(tester);
      final code = mailboxCode(tester, newEmail)!;
      await openMailbox(tester);

      expect(find.byKey(MailboxScreen.emptyKey), findsNothing);
      expect(find.text(ar.emailConfirmSubject), findsOneWidget);
      expect(find.text(newEmail), findsOneWidget);
      expect(find.textContaining(code), findsOneWidget);
      // 14:05 UTC is 4:05 PM in Cairo in November (UTC+2).
      expect(find.textContaining('4:05 م'), findsOneWidget);
      expect(find.text(ar.mailboxCopyCode), findsOneWidget);
    },
  );

  testWidgets('newest first, and the code copies to the clipboard', (
    tester,
  ) async {
    final clock = MovableClock(DateTime.utc(2026, 11, 16, 9));
    await pumpSprintApp(
      tester,
      size: const Size(400, 1400),
      overrides: [appClockProvider.overrideWithValue(clock.value)],
    );
    await signUpNewAccount(tester);
    final first = mailboxCode(tester, newEmail)!;
    clock.advance(AuthLimits.resendWait);
    await tester.pump(const Duration(seconds: 2));
    await tapText(tester, ar.codeEntryResend);
    final second = mailboxCode(tester, newEmail)!;
    expect(second, isNot(first));

    final copied = <String?>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied.add((call.arguments as Map)['text'] as String?);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await openMailbox(tester);
    final firstAt = tester.getTopLeft(find.textContaining(first)).dy;
    final secondAt = tester.getTopLeft(find.textContaining(second)).dy;
    expect(secondAt, lessThan(firstAt), reason: 'the newer email is on top');

    await tester.tap(find.text(ar.mailboxCopyCode).first);
    await tester.pump();
    expect(copied, [second]);
    expect(find.text(ar.mailboxCopied), findsOneWidget);
  });

  testWidgets('the email follows the language of the app when it is sent', (
    tester,
  ) async {
    await pumpSprintApp(tester, size: const Size(400, 1100));
    containerOf(tester).read(localeProvider.notifier).set(const Locale('en'));
    await tester.pumpAndSettle();
    final en = lookupAppLocalizations(const Locale('en'));
    await openSignUp(tester);
    await fillSignUp(tester);
    await tapText(tester, en.signUpButton);
    await openMailbox(tester);
    expect(find.text(en.emailConfirmSubject), findsOneWidget);
    expect(find.text(ar.emailConfirmSubject), findsNothing);
  });

  testWidgets('the notice shows the latest code, and a new one replaces it', (
    tester,
  ) async {
    final clock = MovableClock(DateTime.utc(2026, 11, 16, 9));
    await pumpSprintApp(
      tester,
      size: const Size(400, 1100),
      overrides: [appClockProvider.overrideWithValue(clock.value)],
    );
    await signUpNewAccount(tester);
    final first = mailboxCode(tester, newEmail)!;
    expect(find.text(ar.demoNoticeTitle), findsOneWidget);
    expect(find.textContaining(first), findsOneWidget);

    clock.advance(AuthLimits.resendWait);
    await tester.pump(const Duration(seconds: 2));
    await tapText(tester, ar.codeEntryResend);
    final second = mailboxCode(tester, newEmail)!;
    expect(find.textContaining(second), findsOneWidget);
    expect(find.textContaining(first), findsNothing);
  });

  group('with the demo switch off (FR-023)', () {
    testWidgets('no notice on the code screen, and the code is not shown', (
      tester,
    ) async {
      await pumpSprintApp(
        tester,
        size: const Size(400, 1100),
        overrides: [simulatedMailboxProvider.overrideWithValue(null)],
      );
      await signUpNewAccount(tester);
      expect(topUri(tester).path, '/confirm-email');
      expect(find.byType(DemoCodeNotice), findsNothing);
      expect(find.text(ar.demoNoticeTitle), findsNothing);
      expect(find.textContaining(RegExp(r'\d{6}')), findsNothing);
    });

    testWidgets('the notice widget itself renders nothing', (tester) async {
      setWindow(tester);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [simulatedMailboxProvider.overrideWithValue(null)],
          child: MaterialApp(
            theme: SprintTheme.light,
            locale: const Locale('ar'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: const Scaffold(
              body: DemoCodeNotice(
                email: newEmail,
                purpose: CodePurpose.confirmEmail,
              ),
            ),
          ),
        ),
      );
      expect(find.text(ar.demoNoticeTitle), findsNothing);
    });

    testWidgets('the route is not registered', (tester) async {
      setWindow(tester);
      final router = buildAppRouter(demoTools: false);
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            theme: SprintTheme.light,
            locale: const Locale('ar'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      router.go('/demo/mailbox');
      await tester.pumpAndSettle();
      expect(find.byType(MailboxScreen), findsNothing);
    });

    testWidgets('the demo screen has no mailbox entry', (tester) async {
      setWindow(tester, size: const Size(500, 1400));
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: SprintTheme.light,
            locale: const Locale('ar'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: const DemoScreen(showToolLinks: false),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(ar.mailboxTitle), findsNothing);
    });
  });
}
