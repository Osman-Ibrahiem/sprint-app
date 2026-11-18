import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';

import '../../helpers/widget_harness.dart';

/// Walk 2026-11-18 (design QA): the main action of a bottom bar or a form is
/// as wide as its column, as the design draws it; every other button still
/// wraps its label.
void main() {
  testWidgets('expand fills the width it is given; the default wraps', (
    tester,
  ) async {
    const full = ValueKey<String>('full');
    const hug = ValueKey<String>('hug');
    await pumpWidgetUnderAndSettle(
      tester,
      SizedBox(
        width: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SprintButton(key: full, label: 'الدفع', expand: true, onPressed: () {}),
            SprintButton(key: hug, label: 'الدفع', onPressed: () {}),
          ],
        ),
      ),
    );
    double visual(Key k) => tester
        .getSize(
          find.descendant(
            of: find.byKey(k),
            matching: find.byKey(SprintButton.visualKey),
          ),
        )
        .width;
    expect(visual(full), 300);
    expect(visual(hug), lessThan(300));
  });
}
