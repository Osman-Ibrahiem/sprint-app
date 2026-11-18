import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/adaptive/adaptive_dialog.dart';
import 'package:sprint/core/widgets/wide_dialog/wide_dialog.dart';

import '../../helpers/adaptive_harness.dart';

void main() {
  String? result;

  Future<void> open(
    WidgetTester tester, {
    Size size = const Size(400, 800),
  }) async {
    result = 'unset';
    await pumpHarness(
      tester,
      size: size,
      (context) => TextButton(
        onPressed: () async {
          result = await showSprintDialog<String>(
            context: context,
            title: 'تأكيد',
            message: 'رسالة',
            actions: const [
              SprintDialogAction(label: 'تراجع', value: 'cancel'),
              SprintDialogAction(
                label: 'حذف',
                value: 'delete',
                isDestructive: true,
              ),
              SprintDialogAction(
                label: 'موافقة',
                value: 'ok',
                isDefault: true,
              ),
            ],
          );
        },
        child: const Text('open'),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('the dialog type follows the platform', (tester) async {
    final platform = debugDefaultTargetPlatformOverride!;
    await open(tester);
    expect(find.text('رسالة'), findsOneWidget);
    if (isApple(platform)) {
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
    } else {
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byType(CupertinoAlertDialog), findsNothing);
      expect(
        find.byKey(const ValueKey('sprint-dialog-desktop')),
        isDesktop(platform) ? findsOneWidget : findsNothing,
      );
    }
  }, variant: allPlatforms);

  testWidgets('tapping an action returns its value', (tester) async {
    await open(tester);
    await tester.tap(find.text('حذف'));
    await tester.pumpAndSettle();
    expect(result, 'delete');
    expect(find.text('رسالة'), findsNothing);
  }, variant: allPlatforms);

  testWidgets('on desktop Enter confirms the default and Esc cancels',
      (tester) async {
    await open(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(result, 'ok');

    await open(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(result, isNull);
    expect(find.text('رسالة'), findsNothing);
  }, variant: const TargetPlatformVariant({
    TargetPlatform.windows,
    TargetPlatform.linux,
  }));

  testWidgets('a destructive action is coloured and still has a word',
      (tester) async {
    await open(tester);
    expect(find.text('حذف'), findsOneWidget);
  }, variant: allPlatforms);

  testWidgets('from the medium class every platform shows the wide dialog, '
      'destructive action first, Escape closes', (tester) async {
    await open(tester, size: const Size(800, 900));
    expect(find.byType(WideDialog), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(CupertinoAlertDialog), findsNothing);
    final del = tester.getTopLeft(find.text('حذف'));
    final cancel = tester.getTopLeft(find.text('تراجع'));
    // Destructive is first in reading order (to the right in RTL).
    expect(del.dx, greaterThan(cancel.dx));
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(WideDialog), findsNothing);
    expect(result, isNull);
  }, variant: allPlatforms);
}
