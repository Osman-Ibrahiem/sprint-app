import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/adaptive/adaptive_sheet.dart';

import '../../helpers/adaptive_harness.dart';

void main() {
  String? result;

  Future<void> open(WidgetTester tester) async {
    result = 'unset';
    await pumpHarness(
      tester,
      (context) => TextButton(
        onPressed: () async {
          result = await showSprintSheet<String>(
            context: context,
            title: 'إجراءات',
            actions: const [
              SprintSheetAction(label: 'مشاركة', value: 'share'),
              SprintSheetAction(label: 'حذف', value: 'delete', isDestructive: true),
            ],
            cancelLabel: 'إغلاق',
          );
        },
        child: const Text('open'),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('the sheet type follows the platform', (tester) async {
    final platform = debugDefaultTargetPlatformOverride!;
    await open(tester);
    expect(find.text('مشاركة'), findsOneWidget);
    if (isApple(platform)) {
      expect(find.byType(CupertinoActionSheet), findsOneWidget);
    } else if (isDesktop(platform)) {
      expect(find.byType(PopupMenuItem<String>), findsNWidgets(2));
      expect(find.byType(BottomSheet), findsNothing);
    } else {
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.byType(CupertinoActionSheet), findsNothing);
    }
  }, variant: allPlatforms);

  testWidgets('choosing an action returns its value', (tester) async {
    await open(tester);
    await tester.tap(find.text('مشاركة'));
    await tester.pumpAndSettle();
    expect(result, 'share');
  }, variant: allPlatforms);

  testWidgets('Esc closes the menu on desktop', (tester) async {
    await open(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(result, isNull);
    expect(find.text('مشاركة'), findsNothing);
  }, variant: const TargetPlatformVariant({
    TargetPlatform.windows,
    TargetPlatform.linux,
  }));

  testWidgets('Esc closes the bottom sheet on Android with a keyboard',
      (tester) async {
    await open(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(result, isNull);
    expect(find.text('مشاركة'), findsNothing);
  }, variant: const TargetPlatformVariant({TargetPlatform.android}));
}
