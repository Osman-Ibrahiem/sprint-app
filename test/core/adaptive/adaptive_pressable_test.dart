import 'dart:ui' show PointerDeviceKind, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/adaptive/adaptive_pressable.dart';
import 'package:sprint/core/tokens/reduced_motion.dart';
import 'package:sprint/core/tokens/sprint_colors.g.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/theme/sprint_theme.dart';

void main() {
  final colors = SprintColors.light;
  var taps = 0;

  setUp(() {
    taps = 0;
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
  });

  tearDown(() {
    FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic;
  });

  Future<void> pump(
    WidgetTester tester,
    TargetPlatform platform, {
    VoidCallback? onTap,
    bool reduceMotion = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: SprintTheme.light.copyWith(platform: platform),
        home: Scaffold(
          body: Center(
            child: AdaptivePressable(
              label: 'اختيار',
              onTap: onTap ?? () => taps++,
              restingColor: colors.surface,
              pressedColor: colors.primaryPressed,
              hoverColor: colors.primaryHover,
              borderRadius: BorderRadius.zero,
              builder: (context, state) => const SizedBox(
                width: SprintExtras.slotChipMinWidth,
                height: SprintExtras.slotChipMinHeight,
                child: Text('chip', textDirection: TextDirection.rtl),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Apple fades to applePressedOpacity with no ripple',
      (tester) async {
    await pump(tester, TargetPlatform.iOS);
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(AdaptivePressable)),
    );
    await tester.pumpAndSettle();
    final fade = find.byKey(AdaptivePressable.fadeKey);
    expect(fade, findsOneWidget);
    expect(
      tester.widget<Opacity>(fade).opacity,
      SprintExtras.applePressedOpacity,
    );
    expect(find.byKey(AdaptivePressable.rippleKey), findsNothing);
    await gesture.up();
  });

  testWidgets('Android shows an ink ripple in the pressed colour',
      (tester) async {
    await pump(tester, TargetPlatform.android);
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(AdaptivePressable)),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(AdaptivePressable.rippleKey), findsOneWidget);
    expect(find.byKey(AdaptivePressable.fadeKey), findsNothing);
    await gesture.up();
  });

  testWidgets('Desktop changes colour on hover and uses the click cursor',
      (tester) async {
    await pump(tester, TargetPlatform.windows);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer();
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.byType(AdaptivePressable)));
    await tester.pumpAndSettle();

    final region = tester.widget<MouseRegion>(
      find
          .descendant(
            of: find.byType(AdaptivePressable),
            matching: find.byType(MouseRegion),
          )
          .first,
    );
    expect(region.cursor, SystemMouseCursors.click);

    final box = tester.widget<DecoratedBox>(
      find.byKey(AdaptivePressable.surfaceKey),
    );
    expect((box.decoration as BoxDecoration).color, colors.primaryHover);
  });

  testWidgets('all styles show the focus ring on keyboard focus and activate '
      'on Enter and Space', (tester) async {
    for (final platform in [
      TargetPlatform.iOS,
      TargetPlatform.android,
      TargetPlatform.windows,
    ]) {
      taps = 0;
      await pump(tester, platform);
      // Tab reaches the pressable and shows the ring.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('focus-ring-visible')),
        findsOneWidget,
        reason: '$platform',
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(taps, 1, reason: 'enter on $platform');
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(taps, 2, reason: 'space on $platform');
    }
  });

  testWidgets('the hit area is at least 48', (tester) async {
    await pump(tester, TargetPlatform.android);
    final size = tester.getSize(find.byType(AdaptivePressable));
    expect(size.height, greaterThanOrEqualTo(48));
  });

  testWidgets('a null onTap is skipped by focus and exposes the disabled '
      'semantic', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: SprintTheme.light.copyWith(platform: TargetPlatform.android),
        home: Scaffold(
          body: Center(
            child: AdaptivePressable(
              label: 'مكتمل',
              onTap: null,
              restingColor: colors.surface,
              pressedColor: colors.primaryPressed,
              hoverColor: colors.primaryHover,
              borderRadius: BorderRadius.zero,
              builder: (context, state) => const SizedBox(
                width: SprintExtras.slotChipMinWidth,
                height: SprintExtras.slotChipMinHeight,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final semantics = tester.getSemantics(find.byType(AdaptivePressable));
    expect(semantics.label, 'مكتمل');
    expect(semantics.flagsCollection.isEnabled, Tristate.isFalse);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('focus-ring-visible')), findsNothing);
  });

  testWidgets('pressed beats hovered beats focused', (tester) async {
    await pump(tester, TargetPlatform.windows, reduceMotion: true);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer();
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.byType(AdaptivePressable)));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();

    late AdaptivePressState lastState;
    await tester.pumpWidget(
      MaterialApp(
        theme: SprintTheme.light.copyWith(platform: TargetPlatform.windows),
        home: Scaffold(
          body: Center(
            child: AdaptivePressable(
              label: 'اختيار',
              onTap: () {},
              borderRadius: BorderRadius.zero,
              builder: (context, state) {
                lastState = state;
                return const SizedBox(
                  width: SprintExtras.slotChipMinWidth,
                  height: SprintExtras.slotChipMinHeight,
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    await mouse.moveTo(tester.getCenter(find.byType(AdaptivePressable)));
    await tester.pumpAndSettle();
    expect(lastState, AdaptivePressState.hovered);
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(AdaptivePressable)),
    );
    await tester.pump();
    expect(lastState, AdaptivePressState.pressed);
    await gesture.up();
  });

  testWidgets('reduced motion keeps the fade short', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: SprintTheme.light.copyWith(platform: TargetPlatform.iOS),
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: Center(
              child: AdaptivePressable(
                label: 'اختيار',
                onTap: () {},
                borderRadius: BorderRadius.zero,
                builder: (context, state) => const SizedBox(
                  width: SprintExtras.slotChipMinWidth,
                  height: SprintExtras.slotChipMinHeight,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(AdaptivePressable)),
    );
    await tester.pumpAndSettle();
    expect(ReducedMotion.of(tester.element(find.byType(AdaptivePressable))),
        isTrue);
    await gesture.up();
  });
}
