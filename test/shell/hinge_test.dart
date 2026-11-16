import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/l10n/locale_notifier.dart';
import 'package:sprint/core/widgets/app_navigation/sprint_nav_rail.dart';
import 'package:sprint/core/widgets/app_navigation/sprint_sidebar.dart';
import 'package:sprint/core/widgets/app_navigation/sprint_tab_bar.dart';

import '../helpers/pump_app.dart';

void main() {
  /// The part of [node] that is actually painted: its rect cut by every
  /// ancestor clip (a scrolled row's offscreen children do not sit on a
  /// hinge). The test cares about what a person can see.
  Rect visibleRect(RenderObject node) {
    final box = node as RenderBox;
    var rect = box.localToGlobal(Offset.zero) & box.size;
    RenderObject child = node;
    var parent = node.parent;
    while (parent != null) {
      final clip = parent.describeApproximatePaintClip(child);
      if (clip != null) {
        final origin = MatrixUtils.transformPoint(
          child.getTransformTo(null),
          clip.topLeft,
        );
        rect = rect.intersect(origin & clip.size);
        if (rect.isEmpty) return rect;
      }
      child = parent;
      parent = parent.parent;
    }
    return rect;
  }

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
        final rect = visibleRect(element.renderObject!);
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
        final rect = visibleRect(element.renderObject!);
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
      final rect = visibleRect(element.renderObject!);
      expect(rect.overlaps(hinge), isFalse, reason: 'text at $rect');
    }
    // The first pane is on the left in English: content sits before the hinge.
    expect(
      tester.getRect(find.byType(SprintTabBar)).right,
      lessThanOrEqualTo(hinge.left),
    );
  });

  testWidgets('folding keeps the open facility and its route', (tester) async {
    await pumpSprintApp(tester, size: const Size(800, 800));
    routerOf(tester).go('/facilities/f-pool');
    await tester.pumpAndSettle();
    expect(find.text('حمام السباحة الأولمبي'), findsWidgets);

    // Fold: a hinge appears.
    tester.view.displayFeatures = const [
      DisplayFeature(
        bounds: Rect.fromLTWH(390, 0, 20, 800),
        type: DisplayFeatureType.hinge,
        state: DisplayFeatureState.postureHalfOpened,
      ),
    ];
    await tester.pumpAndSettle();
    expect(find.text('حمام السباحة الأولمبي'), findsWidgets,
        reason: 'the facility is kept after folding');
    expect(currentPath(tester), '/facilities/f-pool');

    // Unfold: the hinge goes away.
    tester.view.displayFeatures = const [];
    await tester.pumpAndSettle();
    expect(find.text('حمام السباحة الأولمبي'), findsWidgets,
        reason: 'the facility is kept after unfolding');
    expect(currentPath(tester), '/facilities/f-pool');
  });
}
