import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/l10n/locale_notifier.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/theme/theme_mode_notifier.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/features/auth/presentation/sign_in_screen.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

import '../../helpers/gated_auth_repository.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/sign_in_steps.dart';

/// The sign-in form across the cross-cutting matrix (language, theme, window,
/// text scale) and its keyboard and screen-reader behaviour (FR-047, NFR-10).
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
            await openSignIn(tester);
            final l10n = lookupAppLocalizations(Locale(lang));
            expect(find.text(l10n.signInIdentifierLabel), findsOneWidget);
            expect(find.text(l10n.signInPasswordLabel), findsOneWidget);
            expect(find.text(l10n.signInForgot), findsOneWidget);
            expect(tester.takeException(), isNull);
          });
        }
      }
    }
  }

  testWidgets('Tab goes identifier then password; Enter submits', (
    tester,
  ) async {
    await pumpSprintApp(tester);
    await openSignIn(tester);
    final fields = find.byType(EditableText);
    await tester.tap(fields.at(0));
    await tester.pump();
    expect(
      tester.widget<EditableText>(fields.at(0)).focusNode.hasFocus,
      isTrue,
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(
      tester.widget<EditableText>(fields.at(1)).focusNode.hasFocus,
      isTrue,
    );

    await tester.enterText(fields.at(0), 'mona@example.test');
    await tester.enterText(fields.at(1), SeedIds.demoPassword);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(containerOf(tester).read(currentSessionProvider).isGuest, isFalse);
  });

  testWidgets('the button waits for both fields', (tester) async {
    await pumpSprintApp(tester);
    await openSignIn(tester);
    SprintButton button() => tester.widget(find.byType(SprintButton).first);
    expect(button().onPressed, isNull);
    await tester.enterText(find.byType(TextField).at(0), 'a@b.c');
    await tester.pump();
    expect(button().onPressed, isNull);
    await tester.enterText(find.byType(TextField).at(1), 'x');
    await tester.pump();
    expect(button().onPressed, isNotNull);
  });

  testWidgets('no double submit while loading', (tester) async {
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
    await openSignIn(tester);
    await fillSignIn(
      tester,
      identifier: 'mona@example.test',
      password: SeedIds.demoPassword,
    );
    final button = find.byType(SprintButton).first;
    await tester.tap(button);
    await tester.pump();
    await tester.tap(button);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(gated.signInCalls, 1);
    gated.release();
    await tester.pumpAndSettle();
  });

  testWidgets('fields carry autofill hints and labels read aloud', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpSprintApp(tester);
    await openSignIn(tester);
    final fields = tester
        .widgetList<TextField>(find.byType(TextField))
        .toList();
    expect(fields[0].autofillHints, contains(AutofillHints.username));
    expect(fields[0].autofillHints, contains(AutofillHints.email));
    expect(fields[1].autofillHints, contains(AutofillHints.password));
    expect(fields[1].obscureText, isTrue);
    expect(
      find.bySemanticsLabel(RegExp(ar.signInIdentifierLabel)),
      findsWidgets,
    );
    expect(find.bySemanticsLabel(RegExp(ar.signInPasswordLabel)), findsWidgets);
    handle.dispose();
  });

  testWidgets('the failure is a live region with a word and an icon', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpSprintApp(tester);
    await openSignIn(tester);
    await signInWith(tester, identifier: 'mona@example.test', password: 'nope');
    expect(find.text(ar.signInBadCredentials), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    final node = tester.getSemantics(find.byKey(SignInScreen.errorKey));
    expect(node.flagsCollection.isLiveRegion, isTrue);
    handle.dispose();
  });

  testWidgets('Forgot password and Create account keep `from`', (tester) async {
    await pumpSprintApp(tester);
    await openSignIn(tester, from: '/bookings');
    await tester.tap(find.text(ar.signInForgot));
    await tester.pumpAndSettle();
    expect(topUri(tester).path, '/forgot-password');
    expect(topUri(tester).queryParameters['from'], '/bookings');

    routerOf(tester).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text(ar.signInCreateAccount));
    await tester.pumpAndSettle();
    expect(topUri(tester).path, '/sign-up');
    expect(topUri(tester).queryParameters['from'], '/bookings');
  });

  testWidgets('a signed-in person opening /sign-in is sent on', (tester) async {
    await pumpSprintApp(tester);
    await tester.runAsync(
      () =>
          containerOf(tester)
              .read(sessionProvider.notifier)
              .actAs(SeedIds.bookerInternal),
    );
    await tester.pumpAndSettle();
    routerOf(tester).go('/sign-in?from=%2Ffacilities');
    await tester.pumpAndSettle();
    expect(currentPath(tester), '/facilities');
    routerOf(tester).go('/sign-in?from=https%3A%2F%2Fevil.example');
    await tester.pumpAndSettle();
    expect(currentPath(tester), '/home');
  });
}
