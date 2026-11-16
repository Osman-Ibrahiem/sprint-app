import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/domain/home_content.dart';
import 'package:sprint/features/catalogue/presentation/facilities/facilities_screen.dart';
import 'package:sprint/features/catalogue/presentation/facilities/facility_filter_bar.dart';
import 'package:sprint/features/catalogue/presentation/providers/catalogue_providers.dart';
import 'package:sprint/features/catalogue/presentation/widgets/catalogue_error_view.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('home: a failure shows the error view and retry reloads', (
    tester,
  ) async {
    var calls = 0;
    await pumpSprintApp(
      tester,
      overrides: [
        homeContentProvider.overrideWith((ref) async {
          if (calls++ == 0) throw StateError('انقطاع');
          return const HomeContent(types: [], featured: []);
        }),
      ],
    );
    expect(find.byType(CatalogueErrorView), findsOneWidget);
    await tester.tap(find.text(ar.catalogueRetry));
    await tester.pumpAndSettle();
    expect(find.byType(CatalogueErrorView), findsNothing);
    expect(currentPath(tester), '/home');
  });

  testWidgets('list: a failure shows the error view and retry reloads', (
    tester,
  ) async {
    var calls = 0;
    await pumpSprintApp(
      tester,
      size: const Size(400, 2000),
      overrides: [
        facilitySummariesProvider.overrideWith((ref) async {
          if (calls++ == 0) throw StateError('انقطاع');
          return [];
        }),
      ],
    );
    routerOf(tester).go('/facilities');
    await tester.pumpAndSettle();
    expect(find.byType(CatalogueErrorView), findsOneWidget);
    await tester.tap(find.text(ar.catalogueRetry));
    await tester.pumpAndSettle();
    expect(find.byType(CatalogueErrorView), findsNothing);
    expect(currentPath(tester), '/facilities');
  });

  testWidgets('details: a failure shows the error view and retry reloads', (
    tester,
  ) async {
    var calls = 0;
    await pumpSprintApp(
      tester,
      overrides: [
        facilityDetailsProvider.overrideWith((ref, id) async {
          if (calls++ == 0) throw StateError('انقطاع');
          return null;
        }),
      ],
    );
    routerOf(tester).go('/facilities/${SeedIds.poolFacility}');
    await tester.pumpAndSettle();
    expect(find.byType(CatalogueErrorView), findsOneWidget);
    await tester.tap(find.text(ar.catalogueRetry));
    await tester.pumpAndSettle();
    expect(find.byType(CatalogueErrorView), findsNothing);
    expect(currentPath(tester), '/facilities/${SeedIds.poolFacility}');
  });

  const hinge = Rect.fromLTWH(490, 0, 20, 900);
  const feature = ui.DisplayFeature(
    bounds: hinge,
    type: ui.DisplayFeatureType.hinge,
    state: ui.DisplayFeatureState.postureHalfOpened,
  );

  testWidgets(
    'a vertical hinge keeps the list and the pane on their own sides',
    (tester) async {
      await pumpSprintApp(
        tester,
        size: const Size(1000, 900),
        features: const [feature],
      );
      routerOf(tester).go('/facilities/${SeedIds.poolFacility}');
      await tester.pumpAndSettle();
      // The shell gives each side of the hinge its own width class, so the
      // screen may show one pane or two. Whatever shows stays on one side.
      for (final key in [
        FacilitiesScreen.listSlotKey,
        FacilitiesScreen.detailsSlotKey,
      ]) {
        final slot = find.byKey(key);
        if (slot.evaluate().isEmpty) continue;
        final rect = tester.getRect(slot);
        expect(rect.overlaps(hinge), isFalse, reason: '$key at $rect');
      }
      expect(find.byKey(FacilitiesScreen.detailsSlotKey), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('folding and unfolding keeps the filter and the selection', (
    tester,
  ) async {
    await pumpSprintApp(tester, size: const Size(1000, 900));
    routerOf(tester).go('/facilities/${SeedIds.gymFacility}');
    await tester.pumpAndSettle();
    final c = containerOf(tester);
    c.read(facilityFilterProvider.notifier).setType(FacilityType.gym);
    await tester.pumpAndSettle();

    setWindow(tester, size: const Size(1000, 900), features: const [feature]);
    await tester.pumpAndSettle();
    expect(c.read(facilityFilterProvider).type, FacilityType.gym);
    expect(currentPath(tester), '/facilities/${SeedIds.gymFacility}');

    setWindow(tester, size: const Size(1000, 900));
    await tester.pumpAndSettle();
    expect(c.read(facilityFilterProvider).type, FacilityType.gym);
    expect(currentPath(tester), '/facilities/${SeedIds.gymFacility}');
    expect(
      find.byKey(FacilityFilterBar.typeKey(FacilityType.gym)),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
