import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/catalogue/presentation/facilities/facility_not_found.dart';

import '../../../helpers/widget_harness.dart';

void main() {
  testWidgets('the not-found screen shows a title, a body and a way back',
      (tester) async {
    await pumpWidgetUnder(tester, const FacilityNotFound());
    await tester.pumpAndSettle();

    expect(find.byKey(FacilityNotFound.containerKey), findsOneWidget);
    expect(find.text('المنشأة مش موجودة'), findsOneWidget);
    expect(find.textContaining('الرابط'), findsOneWidget);
    expect(find.text('الرجوع للمنشآت'), findsOneWidget);
  });
}
