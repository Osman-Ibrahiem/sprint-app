import 'dart:ui' show Tristate;

import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/features/catalogue/presentation/facilities/facility_not_found.dart';
import 'package:sprint/features/catalogue/presentation/home/home_screen.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('/facilities resolves and keeps the facilities tab selected', (
    tester,
  ) async {
    await pumpSprintApp(tester);
    routerOf(tester).go(AppPaths.facilities);
    await tester.pumpAndSettle();

    expect(currentPath(tester), AppPaths.facilities);
    final semantics = tester.getSemantics(find.text(ar.navFacilities));
    expect(semantics.flagsCollection.isSelected, Tristate.isTrue);
  });

  testWidgets('a facility id resolves to its details', (tester) async {
    await pumpSprintApp(tester);
    routerOf(tester).go(AppPaths.facilityDetails(SeedIds.poolFacility));
    await tester.pumpAndSettle();

    expect(currentPath(tester), AppPaths.facilityDetails(SeedIds.poolFacility));
    expect(find.text('حمام السباحة الأولمبي'), findsWidgets);
    final semantics = tester.getSemantics(find.text(ar.navFacilities));
    expect(semantics.flagsCollection.isSelected, Tristate.isTrue);
  });

  testWidgets('a wrong facility id shows the friendly not-found screen', (
    tester,
  ) async {
    await pumpSprintApp(tester);
    routerOf(tester).go('/facilities/nope');
    await tester.pumpAndSettle();

    expect(find.byType(FacilityNotFound), findsOneWidget);
    expect(find.text(ar.catalogueFacilityNotFoundTitle), findsWidgets);
  });

  testWidgets('the other destinations still resolve', (tester) async {
    await pumpSprintApp(tester);

    routerOf(tester).go(AppPaths.home);
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);

    routerOf(tester).go(AppPaths.bookings);
    await tester.pumpAndSettle();
    expect(currentPath(tester), AppPaths.bookings);

    routerOf(tester).go(AppPaths.profile);
    await tester.pumpAndSettle();
    expect(currentPath(tester), AppPaths.profile);
  });

  testWidgets('the details deep link survives a rebuild of the app', (
    tester,
  ) async {
    await pumpSprintApp(tester);
    routerOf(tester).go(AppPaths.facilityDetails(SeedIds.gymFacility));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('صالة اللياقة البدنية'), findsWidgets);
  });
}
