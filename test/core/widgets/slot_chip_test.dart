import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/adaptive/platform.dart';
import 'package:sprint/core/tokens/sprint_colors.g.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_motion.g.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/widgets/slot_chip/slot_chip.dart';
import 'package:sprint/core/widgets/slot_chip/slot_state.dart';

import '../../helpers/widget_harness.dart';

void main() {
  final colors = SprintColors.light;
  var selected = 0;

  setUp(() => selected = 0);

  final start = DateTime(2026, 11, 10, 18);

  Future<void> pump(
    WidgetTester tester, {
    SlotState state = SlotState.available,
    int? remaining = 5,
    num? price,
    double textScale = 1,
    bool reduceMotion = true,
  }) =>
      pumpWidgetUnderAndSettle(
        tester,
        SlotChip(
          start: start,
          state: state,
          remaining: remaining,
          fewLeftThreshold: 2,
          price: price,
          onSelected: () => selected++,
        ),
        textScale: textScale,
        reduceMotion: reduceMotion,
      );

  Color? background(WidgetTester tester) {
    final box = tester.widget<AnimatedContainer>(
      find.byKey(SlotChip.visualKey),
    );
    return (box.decoration! as BoxDecoration).color;
  }

  testWidgets('the five states use the README colours and words',
      (tester) async {
    await pump(tester);
    expect(background(tester), colors.surface);
    expect(find.text('5 أماكن'), findsOneWidget);

    await pump(tester, state: SlotState.selected);
    expect(background(tester), colors.primary);
    expect(find.text('مختار'), findsOneWidget);

    await pump(tester, state: SlotState.fewLeft, remaining: 2);
    expect(background(tester), colors.volt);
    expect(find.text('فاضل مكانين'), findsOneWidget);

    await pump(tester, state: SlotState.full, remaining: 0);
    expect(background(tester), colors.surfaceSunken);
    expect(find.text('مكتمل'), findsOneWidget);

    await pump(tester, state: SlotState.past, remaining: 0);
    expect(background(tester), isNull);
    expect(find.text('فات'), findsOneWidget);
  });

  testWidgets('a shared unit shows its count; an exclusive one shows no '
      'number', (tester) async {
    await pump(tester, remaining: 5);
    expect(find.text('5 أماكن'), findsOneWidget);

    await pump(tester, remaining: null);
    expect(find.textContaining('أماكن'), findsNothing);
  });

  testWidgets('the Arabic few-left forms 1, 2 and 5', (tester) async {
    for (final (n, word) in [
      (1, 'فاضل 1'),
      (2, 'فاضل مكانين'),
      (5, 'فاضل 5'),
    ]) {
      await pump(tester, state: SlotState.fewLeft, remaining: n);
      expect(find.text(word), findsOneWidget, reason: '$n');
    }
  });

  testWidgets('at least 56 x 100', (tester) async {
    await pump(tester);
    final size = tester.getSize(find.byKey(SlotChip.visualKey));
    expect(size.height, greaterThanOrEqualTo(SprintExtras.slotChipMinHeight));
    expect(size.width, greaterThanOrEqualTo(SprintExtras.slotChipMinWidth));
  });

  testWidgets('full and past ignore presses', (tester) async {
    for (final state in [SlotState.full, SlotState.past]) {
      await pump(tester, state: state, remaining: 0);
      await tester.tap(find.byType(SlotChip), warnIfMissed: false);
      expect(selected, 0, reason: state.name);
    }
  });

  testWidgets('the spoken sentence names the time and the state, and the price '
      'when given', (tester) async {
    await pump(tester, state: SlotState.fewLeft, remaining: 1, price: 120);
    final semantics = tester.getSemantics(find.byType(SlotChip));
    expect(semantics.label, contains('الساعة 6 مساءً'));
    expect(semantics.label, contains('فاضل مكان واحد'));
    expect(semantics.label, contains('120 ج.م'));
  });

  testWidgets('in-range is tinted primary-soft and carries its word',
      (tester) async {
    await pumpWidgetUnderAndSettle(
      tester,
      SlotChip(
        start: start,
        state: SlotState.inRange,
        remaining: 5,
        fewLeftThreshold: 2,
        onSelected: () {},
      ),
    );
    expect(background(tester), colors.primarySoft);
    expect(find.text('ضمن النطاق'), findsOneWidget);
    expect(
      tester.getSemantics(find.byType(SlotChip)).label,
      contains('ضمن النطاق'),
    );
  });

  testWidgets('corners are radius-sm (decision 11)', (tester) async {
    await pumpWidgetUnderAndSettle(
      tester,
      SlotChip(
        start: start,
        state: SlotState.available,
        fewLeftThreshold: 2,
        onSelected: () {},
      ),
    );
    final box = tester.widget<AnimatedContainer>(
      find.byKey(SlotChip.visualKey),
    );
    expect(
      (box.decoration! as BoxDecoration).borderRadius,
      SprintRadius.smBorder,
    );
  });

  testWidgets('selection calls the haptic on Apple and Android but not on '
      'desktop', (tester) async {
    for (final style in AdaptiveStyle.values) {
      final calls = <MethodCall>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          calls.add(call);
          return null;
        },
      );
      await pumpWidgetUnderAndSettle(
        tester,
        SlotChip(
          start: start,
          state: SlotState.available,
          remaining: 5,
          fewLeftThreshold: 2,
          onSelected: () => selected++,
        ),
        style: style,
      );
      await tester.tap(find.byType(SlotChip));
      await tester.pumpAndSettle();
      final haptics =
          calls.where((c) => c.method == 'HapticFeedback.vibrate').length;
      expect(haptics, style == AdaptiveStyle.desktop ? 0 : 1, reason: style.name);
    }
    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('a state change animates colour and word together within '
      'duration-base, and announces it', (tester) async {
    await pump(tester, reduceMotion: false);
    final switcher = tester.widget<AnimatedSwitcher>(
      find.byType(AnimatedSwitcher),
    );
    expect(switcher.duration, SprintMotion.durationBase);
    final box = tester.widget<AnimatedContainer>(find.byKey(SlotChip.visualKey));
    expect(box.duration, SprintMotion.durationBase);
    expect(
      tester.getSemantics(find.byType(SlotChip)).flagsCollection.isLiveRegion,
      isTrue,
    );

    await pump(tester, state: SlotState.full, remaining: 0);
    expect(find.text('مكتمل'), findsOneWidget);
    expect(find.text('5 أماكن'), findsNothing);
  });

  testWidgets('reduced motion keeps the fade at duration-fast', (tester) async {
    await pump(tester);
    final box = tester.widget<AnimatedContainer>(find.byKey(SlotChip.visualKey));
    expect(box.duration, SprintMotion.durationFast);
  });

  testWidgets('the word is always present, so volt is never the only signal',
      (tester) async {
    await pump(tester, state: SlotState.fewLeft, remaining: 2);
    expect(find.byKey(SlotChip.visualKey), findsOneWidget);
    expect(find.text('فاضل مكانين'), findsOneWidget);
  });

  testWidgets('200% text grows the chip', (tester) async {
    await pump(tester, textScale: 2);
    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byKey(SlotChip.visualKey)).height,
      greaterThanOrEqualTo(SprintExtras.slotChipMinHeight),
    );
  });
}
