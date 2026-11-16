import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/presentation/facilities/facility_filter_bar.dart';
import 'package:sprint/features/catalogue/presentation/facilities/facility_list_view.dart';
import 'package:sprint/features/catalogue/presentation/providers/catalogue_providers.dart';

import '../../../helpers/pump_app.dart';

Future<void> open(
  WidgetTester tester, {
  Size size = const Size(400, 900),
}) async {
  await pumpSprintApp(tester, size: size);
  routerOf(tester).go('/facilities');
  await tester.pumpAndSettle();
}

Future<void> tapKey(WidgetTester tester, Key key) async {
  await tester.ensureVisible(find.byKey(key));
  await tester.tap(find.byKey(key));
  await tester.pumpAndSettle();
}

Finder count(String text) => find.text(text);

void main() {
  testWidgets('shows every published facility on open', (tester) async {
    await open(tester, size: const Size(400, 2400));
    expect(find.text(ar.catalogueResultCount(6)), findsOneWidget);
    for (final id in [
      SeedIds.poolFacility,
      SeedIds.hallFacility,
      SeedIds.academyFacility,
    ]) {
      expect(find.byKey(FacilityListView.cardKey(id)), findsOneWidget);
    }
  });

  testWidgets('type, unit and free filters work alone and combined', (
    tester,
  ) async {
    await open(tester, size: const Size(400, 2400));
    await tapKey(tester, FacilityFilterBar.typeKey(FacilityType.tennis));
    expect(find.text(ar.catalogueResultCount(1)), findsOneWidget);

    await tapKey(tester, FacilityFilterBar.typeKey(null));
    await tapKey(tester, FacilityFilterBar.unitKey(SeedIds.ouPe));
    expect(find.text(ar.catalogueResultCount(3)), findsOneWidget);

    await tapKey(tester, FacilityFilterBar.unitKey(null));
    await tapKey(tester, FacilityFilterBar.freeKey(true));
    expect(find.text(ar.catalogueResultCount(1)), findsOneWidget);
    expect(
      find.byKey(FacilityListView.cardKey(SeedIds.hallFacility)),
      findsOneWidget,
    );

    // AND: PE faculty + free matches nothing.
    await tapKey(tester, FacilityFilterBar.unitKey(SeedIds.ouPe));
    expect(find.byKey(FacilityListView.emptyKey), findsOneWidget);
  });

  testWidgets('active filters are removable chips and clear all resets', (
    tester,
  ) async {
    await open(tester, size: const Size(400, 2400));
    await tapKey(tester, FacilityFilterBar.typeKey(FacilityType.gym));
    final chip = FacilityFilterBar.activeKey(ar.catalogueTypeGym);
    expect(find.byKey(chip), findsOneWidget);
    await tapKey(tester, chip);
    expect(find.byKey(chip), findsNothing);
    expect(find.text(ar.catalogueResultCount(6)), findsOneWidget);

    await tapKey(tester, FacilityFilterBar.freeKey(false));
    await tapKey(tester, FacilityFilterBar.clearAllKey);
    expect(find.byKey(FacilityFilterBar.clearAllKey), findsNothing);
    expect(find.text(ar.catalogueResultCount(6)), findsOneWidget);
  });

  testWidgets('empty state names the filters and offers a clear action', (
    tester,
  ) async {
    await open(tester, size: const Size(400, 2400));
    await tapKey(tester, FacilityFilterBar.typeKey(FacilityType.tennis));
    await tapKey(tester, FacilityFilterBar.freeKey(true));
    expect(find.byKey(FacilityListView.emptyKey), findsOneWidget);
    expect(find.text(ar.catalogueEmptyTitle), findsOneWidget);
    expect(
      find.text(
        ar.catalogueEmptyBody(
          '${ar.catalogueTypeTennis} + ${ar.catalogueFilterFree}',
        ),
      ),
      findsOneWidget,
    );
    await tester.tap(find.text(ar.catalogueEmptyClear));
    await tester.pumpAndSettle();
    expect(find.byKey(FacilityListView.emptyKey), findsNothing);
  });

  testWidgets('free and trainer tags appear as words', (tester) async {
    await open(tester, size: const Size(400, 2400));
    expect(find.text(ar.catalogueTagFree), findsWidgets);
    expect(find.text(ar.catalogueTagTrainer), findsWidgets);
  });

  testWidgets('medium and larger show a multi-column grid', (tester) async {
    await open(tester, size: const Size(1600, 1600));
    final a = tester.getTopLeft(
      find.byKey(FacilityListView.cardKey(SeedIds.poolFacility)),
    );
    final b = tester.getTopLeft(
      find.byKey(FacilityListView.cardKey(SeedIds.futsalFacility)),
    );
    expect(a.dy, b.dy);
    expect(a.dx, isNot(b.dx));
  });

  testWidgets('filter notifier is shared state', (tester) async {
    await open(tester);
    containerOf(tester).read(facilityFilterProvider.notifier).setFree(true);
    await tester.pumpAndSettle();
    expect(
      find.byKey(FacilityFilterBar.activeKey(ar.catalogueFilterFree)),
      findsOneWidget,
    );
  });
}
