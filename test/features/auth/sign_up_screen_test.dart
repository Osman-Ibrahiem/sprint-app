import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/l10n/locale_notifier.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/theme/theme_mode_notifier.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/features/auth/domain/validators.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

import '../../helpers/gated_auth_repository.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/sign_in_steps.dart';
import '../../helpers/sign_up_steps.dart';

/// The sign-up form across the cross-cutting matrix, its per-field errors in
/// words, keyboard order and screen-reader labels (FR-002, FR-047, NFR-10).
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
            await openSignUp(tester);
            final l10n = lookupAppLocalizations(Locale(lang));
            for (final label in [
              l10n.signUpNameLabel,
              l10n.signUpPhoneLabel,
              l10n.signUpEmailLabel,
              l10n.signUpPasswordLabel,
            ]) {
              expect(find.text(label), findsOneWidget);
            }
            expect(find.byType(TextField), findsNWidgets(4));
            expect(tester.takeException(), isNull);
          });
        }
      }
    }
  }

  testWidgets('Tab follows name, phone, email, password; Enter submits', (
    tester,
  ) async {
    await pumpSprintApp(tester, size: const Size(400, 1100));
    await openSignUp(tester);
    final fields = find.byType(EditableText);
    await tester.tap(fields.at(0));
    await tester.pump();
    for (var i = 1; i < 4; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(
        tester.widget<EditableText>(fields.at(i)).focusNode.hasFocus,
        isTrue,
        reason: 'field $i has focus',
      );
    }
    await fillSignUp(tester);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(topUri(tester).path, '/confirm-email');
  });

  testWidgets('a problem shows in words next to its field when it is left', (
    tester,
  ) async {
    await pumpSprintApp(tester, size: const Size(400, 1100));
    await openSignUp(tester);
    final fields = find.byType(TextField);

    await tester.enterText(fields.at(0), 'نورا');
    await tester.pump();
    // Nothing is shown while typing.
    expect(find.text(ar.validationNameNeedsTwoWords), findsNothing);

    // Moving on to the next field is "leaving".
    await tester.enterText(fields.at(1), '12345');
    await tester.pump();
    await tester.tap(fields.at(2));
    await tester.pump();
    expect(find.text(ar.validationNameNeedsTwoWords), findsOneWidget);
    expect(find.text(ar.validationPhoneInvalid), findsOneWidget);
    // A word and an icon, never colour alone.
    expect(find.byIcon(Icons.error_outline), findsNWidgets(2));
    // The field a person has not touched yet stays quiet.
    expect(find.text(ar.validationEmailEmpty), findsNothing);

    // Fixing it clears it as soon as the field is left again.
    await tester.enterText(fields.at(0), 'نورا أحمد');
    await tester.tap(fields.at(3));
    await tester.pump();
    expect(find.text(ar.validationNameNeedsTwoWords), findsNothing);
  });

  testWidgets('submitting an empty form names every problem, creates nothing', (
    tester,
  ) async {
    late GatedAuthRepository gated;
    await pumpSprintApp(
      tester,
      size: const Size(400, 1100),
      overrides: [
        authRepositoryProvider.overrideWith(
          (ref) =>
              gated = GatedAuthRepository(ref.watch(dataLayerProvider).auth),
        ),
      ],
    );
    await openSignUp(tester);
    await tapText(tester, ar.signUpButton);
    for (final message in [
      ar.validationNameEmpty,
      ar.validationPhoneEmpty,
      ar.validationEmailEmpty,
      ar.validationPasswordEmpty,
    ]) {
      expect(find.text(message), findsOneWidget);
    }
    expect(gated.signUpCalls, 0);
    // Focus moved to the first field with a problem.
    expect(
      tester
          .widget<EditableText>(find.byType(EditableText).at(0))
          .focusNode
          .hasFocus,
      isTrue,
    );
  });

  for (final entry in {
    'a short password': ('Ab1', PasswordProblem.tooShort),
    'no digit': ('Abcdefgh', PasswordProblem.needsDigit),
    'no letter': ('12345678', PasswordProblem.needsLetter),
  }.entries) {
    testWidgets('password rule, ${entry.key}, is explained', (tester) async {
      await pumpSprintApp(tester, size: const Size(400, 1100));
      await openSignUp(tester);
      await fillSignUp(tester, password: entry.value.$1);
      await tapText(tester, ar.signUpButton);
      final message = switch (entry.value.$2) {
        PasswordProblem.tooShort => ar.validationPasswordTooShort,
        PasswordProblem.needsDigit => ar.validationPasswordNeedsDigit,
        _ => ar.validationPasswordNeedsLetter,
      };
      expect(find.text(message), findsOneWidget);
      expect(topUri(tester).path, '/sign-up');
    });
  }

  testWidgets('Arabic-Indic digits and +20 are accepted in the phone', (
    tester,
  ) async {
    await pumpSprintApp(tester, size: const Size(400, 1100));
    await openSignUp(tester);
    await fillSignUp(tester, phone: '+٢٠١٠٩٩٨٨٧٧٦٦');
    await tapText(tester, ar.signUpButton);
    expect(topUri(tester).path, '/confirm-email');
  });

  testWidgets('no double submit while loading', (tester) async {
    late GatedAuthRepository gated;
    await pumpSprintApp(
      tester,
      size: const Size(400, 1100),
      overrides: [
        authRepositoryProvider.overrideWith(
          (ref) =>
              gated = GatedAuthRepository(ref.watch(dataLayerProvider).auth),
        ),
      ],
    );
    await openSignUp(tester);
    await fillSignUp(tester);
    final button = find.byType(SprintButton).first;
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
    await tester.tap(button);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(gated.signUpCalls, 1);
    gated.release();
    await tester.pumpAndSettle();
  });

  testWidgets('fields carry autofill hints, helpers and spoken labels', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpSprintApp(tester, size: const Size(400, 1100));
    await openSignUp(tester);
    final fields = tester
        .widgetList<TextField>(find.byType(TextField))
        .toList();
    expect(fields[0].autofillHints, contains(AutofillHints.name));
    expect(fields[1].autofillHints, contains(AutofillHints.telephoneNumber));
    expect(fields[2].autofillHints, contains(AutofillHints.email));
    expect(fields[3].autofillHints, [AutofillHints.newPassword]);
    expect(fields[3].obscureText, isTrue);
    for (final label in [
      ar.signUpNameLabel,
      ar.signUpPhoneLabel,
      ar.signUpEmailLabel,
      ar.signUpPasswordLabel,
    ]) {
      expect(find.bySemanticsLabel(RegExp(label)), findsWidgets);
    }
    expect(find.text(ar.signUpPasswordHelper), findsOneWidget);
    handle.dispose();
  });

  testWidgets('the spoken label of a field includes its error', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpSprintApp(tester, size: const Size(400, 1100));
    await openSignUp(tester);
    await tapText(tester, ar.signUpButton);
    expect(
      find.bySemanticsLabel(
        RegExp('${ar.signUpEmailLabel}.*${ar.validationEmailEmpty}'),
      ),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('"already have an account" goes to sign in keeping from', (
    tester,
  ) async {
    await pumpSprintApp(tester, size: const Size(400, 1100));
    await openSignUp(tester, from: '/bookings');
    await tapText(tester, ar.signInButton);
    expect(topUri(tester).path, '/sign-in');
    final screen = find.text(ar.signInIdentifierLabel);
    expect(screen, findsOneWidget);
  });
}
