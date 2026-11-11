import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/adaptive/adaptive_dialog.dart';
import 'package:sprint/core/adaptive/adaptive_sheet.dart';
import 'package:sprint/core/l10n/locale_notifier.dart';

import '../../helpers/pump_app.dart';

/// Spec edge case: the user changes language while a dialog or sheet is open.
void main() {
  Future<void> switchLanguage(WidgetTester tester) async {
    await containerOf(tester)
        .read(localeProvider.notifier)
        .set(const Locale('en'));
    await tester.pumpAndSettle();
  }

  testWidgets('an open dialog closes when the language changes',
      (tester) async {
    await pumpSprintApp(tester);
    final context = tester.element(find.byType(Scaffold).first);
    showSprintDialog<void>(
      context: context,
      title: 'عنوان',
      message: 'رسالة',
      actions: const [SprintDialogAction(label: 'موافقة', isDefault: true)],
    );
    await tester.pumpAndSettle();
    expect(find.text('رسالة'), findsOneWidget);

    await switchLanguage(tester);
    expect(find.text('رسالة'), findsNothing);
    expect(tester.takeException(), isNull);
    expect(
      Directionality.of(tester.element(find.byType(Scaffold).first)),
      TextDirection.ltr,
    );
  });

  testWidgets('an open sheet closes when the language changes', (tester) async {
    await pumpSprintApp(tester);
    final context = tester.element(find.byType(Scaffold).first);
    showSprintSheet<void>(
      context: context,
      title: 'إجراءات',
      actions: const [SprintSheetAction(label: 'مشاركة')],
    );
    await tester.pumpAndSettle();
    expect(find.text('مشاركة'), findsOneWidget);

    await switchLanguage(tester);
    expect(find.text('مشاركة'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the page underneath stays where it was', (tester) async {
    await pumpSprintApp(tester);
    routerOf(tester).go('/profile');
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(Scaffold).first);
    showSprintDialog<void>(
      context: context,
      title: 't',
      actions: const [SprintDialogAction(label: 'ok')],
    );
    await tester.pumpAndSettle();
    await switchLanguage(tester);
    expect(currentPath(tester), '/profile');
    expect(find.text('ok'), findsNothing);
  });
}
