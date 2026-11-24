import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/adaptive/adaptive_loader.dart';
import 'package:sprint/core/adaptive/adaptive_pressable.dart';
import 'package:sprint/core/adaptive/platform.dart';
import 'package:sprint/core/tokens/sprint_colors.g.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';

import '../../helpers/widget_harness.dart';

void main() {
  final colors = SprintColors.light;
  var presses = 0;

  setUp(() => presses = 0);

  Future<void> pump(
    WidgetTester tester,
    SprintButton button, {
    AdaptiveStyle? style,
    Locale locale = const Locale('ar'),
    double textScale = 1,
  }) async {
    await pumpWidgetUnderAndSettle(
      tester,
      button,
      style: style,
      locale: locale,
      textScale: textScale,
    );
  }

  testWidgets('the secondary outline follows the rounded corners', (
    tester,
  ) async {
    await pump(
      tester,
      SprintButton(
        label: 'x',
        variant: SprintButtonVariant.secondary,
        onPressed: () {},
      ),
    );
    final box = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byKey(SprintButton.visualKey),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final decoration = box.decoration as BoxDecoration;
    expect(decoration.border, isNotNull);
    expect(decoration.borderRadius, SprintRadius.mdBorder);
  });

  testWidgets('the five variants use the Button README token colours', (
    tester,
  ) async {
    final expected = {
      SprintButtonVariant.primary: colors.primary,
      SprintButtonVariant.secondary: colors.surface,
      SprintButtonVariant.tonal: colors.primarySoft,
      SprintButtonVariant.ghost: null,
      SprintButtonVariant.danger: colors.danger,
    };
    for (final entry in expected.entries) {
      await pump(
        tester,
        SprintButton(
          label: 'تأكيد الحجز',
          variant: entry.key,
          onPressed: () {},
        ),
      );
      final surface = tester.widget<DecoratedBox>(
        find.byKey(AdaptivePressable.surfaceKey),
      );
      expect((surface.decoration as BoxDecoration).color, entry.value);
    }
  });

  Color? surfaceColor(WidgetTester tester) =>
      (tester.widget<DecoratedBox>(find.byKey(AdaptivePressable.surfaceKey))
                  .decoration
              as BoxDecoration)
          .color;

  testWidgets('every variant changes on hover and on press, in its own colour '
      'family (decision U1)', (tester) async {
    final expected = {
      SprintButtonVariant.primary: (colors.primaryHover, colors.primaryPressed),
      SprintButtonVariant.secondary: (colors.surfaceSunken, colors.surfaceSunken),
      SprintButtonVariant.tonal: (
        colors.primarySoftHover,
        colors.primarySoftPressed,
      ),
      SprintButtonVariant.ghost: (colors.surfaceSunken, colors.surfaceSunken),
      SprintButtonVariant.danger: (colors.dangerHover, colors.dangerPressed),
    };
    expect(expected.keys.toSet(), SprintButtonVariant.values.toSet());
    // Hover highlights show in the traditional (mouse and keyboard) mode.
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(
      () => FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic,
    );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    for (final MapEntry(key: variant, value: (hover, pressed))
        in expected.entries) {
      await pump(
        tester,
        SprintButton(label: 'تأكيد', variant: variant, onPressed: () {}),
        style: AdaptiveStyle.desktop,
      );
      final resting = surfaceColor(tester);

      await mouse.moveTo(tester.getCenter(find.byType(SprintButton)));
      await tester.pumpAndSettle();
      expect(surfaceColor(tester), hover, reason: '$variant hover');
      expect(surfaceColor(tester), isNot(resting), reason: '$variant hover');

      await mouse.down(tester.getCenter(find.byType(SprintButton)));
      await tester.pump();
      expect(surfaceColor(tester), pressed, reason: '$variant pressed');
      expect(surfaceColor(tester), isNot(resting), reason: '$variant pressed');
      await mouse.up();
      await mouse.moveTo(Offset.zero);
      await tester.pumpAndSettle();
    }
  });

  testWidgets('md has radius-md and space-5 sides; sm has radius-sm and '
      'space-3 sides (decision 12)', (tester) async {
    for (final (size, radius, side) in [
      (SprintButtonSize.md, SprintRadius.mdBorder, SprintSpacing.space5),
      (SprintButtonSize.sm, SprintRadius.smBorder, SprintSpacing.space3),
    ]) {
      await pump(
        tester,
        SprintButton(label: 'تأكيد', size: size, onPressed: () {}),
      );
      final surface = tester.widget<DecoratedBox>(
        find.byKey(AdaptivePressable.surfaceKey),
      );
      expect((surface.decoration as BoxDecoration).borderRadius, radius);
      final padding = tester.widget<Padding>(
        find
            .descendant(
              of: find.byKey(SprintButton.visualKey),
              matching: find.byType(Padding),
            )
            .first,
      );
      final insets = padding.padding as EdgeInsetsDirectional;
      expect(insets.start, side, reason: '$size');
      expect(insets.end, side, reason: '$size');
    }
  });

  testWidgets('labels stay whole on a 320 window at 200% text', (
    tester,
  ) async {
    for (final size in SprintButtonSize.values) {
      await pumpWidgetUnderAndSettle(
        tester,
        SprintButton(label: 'متابعة للدفع', size: size, onPressed: () {}),
        textScale: 2,
        size: const Size(320, 800),
      );
      expect(tester.takeException(), isNull);
      final paragraph = tester.renderObject<RenderParagraph>(
        find.text('متابعة للدفع'),
      );
      expect(paragraph.didExceedMaxLines, isFalse);
    }
  });

  testWidgets('md is control-height and sm is control-height-sm with a 48 hit '
      'area', (tester) async {
    await pump(
      tester,
      SprintButton(label: 'تأكيد', size: SprintButtonSize.md, onPressed: () {}),
    );
    expect(
      tester.getSize(find.byKey(SprintButton.visualKey)).height,
      SprintSize.controlHeight,
    );

    await pump(
      tester,
      SprintButton(label: 'تأكيد', size: SprintButtonSize.sm, onPressed: () {}),
    );
    expect(
      tester.getSize(find.byKey(SprintButton.visualKey)).height,
      SprintSize.controlHeightSm,
    );
    expect(
      tester.getSize(find.byType(SprintButton)).height,
      greaterThanOrEqualTo(SprintSize.controlHeight),
    );
  });

  testWidgets('start and end icons show, and directional icons mirror in RTL', (
    tester,
  ) async {
    await pump(
      tester,
      SprintButton(
        label: 'التالي',
        icon: const SprintButtonIcon(
          Icons.arrow_forward,
          position: SprintButtonIconPosition.end,
          mirrorInRtl: true,
        ),
        onPressed: () {},
      ),
    );
    expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    expect(find.byType(Transform), findsWidgets); // mirrored in Arabic
  });

  testWidgets('loading shows AdaptiveLoader, the loading label and ignores '
      'presses', (tester) async {
    await pump(
      tester,
      SprintButton(
        label: 'تأكيد الحجز',
        loading: true,
        loadingLabel: 'جاري الدفع…',
        onPressed: () => presses++,
      ),
    );
    expect(find.byType(AdaptiveLoader), findsOneWidget);
    expect(find.text('جاري الدفع…'), findsOneWidget);
    await tester.tap(find.byType(SprintButton), warnIfMissed: false);
    expect(presses, 0);
  });

  testWidgets('disabled keeps the label and announces it unavailable', (
    tester,
  ) async {
    await pump(tester, const SprintButton(label: 'إلغاء الحجز'));
    expect(find.text('إلغاء الحجز'), findsOneWidget);
    final semantics = tester.getSemantics(find.byType(SprintButton));
    expect(semantics.label, contains('إلغاء الحجز'));
    expect(semantics.label, contains('غير متاح'));
  });

  testWidgets('a label with a price renders in full with Western digits', (
    tester,
  ) async {
    await pump(
      tester,
      SprintButton(label: 'تأكيد الحجز · 120 ج.م', onPressed: () {}),
    );
    expect(find.text('تأكيد الحجز · 120 ج.م'), findsOneWidget);
  });

  testWidgets('press feedback follows the platform', (tester) async {
    for (final style in AdaptiveStyle.values) {
      await pump(
        tester,
        SprintButton(label: 'تأكيد', onPressed: () => presses++),
        style: style,
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(SprintButton)),
      );
      await tester.pumpAndSettle();
      if (style == AdaptiveStyle.apple) {
        expect(find.byKey(AdaptivePressable.fadeKey), findsOneWidget);
      } else if (style == AdaptiveStyle.android) {
        expect(find.byKey(AdaptivePressable.rippleKey), findsOneWidget);
      } else {
        expect(find.byKey(AdaptivePressable.surfaceKey), findsOneWidget);
      }
      await gesture.up();
    }
  });

  testWidgets('the focus ring shows on keyboard focus', (tester) async {
    await pump(tester, SprintButton(label: 'تأكيد', onPressed: () {}));
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(
      () => FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('focus-ring-visible')), findsOneWidget);
  });

  testWidgets('no variant fills with volt', (tester) async {
    for (final variant in SprintButtonVariant.values) {
      await pump(
        tester,
        SprintButton(label: 'زر', variant: variant, onPressed: () {}),
      );
      final surface = tester.widget<DecoratedBox>(
        find.byKey(AdaptivePressable.surfaceKey),
      );
      expect(
        (surface.decoration as BoxDecoration).color,
        isNot(colors.volt),
        reason: variant.name,
      );
    }
  });

  testWidgets('at 200% text the button grows instead of clipping', (
    tester,
  ) async {
    await pump(
      tester,
      SprintButton(label: 'تأكيد الحجز · 120 ج.م', onPressed: () {}),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byKey(SprintButton.visualKey)).height,
      greaterThan(SprintSize.controlHeight),
    );
  });

  testWidgets('English label renders and the button stays pressable', (
    tester,
  ) async {
    await pump(
      tester,
      SprintButton(label: 'Confirm booking', onPressed: () => presses++),
      locale: const Locale('en'),
    );
    await tester.tap(find.byType(SprintButton));
    expect(presses, 1);
  });
}
