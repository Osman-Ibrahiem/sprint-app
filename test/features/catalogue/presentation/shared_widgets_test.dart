import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/features/catalogue/presentation/widgets/catalogue_error_view.dart';
import 'package:sprint/features/catalogue/presentation/widgets/section_card.dart';

import '../../../helpers/widget_harness.dart';

void main() {
  testWidgets('section card renders its title and its child', (tester) async {
    await pumpWidgetUnder(
      tester,
      const SectionCard(
        title: 'المعادن',
        child: Text('محتوى القسم'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('المعادن'), findsOneWidget);
    expect(find.text('محتوى القسم'), findsOneWidget);
  });

  testWidgets('section card shows an optional trailing control', (tester) async {
    await pumpWidgetUnder(
      tester,
      const SectionCard(
        title: 'الأوقات',
        trailing: Icon(Icons.info_outline),
        child: Text('محتوى'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
  });

  testWidgets('the error view renders and its retry fires', (tester) async {
    var retried = 0;
    await pumpWidgetUnder(
      tester,
      CatalogueErrorView(onRetry: () => retried++),
    );
    await tester.pumpAndSettle();

    expect(find.text('حصلت مشكلة'), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsOneWidget);

    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();
    expect(retried, 1);
  });

  testWidgets('the retry touch target is at least 48dp', (tester) async {
    await pumpWidgetUnder(
      tester,
      CatalogueErrorView(onRetry: () {}),
    );
    await tester.pumpAndSettle();
    final rect = tester.getRect(find.byType(SprintButton));
    expect(rect.height, greaterThanOrEqualTo(48));
  });
}
