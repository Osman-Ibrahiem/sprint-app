import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/tokens/sprint_colors.g.dart';
import 'package:sprint/core/tokens/sprint_motion.g.dart';
import 'package:sprint/core/widgets/code_field/sprint_code_field.dart';

import '../../helpers/widget_harness.dart';

/// Decision 2 of refactor 000: the confirmation code is six boxes, built on
/// the `pinput` package and styled from tokens only.
void main() {
  final colors = SprintColors.light;

  BoxDecoration box(WidgetTester tester, int index) {
    final c = tester.widget<AnimatedContainer>(
      find.descendant(
        of: find.byKey(SprintCodeField.boxKey(index)),
        matching: find.byType(AnimatedContainer),
      ),
    );
    return c.decoration! as BoxDecoration;
  }

  EditableText editable(WidgetTester tester) =>
      tester.widget<EditableText>(find.byType(EditableText));

  testWidgets('six boxes, 48 high at least, with a numeric keyboard and the '
      'one-time-code autofill hint', (tester) async {
    await pumpWidgetUnderAndSettle(
      tester,
      const SprintCodeField(label: 'كود التأكيد'),
    );
    for (var i = 0; i < sprintCodeLength; i++) {
      expect(find.byKey(SprintCodeField.boxKey(i)), findsOneWidget);
      expect(
        tester.getSize(find.byKey(SprintCodeField.boxKey(i))).height,
        greaterThanOrEqualTo(48),
      );
    }
    expect(editable(tester).keyboardType, TextInputType.number);
    expect(editable(tester).autofillHints, contains(AutofillHints.oneTimeCode));
  });

  testWidgets('digits run left to right in Arabic and English', (tester) async {
    for (final locale in const [Locale('ar'), Locale('en')]) {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await pumpWidgetUnderAndSettle(
        tester,
        SprintCodeField(label: 'code', controller: controller),
        locale: locale,
      );
      await tester.enterText(find.byType(EditableText), '123456');
      await tester.pumpAndSettle();
      final first = tester.getCenter(find.text('1'));
      final last = tester.getCenter(find.text('6'));
      expect(first.dx, lessThan(last.dx), reason: '$locale');
    }
  });

  testWidgets('a pasted or typed code converts Arabic-Indic digits, drops '
      'other characters and stops at six', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    String? completed;
    await pumpWidgetUnderAndSettle(
      tester,
      SprintCodeField(
        label: 'كود التأكيد',
        controller: controller,
        onCompleted: (v) => completed = v,
      ),
    );
    await tester.enterText(find.byType(EditableText), '١٢ab٣-4567');
    await tester.pumpAndSettle();
    expect(controller.text, '123456');
    expect(completed, '123456');
  });

  testWidgets('every box has its own spoken label, and the field names '
      'itself and its error', (tester) async {
    final handle = tester.ensureSemantics();
    final controller = TextEditingController(text: '12');
    addTearDown(controller.dispose);
    await pumpWidgetUnderAndSettle(
      tester,
      SprintCodeField(
        label: 'كود التأكيد',
        controller: controller,
        error: 'الكود مش صح',
      ),
    );
    expect(find.bySemanticsLabel('الخانة 1 من 6: 1'), findsOneWidget);
    expect(find.bySemanticsLabel('الخانة 2 من 6: 2'), findsOneWidget);
    expect(find.bySemanticsLabel('الخانة 3 من 6، فاضية'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('كود التأكيد، الكود مش صح')),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('English box labels', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpWidgetUnderAndSettle(
      tester,
      const SprintCodeField(label: 'Confirmation code'),
      locale: const Locale('en'),
    );
    expect(find.bySemanticsLabel('Box 1 of 6, empty'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('states: control-border at rest, 2px primary on the next box '
      'when focused, danger on every box with an error', (tester) async {
    final node = FocusNode();
    addTearDown(node.dispose);
    await pumpWidgetUnderAndSettle(
      tester,
      SprintCodeField(label: 'كود التأكيد', focusNode: node),
    );
    expect(box(tester, 0).color, colors.surface);
    expect((box(tester, 0).border! as Border).top.color, colors.controlBorder);

    node.requestFocus();
    await tester.pumpAndSettle();
    expect((box(tester, 0).border! as Border).top.color, colors.primary);

    await pumpWidgetUnderAndSettle(
      tester,
      const SprintCodeField(label: 'كود التأكيد', error: 'غلط'),
    );
    for (var i = 0; i < sprintCodeLength; i++) {
      expect(box(tester, i).color, colors.dangerSoft);
    }
    expect(find.text('غلط'), findsOneWidget);
  });

  testWidgets('reduced motion drops the digit entrance', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await pumpWidgetUnderAndSettle(
      tester,
      SprintCodeField(label: 'كود التأكيد', controller: controller),
    );
    final switcher = tester.widget<AnimatedSwitcher>(
      find.descendant(
        of: find.byKey(SprintCodeField.boxKey(0)),
        matching: find.byType(AnimatedSwitcher),
      ),
    );
    expect(switcher.duration, Duration.zero);

    await pumpWidgetUnderAndSettle(
      tester,
      SprintCodeField(label: 'كود التأكيد', controller: controller),
      reduceMotion: false,
    );
    final moving = tester.widget<AnimatedSwitcher>(
      find.descendant(
        of: find.byKey(SprintCodeField.boxKey(0)),
        matching: find.byType(AnimatedSwitcher),
      ),
    );
    expect(moving.duration, SprintMotion.durationFast);
  });

  testWidgets('fits a 320 window at 200% text', (tester) async {
    await pumpWidgetUnderAndSettle(
      tester,
      const SprintCodeField(label: 'كود التأكيد'),
      textScale: 2,
      size: const Size(320, 800),
    );
    expect(tester.takeException(), isNull);
  });
}
