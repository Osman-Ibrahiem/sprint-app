import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/adaptive/adaptive_haptics.dart';
import 'package:sprint/core/theme/sprint_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a selection haptic is requested on Apple', (tester) async {
    final calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        calls.add(call);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: SprintTheme.light.copyWith(platform: TargetPlatform.iOS),
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () => AdaptiveHaptics.selection(context),
              child: const Text('x'),
            );
          },
        ),
      ),
    );
    await tester.tap(find.byType(TextButton));
    expect(
      calls.where((c) =>
          c.method == 'HapticFeedback.vibrate' &&
          c.arguments == 'HapticFeedbackType.selectionClick'),
      hasLength(1),
    );
  });

  testWidgets('a selection haptic is requested on Android', (tester) async {
    final calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        calls.add(call);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: SprintTheme.light.copyWith(platform: TargetPlatform.android),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => AdaptiveHaptics.selection(context),
            child: const Text('x'),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(TextButton));
    expect(
      calls.where((c) => c.method == 'HapticFeedback.vibrate'),
      hasLength(1),
    );
  });

  testWidgets('none on desktop, and no throw when the channel is unhandled',
      (tester) async {
    final calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        calls.add(call);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: SprintTheme.light.copyWith(platform: TargetPlatform.windows),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => AdaptiveHaptics.selection(context),
            child: const Text('x'),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(TextButton));
    expect(calls.where((c) => c.method == 'HapticFeedback.vibrate'), isEmpty);
  });

}
