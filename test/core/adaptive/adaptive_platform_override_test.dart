import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/adaptive/adaptive_platform_override.dart';
import 'package:sprint/core/adaptive/platform.dart';
import 'package:sprint/core/theme/sprint_theme.dart';

void main() {
  const cases = {
    AdaptiveStyle.apple: AdaptiveStyle.apple,
    AdaptiveStyle.android: AdaptiveStyle.android,
    AdaptiveStyle.desktop: AdaptiveStyle.desktop,
  };

  for (final entry in cases.entries) {
    testWidgets('Override ${entry.key.name} makes adaptiveStyleOf return it '
        'inside and leaves it unchanged outside', (tester) async {
      late AdaptiveStyle outside;
      late AdaptiveStyle inside;
      await tester.pumpWidget(
        MaterialApp(
          theme: SprintTheme.light.copyWith(platform: TargetPlatform.iOS),
          home: Column(
            children: [
              Builder(
                builder: (context) {
                  outside = adaptiveStyleOf(context);
                  return AdaptivePlatformOverride(
                    style: entry.key,
                    child: Builder(
                      builder: (context) {
                        inside = adaptiveStyleOf(context);
                        return const SizedBox();
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
      expect(inside, entry.value);
      expect(outside, AdaptiveStyle.apple);
    });
  }
}
