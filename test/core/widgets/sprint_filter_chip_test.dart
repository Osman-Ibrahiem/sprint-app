import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/adaptive/adaptive_pressable.dart';
import 'package:sprint/core/tokens/sprint_colors.g.dart';
import 'package:sprint/core/widgets/filter_chip/sprint_filter_chip.dart';

import '../../helpers/widget_harness.dart';

/// Decision 21 of refactor 000: one filter chip, `control-border` unselected,
/// `primary` selected.
void main() {
  BoxDecoration visual(WidgetTester tester) =>
      tester.widget<Container>(find.byKey(SprintFilterChip.visualKey)).decoration!
          as BoxDecoration;

  for (final dark in [false, true]) {
    final colors = dark ? SprintColors.dark : SprintColors.light;
    testWidgets('unselected: surface with a control-border edge '
        '(${dark ? 'dark' : 'light'})', (tester) async {
      await pumpWidgetUnderAndSettle(
        tester,
        SprintFilterChip(label: 'سباحة', selected: false, onTap: () {}),
        dark: dark,
      );
      expect((visual(tester).border! as Border).top.color, colors.controlBorder);
      final surface = tester.widget<DecoratedBox>(
        find.byKey(AdaptivePressable.surfaceKey),
      );
      expect((surface.decoration as BoxDecoration).color, colors.surface);
      expect(find.byIcon(PhosphorIconsRegular.check), findsNothing);
    });

    testWidgets('selected: primary-soft, a primary edge and a check '
        '(${dark ? 'dark' : 'light'})', (tester) async {
      await pumpWidgetUnderAndSettle(
        tester,
        SprintFilterChip(label: 'سباحة', selected: true, onTap: () {}),
        dark: dark,
      );
      expect((visual(tester).border! as Border).top.color, colors.primary);
      expect(find.byIcon(PhosphorIconsRegular.check), findsOneWidget);
    });
  }

  testWidgets('48 high, announced as a selected button, and tappable', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    var taps = 0;
    await pumpWidgetUnderAndSettle(
      tester,
      SprintFilterChip(
        label: 'سباحة',
        selected: true,
        semanticLabel: 'إزالة فلتر سباحة',
        trailingIcon: PhosphorIconsRegular.x,
        onTap: () => taps++,
      ),
    );
    expect(
      tester.getSize(find.byType(SprintFilterChip)).height,
      greaterThanOrEqualTo(48),
    );
    expect(find.bySemanticsLabel('إزالة فلتر سباحة'), findsOneWidget);
    expect(find.byIcon(PhosphorIconsRegular.check), findsNothing);
    await tester.tap(find.byType(SprintFilterChip));
    expect(taps, 1);
    handle.dispose();
  });

  testWidgets('200% text grows the chip without overflow', (tester) async {
    await pumpWidgetUnderAndSettle(
      tester,
      SprintFilterChip(
        label: 'كل المنشآت',
        selected: false,
        icon: PhosphorIconsRegular.swimmingPool,
        onTap: () {},
      ),
      textScale: 2,
      size: const Size(320, 800),
    );
    expect(tester.takeException(), isNull);
  });
}
