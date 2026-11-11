import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/shell/placeholders/facilities_placeholder.dart';

import '../helpers/pump_app.dart';

void main() {
  const widths = <double>[400, 700, 900, 1300];

  testWidgets('destination, typed text and scroll offset survive every resize',
      (tester) async {
    await pumpSprintApp(tester, size: const Size(400, 800));

    // Go to Facilities, type in its field and scroll its list.
    routerOf(tester).go('/facilities');
    await tester.pumpAndSettle();
    final scroller = find
        .descendant(
          of: find.byType(FacilitiesPlaceholder),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.enterText(find.byType(TextField), 'حمام');
    await tester.drag(scroller, const Offset(0, -300));
    await tester.pumpAndSettle();

    double offset() =>
        tester.state<ScrollableState>(scroller).position.pixels;
    final before = offset();
    expect(before, greaterThan(0));

    // Cross every boundary up and down (400 -> 700 -> 900 -> 1300 -> 400).
    for (final w in [...widths.skip(1), widths.first]) {
      tester.view.physicalSize = Size(w, 800);
      await tester.pumpAndSettle();
      expect(currentPath(tester), '/facilities', reason: 'width $w');
      expect(find.byType(FacilitiesPlaceholder), findsOneWidget);
      expect(find.text('حمام'), findsOneWidget, reason: 'text kept at $w');
      expect(offset(), before, reason: 'scroll kept at $w');
    }
  });

  testWidgets('the selected destination stays selected across resizes',
      (tester) async {
    await pumpSprintApp(tester, size: const Size(400, 800));
    routerOf(tester).go('/bookings');
    await tester.pumpAndSettle();

    for (final w in [700.0, 900.0, 1300.0, 400.0]) {
      tester.view.physicalSize = Size(w, 800);
      await tester.pumpAndSettle();
      expect(currentPath(tester), '/bookings', reason: 'width $w');
      expect(find.text(ar.signInPromptTitle), findsOneWidget);
    }
  });
}
