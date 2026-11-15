import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/adaptive/adaptive_traits.dart';
import 'package:sprint/core/theme/sprint_theme.dart';

/// contracts/adaptive-additions.md: one trait value per style.
void main() {
  Future<AdaptiveTraits> traitsFor(WidgetTester tester, TargetPlatform p) async {
    late AdaptiveTraits traits;
    await tester.pumpWidget(
      MaterialApp(
        theme: SprintTheme.light.copyWith(platform: p),
        home: Builder(
          builder: (context) {
            traits = AdaptiveTraits.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    return traits;
  }

  testWidgets('Apple: fade, haptics, no tab-bar pill, no number shortcuts',
      (tester) async {
    final t = await traitsFor(tester, TargetPlatform.iOS);
    expect(t.pressFeedback, PressFeedback.fade);
    expect(t.hapticsOnSelect, isTrue);
    expect(t.tabBarPill, isFalse);
    expect(t.numberShortcuts, isFalse);
    expect(t.keyboardFocusRing, isTrue);
  });

  testWidgets('Android: ripple, haptics, pill allowed, no number shortcuts',
      (tester) async {
    final t = await traitsFor(tester, TargetPlatform.android);
    expect(t.pressFeedback, PressFeedback.ripple);
    expect(t.hapticsOnSelect, isTrue);
    expect(t.tabBarPill, isTrue);
    expect(t.numberShortcuts, isFalse);
    expect(t.keyboardFocusRing, isTrue);
  });

  testWidgets('Desktop: hover, no haptics, number shortcuts', (tester) async {
    final t = await traitsFor(tester, TargetPlatform.windows);
    expect(t.pressFeedback, PressFeedback.hover);
    expect(t.hapticsOnSelect, isFalse);
    expect(t.tabBarPill, isFalse);
    expect(t.numberShortcuts, isTrue);
    expect(t.keyboardFocusRing, isTrue);
  });
}
