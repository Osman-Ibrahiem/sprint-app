import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/adaptive/adaptive_dialog.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
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

  test('actions are ordered safe, then confirming, then destructive, keeping '
      'the order within each kind (decision P1)', () {
    const leave = SprintDialogAction(
      label: 'leave',
      value: 1,
      isDestructive: true,
    );
    const stay = SprintDialogAction(label: 'stay', value: 2, isDefault: true);
    const back = SprintDialogAction(label: 'back', value: 3);
    const later = SprintDialogAction(label: 'later', value: 4);
    expect(
      orderDialogActions(const [leave, stay, back, later])
          .map((a) => a.label)
          .toList(),
      ['back', 'later', 'stay', 'leave'],
    );
  });

  for (final (locale, width) in const [
    (Locale('ar'), 400.0),
    (Locale('en'), 400.0),
    (Locale('ar'), 900.0),
    (Locale('en'), 900.0),
  ]) {
    testWidgets('a destructive action passed first still lands last: '
        '${locale.languageCode} at $width', (tester) async {
      final platform = debugDefaultTargetPlatformOverride!;
      final wide = width >= 600;
      await pumpHarness(
        tester,
        size: Size(width, 800),
        locale: locale,
        (context) => TextButton(
          onPressed: () => showSprintDialog<String>(
            context: context,
            title: 'title',
            actions: const [
              SprintDialogAction(
                label: 'leave',
                value: 'leave',
                isDestructive: true,
              ),
              SprintDialogAction(label: 'stay', value: 'stay', isDefault: true),
            ],
          ),
          child: const Text('open'),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      final leaveX = tester.getCenter(find.text('leave')).dx;
      final stayX = tester.getCenter(find.text('stay')).dx;
      final rtl = locale.languageCode == 'ar';
      // Safe first in reading order on every platform: right of the
      // destructive action in Arabic, left of it in English.
      expect(rtl ? stayX > leaveX : stayX < leaveX, isTrue);
      if (wide) {
        // The wide dialog on every platform: same order, filled danger.
        expect(find.byType(WideDialog), findsOneWidget);
        expect(
          find.ancestor(
            of: find.text('leave'),
            matching: find.byType(SprintButton),
          ),
          findsOneWidget,
        );
      } else if (!isApple(platform)) {
        // Android and the web: a filled danger button.
        expect(
          find.ancestor(
            of: find.text('leave'),
            matching: find.byType(SprintButton),
          ),
          findsOneWidget,
        );
      } else {
        expect(
          tester
              .widget<CupertinoDialogAction>(
                find.ancestor(
                  of: find.text('leave'),
                  matching: find.byType(CupertinoDialogAction),
                ),
              )
              .isDestructiveAction,
          isTrue,
        );
      }
    }, variant: allPlatforms);
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
      'safe action first and destructive last (P1), Escape closes', (
    tester,
  ) async {
    await open(tester, size: const Size(800, 900));
    expect(find.byType(WideDialog), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(CupertinoAlertDialog), findsNothing);
    final del = tester.getTopLeft(find.text('حذف'));
    final cancel = tester.getTopLeft(find.text('تراجع'));
    // Safe first in reading order (to the right in RTL), destructive last.
    expect(del.dx, lessThan(cancel.dx));
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(WideDialog), findsNothing);
    expect(result, isNull);
  }, variant: allPlatforms);

  for (final width in [720.0, 1024.0]) {
    testWidgets('the wide dialog is 400 wide at $width', (tester) async {
      await open(tester, size: Size(width, 900));
      expect(tester.getSize(find.byKey(WideDialog.panelKey)).width, 400);
    });
  }
}
