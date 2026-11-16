import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/tokens/sprint_colors.g.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/widgets/sprint_text_field/sprint_text_field.dart';

import '../../helpers/widget_harness.dart';

void main() {
  final colors = SprintColors.light;

  Future<void> pump(
    WidgetTester tester,
    Widget field, {
    Locale locale = const Locale('ar'),
    double textScale = 1,
  }) => pumpWidgetUnderAndSettle(
    tester,
    field,
    locale: locale,
    textScale: textScale,
  );

  BoxDecoration fieldDecoration(WidgetTester tester) {
    final box = tester.widget<DecoratedBox>(
      find.byKey(SprintTextField.fieldKey),
    );
    return box.decoration as BoxDecoration;
  }

  testWidgets('the label sits above and never floats; the placeholder is '
      'separate; the helper shows below', (tester) async {
    await pump(
      tester,
      const SprintTextField(
        label: 'البريد الإلكتروني',
        placeholder: 'name@tanta.edu.eg',
        helper: 'بنستخدمه للتذكير',
      ),
    );
    final labelY = tester.getTopLeft(find.text('البريد الإلكتروني')).dy;
    final fieldY = tester.getTopLeft(find.byKey(SprintTextField.fieldKey)).dy;
    expect(labelY, lessThan(fieldY));
    expect(find.text('name@tanta.edu.eg'), findsOneWidget);
    expect(find.text('بنستخدمه للتذكير'), findsOneWidget);
  });

  testWidgets('an error replaces the helper with an icon and message, a 2px '
      'danger border and danger-soft fill, and is in the semantics', (
    tester,
  ) async {
    await pump(
      tester,
      const SprintTextField(
        label: 'البريد الإلكتروني',
        helper: 'بنستخدمه للتذكير',
        error: 'الإيميل مش صح',
      ),
    );
    expect(find.text('بنستخدمه للتذكير'), findsNothing);
    expect(find.text('الإيميل مش صح'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);

    final decoration = fieldDecoration(tester);
    expect(decoration.color, colors.dangerSoft);
    final border = decoration.border! as Border;
    expect(border.top.color, colors.danger);
    expect(border.top.width, SprintExtras.focusRingWidth);

    // The error is announced as part of the field.
    final semantics = tester.getSemantics(find.byType(SprintTextField));
    expect(semantics.label, contains('الإيميل مش صح'));
  });

  testWidgets('focus draws a 2px primary border', (tester) async {
    await pump(
      tester,
      const SprintTextField(label: 'الاسم', placeholder: 'اسمك'),
    );
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    final border = fieldDecoration(tester).border! as Border;
    expect(border.top.color, colors.primary);
    expect(border.top.width, SprintExtras.focusRingWidth);
  });

  testWidgets('the inner text field draws no border of its own, so the '
      'theme never adds a second outline or focus ring', (tester) async {
    await pump(
      tester,
      const SprintTextField(label: 'الاسم', placeholder: 'اسمك'),
    );
    InputDecoration inner() =>
        tester.widget<InputDecorator>(find.byType(InputDecorator)).decoration;
    expect(inner().enabledBorder, InputBorder.none);
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    expect(inner().focusedBorder, InputBorder.none);
    expect(inner().border, InputBorder.none);
  });

  testWidgets('disabled uses surface-sunken and ink-disabled', (tester) async {
    await pump(tester, const SprintTextField(label: 'الاسم', enabled: false));
    expect(fieldDecoration(tester).color, colors.surfaceSunken);
    final label = tester.widget<Text>(find.text('الاسم'));
    expect(label.style!.color, colors.inkDisabled);
  });

  testWidgets('email, phone, nationalId and password type LTR, start-aligned '
      'in Arabic', (tester) async {
    for (final type in [
      SprintTextFieldType.email,
      SprintTextFieldType.phone,
      SprintTextFieldType.nationalId,
      SprintTextFieldType.password,
    ]) {
      await pump(tester, SprintTextField(label: 'الحقل', type: type));
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.textDirection, TextDirection.ltr, reason: type.name);
      expect(field.textAlign, TextAlign.right, reason: type.name);
    }
  });

  testWidgets('keyboard type and autofill hints follow the type table', (
    tester,
  ) async {
    final cases = {
      SprintTextFieldType.text: TextInputType.text,
      SprintTextFieldType.password: TextInputType.text,
      SprintTextFieldType.search: TextInputType.text,
      SprintTextFieldType.phone: TextInputType.phone,
      SprintTextFieldType.email: TextInputType.emailAddress,
      SprintTextFieldType.nationalId: TextInputType.number,
    };
    for (final entry in cases.entries) {
      await pump(tester, SprintTextField(label: 'الحقل', type: entry.key));
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.keyboardType, entry.value, reason: entry.key.name);
    }

    await pump(
      tester,
      const SprintTextField(label: 'الإيميل', type: SprintTextFieldType.email),
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).autofillHints,
      contains(AutofillHints.email),
    );

    await pump(
      tester,
      const SprintTextField(label: 'الموبايل', type: SprintTextFieldType.phone),
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).autofillHints,
      contains(AutofillHints.telephoneNumber),
    );
  });

  testWidgets('the password reveal control has a 48 target and the show/hide '
      'labels', (tester) async {
    await pump(
      tester,
      const SprintTextField(
        label: 'كلمة السر',
        type: SprintTextFieldType.password,
      ),
    );
    expect(
      tester.getSize(find.byTooltip('إظهار')).height,
      greaterThanOrEqualTo(48),
    );
    await tester.tap(find.byTooltip('إظهار'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('إخفاء'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).obscureText,
      isFalse,
    );
  });

  testWidgets('search is a pill on surface-sunken with a search icon', (
    tester,
  ) async {
    await pump(
      tester,
      const SprintTextField(label: 'بحث', type: SprintTextFieldType.search),
    );
    final decoration = fieldDecoration(tester);
    expect(decoration.color, colors.surfaceSunken);
    expect(decoration.borderRadius, SprintRadius.fullBorder);
    expect(find.byIcon(Icons.search), findsOneWidget);
  });

  testWidgets('onLeave fires when focus leaves, and nothing validates while '
      'typing', (tester) async {
    var leaves = 0;
    var changes = 0;
    await pump(
      tester,
      Column(
        children: [
          SprintTextField(
            label: 'الاسم',
            onLeave: () => leaves++,
            onChanged: (_) => changes++,
          ),
          const SizedBox(height: 80),
          const TextField(key: ValueKey('other')),
        ],
      ),
    );
    await tester.tap(find.byType(TextField).first);
    await tester.enterText(find.byType(TextField).first, 'أ');
    await tester.pumpAndSettle();
    expect(leaves, 0);
    expect(changes, 1);

    await tester.tap(find.byKey(const ValueKey('other')));
    await tester.pumpAndSettle();
    expect(leaves, 1);
  });

  testWidgets('200% text keeps the label and helper readable and unclipped', (
    tester,
  ) async {
    await pump(
      tester,
      const SprintTextField(
        label: 'البريد الإلكتروني',
        placeholder: 'name@tanta.edu.eg',
        helper: 'بنستخدمه للتذكير',
      ),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
    expect(find.text('البريد الإلكتروني'), findsOneWidget);
    expect(find.text('بنستخدمه للتذكير'), findsOneWidget);
  });

  testWidgets('English labels render', (tester) async {
    await pump(
      tester,
      const SprintTextField(label: 'Email', placeholder: 'name@tanta.edu.eg'),
      locale: const Locale('en'),
    );
    expect(find.text('Email'), findsOneWidget);
  });

  group('code type', () {
    testWidgets('is LTR with a numeric keyboard and the one-time-code hint', (
      tester,
    ) async {
      await pump(
        tester,
        const SprintTextField(
          label: 'كود التأكيد',
          type: SprintTextFieldType.code,
        ),
      );
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.textDirection, TextDirection.ltr);
      expect(field.keyboardType, TextInputType.number);
      expect(field.autofillHints, contains(AutofillHints.oneTimeCode));
    });

    testWidgets('converts Arabic-Indic digits, drops non-digits, caps at 6', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await pump(
        tester,
        SprintTextField(
          label: 'كود التأكيد',
          type: SprintTextFieldType.code,
          controller: controller,
        ),
      );
      await tester.enterText(find.byType(TextField), '١٢ab٣-4567');
      expect(controller.text, '123456');
    });

    testWidgets('screen readers get one field carrying the label', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pump(
        tester,
        const SprintTextField(
          label: 'كود التأكيد',
          type: SprintTextFieldType.code,
        ),
      );
      final semantics = tester.getSemantics(find.byType(SprintTextField));
      expect(semantics.label, contains('كود التأكيد'));
      expect(find.byType(TextField), findsOneWidget);
      handle.dispose();
    });
  });

  testWidgets('autofillHints, textInputAction and focusNode are honoured', (
    tester,
  ) async {
    final node = FocusNode();
    addTearDown(node.dispose);
    await pump(
      tester,
      SprintTextField(
        label: 'الباسورد',
        type: SprintTextFieldType.password,
        autofillHints: const [AutofillHints.newPassword],
        textInputAction: TextInputAction.next,
        focusNode: node,
      ),
    );
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.autofillHints, [AutofillHints.newPassword]);
    expect(field.textInputAction, TextInputAction.next);
    expect(field.focusNode, node);
    node.requestFocus();
    await tester.pump();
    expect(node.hasFocus, isTrue);
  });
}
