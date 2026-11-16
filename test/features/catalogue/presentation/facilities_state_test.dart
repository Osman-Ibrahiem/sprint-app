import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/presentation/facilities/facilities_screen.dart';
import 'package:sprint/features/catalogue/presentation/facilities/facility_filter_bar.dart';
import 'package:sprint/features/catalogue/presentation/facilities/facility_list_view.dart';
import 'package:sprint/features/catalogue/presentation/providers/catalogue_providers.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('filter and scroll survive opening a facility and going back', (
    tester,
  ) async {
    await pumpSprintApp(tester, size: const Size(400, 500));
    final router = routerOf(tester)..go('/facilities');
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(FacilityFilterBar.freeKey(false)));
    await tester.tap(find.byKey(FacilityFilterBar.freeKey(false)));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    final container = containerOf(tester);
    final offset = container.read(facilitiesListScrollOffsetProvider);
    expect(offset, greaterThan(0));

    router.go('/facilities/${SeedIds.poolFacility}');
    await tester.pumpAndSettle();
    expect(find.byKey(FacilitiesScreen.listSlotKey), findsNothing);

    router.go('/facilities');
    await tester.pumpAndSettle();
    expect(container.read(facilityFilterProvider).free, false);
    final scroll = tester.widget<CustomScrollView>(
      find.byType(CustomScrollView).first,
    );
    expect(scroll.controller!.offset, offset);
  });

  testWidgets('resize keeps the selected facility and the filter', (
    tester,
  ) async {
    await pumpSprintApp(tester, size: const Size(400, 900));
    routerOf(tester).go('/facilities/${SeedIds.gymFacility}');
    await tester.pumpAndSettle();
    containerOf(tester)
        .read(facilityFilterProvider.notifier)
        .setType(FacilityType.gym);
    await tester.pumpAndSettle();

    setWindow(tester, size: const Size(1000, 900));
    await tester.pumpAndSettle();
    expect(find.byKey(FacilitiesScreen.listSlotKey), findsOneWidget);
    expect(find.byKey(FacilitiesScreen.detailsSlotKey), findsOneWidget);
    expect(currentPath(tester), '/facilities/${SeedIds.gymFacility}');

    setWindow(tester, size: const Size(400, 900));
    await tester.pumpAndSettle();
    expect(find.byKey(FacilitiesScreen.listSlotKey), findsNothing);
    expect(find.byKey(FacilitiesScreen.detailsSlotKey), findsOneWidget);
    expect(currentPath(tester), '/facilities/${SeedIds.gymFacility}');
    expect(
      containerOf(tester).read(facilityFilterProvider).type,
      FacilityType.gym,
    );
  });

  testWidgets('tap at 1000px keeps the list; at 400px opens details alone', (
    tester,
  ) async {
    await pumpSprintApp(tester, size: const Size(1000, 1800));
    routerOf(tester).go('/facilities');
    await tester.pumpAndSettle();
    var card = find.byKey(FacilityListView.cardKey(SeedIds.poolFacility));
    await tester.ensureVisible(card);
    await tester.tap(card);
    await tester.pumpAndSettle();
    expect(find.byKey(FacilitiesScreen.listSlotKey), findsOneWidget);
    expect(find.byKey(FacilitiesScreen.detailsSlotKey), findsOneWidget);

    routerOf(tester).go('/facilities');
    setWindow(tester, size: const Size(400, 1800));
    await tester.pumpAndSettle();
    card = find.byKey(FacilityListView.cardKey(SeedIds.poolFacility));
    await tester.ensureVisible(card);
    await tester.tap(card);
    await tester.pumpAndSettle();
    expect(find.byKey(FacilitiesScreen.listSlotKey), findsNothing);
    expect(find.byKey(FacilitiesScreen.detailsSlotKey), findsOneWidget);
  });
}
