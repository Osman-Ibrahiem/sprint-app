import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/l10n/locale_notifier.dart';
import 'package:sprint/app/shell/nav/sprint_nav_rail.dart';
import 'package:sprint/app/shell/nav/sprint_sidebar.dart';
import 'package:sprint/app/shell/nav/sprint_tab_bar.dart';

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

  testWidgets('a split screen uses the pane width for its navigation',
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
    // Each pane is 390 wide, so the shell shows the compact tab bar, not the
    // rail or sidebar an 800-wide window would get.
    expect(find.byType(SprintTabBar), findsOneWidget);
    expect(find.byType(SprintSidebar), findsNothing);
    expect(find.byType(SprintNavRail), findsNothing);
  });

  testWidgets('a flat fold does not split the screen', (tester) async {
    await pumpSprintApp(
      tester,
      size: const Size(800, 800),
      features: const [
        DisplayFeature(
          bounds: Rect.fromLTWH(390, 0, 20, 800),
          type: DisplayFeatureType.fold,
          state: DisplayFeatureState.postureFlat,
        ),
      ],
    );
    expect(find.byType(SprintNavRail), findsOneWidget);
    expect(find.byType(SprintTabBar), findsNothing);
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

  testWidgets('a tabletop (horizontal) hinge keeps everything off it',
      (tester) async {
    const hinge = Rect.fromLTWH(0, 390, 800, 20);
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
    for (final finder in [
      find.byType(Text),
      find.byType(Icon),
      find.byType(InkWell),
      find.byType(Scrollable),
    ]) {
      for (final element in finder.evaluate()) {
        final box = element.renderObject! as RenderBox;
        final rect = box.localToGlobal(Offset.zero) & box.size;
        expect(rect.overlaps(hinge), isFalse,
            reason: '${element.widget.runtimeType} at $rect overlaps the hinge');
      }
    }
    expect(find.text(ar.navHome), findsWidgets);
  });

  testWidgets('a vertical hinge also works left-to-right (English)',
      (tester) async {
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
    await containerOf(tester)
        .read(localeProvider.notifier)
        .set(const Locale('en'));
    await tester.pumpAndSettle();
    for (final element in find.byType(Text).evaluate()) {
      final box = element.renderObject! as RenderBox;
      final rect = box.localToGlobal(Offset.zero) & box.size;
      expect(rect.overlaps(hinge), isFalse, reason: 'text at $rect');
    }
    // The first pane is on the left in English: content sits before the hinge.
    expect(
      tester.getRect(find.byType(SprintTabBar)).right,
      lessThanOrEqualTo(hinge.left),
    );
  });

  testWidgets('folding mid-typing keeps the text and the focus',
      (tester) async {
    await pumpSprintApp(tester, size: const Size(800, 800));
    routerOf(tester).go('/facilities');
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'حمام');
    await tester.pumpAndSettle();

    bool focused() =>
        tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus;
    expect(focused(), isTrue);

    // Fold: a hinge appears.
    tester.view.displayFeatures = const [
      DisplayFeature(
        bounds: Rect.fromLTWH(390, 0, 20, 800),
        type: DisplayFeatureType.hinge,
        state: DisplayFeatureState.postureHalfOpened,
      ),
    ];
    await tester.pumpAndSettle();
    expect(find.text('حمام'), findsOneWidget);
    expect(focused(), isTrue, reason: 'focus kept after folding');

    // Unfold: the hinge goes away.
    tester.view.displayFeatures = const [];
    await tester.pumpAndSettle();
    expect(find.text('حمام'), findsOneWidget);
    expect(focused(), isTrue, reason: 'focus kept after unfolding');
    expect(currentPath(tester), '/facilities');
  });
}
