import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/tokens/sprint_colors.g.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';

import '../../helpers/widget_harness.dart';

/// H1: a disabled button looks disabled in every variant, in both themes.
void main() {
  for (final dark in [false, true]) {
    final colors = dark ? SprintColors.dark : SprintColors.light;
    for (final variant in SprintButtonVariant.values) {
      testWidgets('${variant.name} disabled, ${dark ? 'dark' : 'light'}',
          (tester) async {
        await pumpWidgetUnder(
          tester,
          SprintButton(label: 'حفظ', variant: variant, onPressed: null),
          dark: dark,
        );
        final text = tester.widget<Text>(find.text('حفظ'));
        expect(text.style!.color, colors.inkDisabled);
        final fill = tester
            .widgetList<Material>(find.byType(Material))
            .any((m) => m.color == colors.surfaceSunken);
        final box = tester.widgetList<Container>(find.byType(Container)).any(
              (c) => c.color == colors.surfaceSunken,
            );
        expect(fill || box || _hasSunkenDecoration(tester, colors), isTrue);
        expect(find.bySemanticsLabel(RegExp('حفظ')), findsWidgets);
      });
    }
  }

  testWidgets('loading keeps its own look, not the disabled one',
      (tester) async {
    await pumpWidgetUnder(
      tester,
      const SprintButton(label: 'حفظ', loading: true, onPressed: null),
    );
    final text = tester.widget<Text>(find.byType(Text).first);
    expect(text.style!.color, isNot(SprintColors.light.inkDisabled));
  });
}

bool _hasSunkenDecoration(WidgetTester tester, SprintColors colors) => tester
    .widgetList<DecoratedBox>(find.byType(DecoratedBox))
    .any((d) => (d.decoration as BoxDecoration).color == colors.surfaceSunken);
