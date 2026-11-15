import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/adaptive/adaptive_pressable.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';

import '../../helpers/widget_harness.dart';
import 'widget_samples.dart';

/// The rules every widget shares (SC-004, SC-009, SC-010).
void main() {
  final names = plainWidgets().keys.toList();

  for (final name in names) {
    group(name, () {
      testWidgets('Dark has no shadow', (tester) async {
        await pumpWidgetUnderAndSettle(
          tester,
          plainWidgets()[name]!,
          dark: true,
        );
        final shadowed = tester
            .widgetList<DecoratedBox>(find.byType(DecoratedBox))
            .map((d) => d.decoration)
            .whereType<BoxDecoration>()
            .where((d) => d.boxShadow != null && d.boxShadow!.isNotEmpty);
        expect(shadowed, isEmpty);
      });

      testWidgets('builds at 200% text on a 400-wide window', (tester) async {
        await pumpWidgetUnderAndSettle(
          tester,
          plainWidgets()[name]!,
          textScale: 2,
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('every pressable target is at least 48', (tester) async {
        await pumpWidgetUnderAndSettle(tester, plainWidgets()[name]!);
        for (final element in find.byType(AdaptivePressable).evaluate()) {
          final size = element.size!;
          expect(size.height, greaterThanOrEqualTo(SprintSize.controlHeight));
          expect(size.width, greaterThanOrEqualTo(SprintSize.controlHeight));
        }
      });

      testWidgets('builds in English (LTR) without errors', (tester) async {
        final widget = plainWidgets()[name]!;
        await pumpWidgetUnderAndSettle(
          tester,
          widget,
          locale: const Locale('en'),
        );
        expect(tester.takeException(), isNull);
        final direction = Directionality.of(
          tester.element(find.byWidget(widget)),
        );
        expect(direction, TextDirection.ltr);
      });
    });
  }
}
