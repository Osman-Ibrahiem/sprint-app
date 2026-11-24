import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/widgets/code_field/sprint_code_field.dart';
import 'package:sprint/core/theme/sprint_theme.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/core/widgets/sprint_text_field/sprint_text_field.dart';
import 'package:sprint/features/auth/presentation/widgets/auth_form_scaffold.dart';
import 'package:sprint/features/auth/presentation/widgets/code_entry.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

import '../../../../helpers/pump_app.dart';

Future<void> pumpPage(
  WidgetTester tester,
  Widget home, {
  Locale locale = const Locale('ar'),
  double textScale = 1,
  Size size = const Size(400, 800),
}) async {
  setWindow(tester, size: size, textScale: textScale);
  await tester.pumpWidget(
    MaterialApp(
      theme: SprintTheme.light,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: home,
    ),
  );
  await tester.pump();
}

void main() {
  group('AuthFormScaffold', () {
    testWidgets('caps the column at the token width on a wide window', (
      tester,
    ) async {
      await pumpPage(
        tester,
        AuthFormScaffold(
          title: 'تسجيل الدخول',
          primaryLabel: 'دخول',
          onSubmit: () {},
          children: const [
            SprintTextField(label: 'الإيميل', type: SprintTextFieldType.email),
          ],
        ),
        size: const Size(1200, 800),
      );
      final width = tester
          .getSize(find.byKey(AuthFormScaffold.columnKey))
          .width;
      expect(width, SprintExtras.authFormMaxWidth);
    });

    testWidgets('Enter on the last field submits; button reports loading', (
      tester,
    ) async {
      var submits = 0;
      await pumpPage(
        tester,
        Builder(
          builder: (context) => AuthFormScaffold(
            title: 'تسجيل الدخول',
            primaryLabel: 'دخول',
            onSubmit: () => submits++,
            children: [
              SprintTextField(
                label: 'الباسورد',
                type: SprintTextFieldType.password,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => submits++,
              ),
            ],
          ),
        ),
      );
      await tester.showKeyboard(find.byType(TextField));
      await tester.testTextInput.receiveAction(TextInputAction.done);
      expect(submits, 1);
      await tester.tap(find.text('دخول'));
      expect(submits, 2);
    });

    testWidgets('loading disables the primary action', (tester) async {
      var submits = 0;
      await pumpPage(
        tester,
        AuthFormScaffold(
          title: 'تسجيل الدخول',
          primaryLabel: 'دخول',
          loading: true,
          onSubmit: () => submits++,
          children: const [SprintTextField(label: 'الإيميل')],
        ),
      );
      await tester.tap(find.byType(SprintButton));
      expect(submits, 0);
    });

    testWidgets('200% text scrolls without overflow', (tester) async {
      await pumpPage(
        tester,
        AuthFormScaffold(
          title: 'تسجيل الدخول',
          primaryLabel: 'دخول',
          onSubmit: () {},
          footer: const Text('عندك حساب؟'),
          children: const [
            SprintTextField(label: 'الإيميل', type: SprintTextFieldType.email),
            SprintTextField(label: 'الباسورد'),
          ],
        ),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('CodeEntry', () {
    late DateTime now;
    setUp(() => now = DateTime.utc(2026, 11, 16, 10));

    Widget entry({VoidCallback? onResend, Widget? notice}) => Scaffold(
      body: SingleChildScrollView(
        child: CodeEntry(
          address: 'a@tanta.edu.eg',
          resendAfter: now.add(const Duration(seconds: 3)),
          onResend: onResend ?? () {},
          demoNotice: notice,
          now: () => now,
        ),
      ),
    );

    testWidgets('counts down, then enables resend', (tester) async {
      var resends = 0;
      await pumpPage(tester, entry(onResend: () => resends++));
      expect(find.text('إرسال الكود تاني بعد 3 ثانية'), findsOneWidget);
      await tester.tap(find.byKey(CodeEntry.resendKey), warnIfMissed: false);
      expect(resends, 0);

      now = now.add(const Duration(seconds: 3));
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('إرسال الكود تاني'), findsOneWidget);
      await tester.tap(find.byKey(CodeEntry.resendKey));
      expect(resends, 1);
    });

    testWidgets('shows the address in an LTR isolate and the demo slot', (
      tester,
    ) async {
      await pumpPage(tester, entry(notice: const Text('للعرض بس')));
      final dir = Directionality.of(
        tester.element(find.text('a@tanta.edu.eg')),
      );
      expect(dir, TextDirection.ltr);
      expect(find.text('للعرض بس'), findsOneWidget);
      expect(find.byType(SprintCodeField), findsOneWidget);
    });

    testWidgets('English and 200% text render without overflow', (
      tester,
    ) async {
      await pumpPage(tester, entry(), locale: const Locale('en'), textScale: 2);
      expect(tester.takeException(), isNull);
      expect(find.text('Resend the code in 3 s'), findsOneWidget);
    });
  });
}
