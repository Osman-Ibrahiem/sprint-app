import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('no text or control sits on a vertical hinge', (tester) async {
    const hinge = Rect.fromLTWH(390, 0, 20, 800);
    await pumpSprintApp(
      tester,
      size: const Size(800, 800),
      features: const [
        DisplayFeature(
          bounds: hinge,
          type: DisplayFeatureType.hinge,
          state: DisplayFeatureState.postureHalfOpened,
        ),
      ],
    );

    final candidates = <Finder>[
      find.byType(Text),
      find.byType(Icon),
      find.byType(TextField),
      find.byType(InkResponse),
      find.byType(InkWell),
    ];
    for (final finder in candidates) {
      for (final element in finder.evaluate()) {
        final box = element.renderObject! as RenderBox;
        final rect = box.localToGlobal(Offset.zero) & box.size;
        expect(
          rect.overlaps(hinge),
          isFalse,
          reason: '${element.widget.runtimeType} at $rect overlaps the hinge',
        );
      }
    }
  });

  testWidgets('navigation stays reachable and content is not empty',
      (tester) async {
    await pumpSprintApp(
      tester,
      size: const Size(800, 800),
      features: const [
        DisplayFeature(
          bounds: Rect.fromLTWH(390, 0, 20, 800),
          type: DisplayFeatureType.hinge,
          state: DisplayFeatureState.postureHalfOpened,
        ),
      ],
    );
    expect(find.text(ar.navHome), findsWidgets);
    expect(find.byType(Text), findsWidgets);
  });
}
