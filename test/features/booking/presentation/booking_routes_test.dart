import 'package:flutter/material.dart' show Size;
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';
import 'package:sprint/features/booking/presentation/schedule/schedule_screen.dart';
import 'package:sprint/features/catalogue/presentation/facilities/facilities_screen.dart';

import '../../../helpers/pump_app.dart';

/// Routes of the booking flow (contracts/routes.md).
void main() {
  final selection = ScheduleSelection(
    day: DateTime(2026, 11, 19),
    unitId: SeedIds.pool2,
    startMinutes: 18 * 60,
    endMinutes: 19 * 60,
  );
  final pool = SeedIds.poolFacility;

  testWidgets('the schedule route builds the schedule inside the shell', (
    tester,
  ) async {
    await pumpSprintApp(tester);
    routerOf(tester).go(AppPaths.facilitySchedule(pool));
    await tester.pumpAndSettle();

    expect(find.byType(ScheduleScreen), findsOneWidget);
    expect(currentPath(tester), AppPaths.facilitySchedule(pool));
    expect(find.text(ar.navFacilities), findsWidgets);
  });

  testWidgets('query parameters reach the screen as a selection', (
    tester,
  ) async {
    await pumpSprintApp(tester);
    routerOf(tester).go(AppPaths.facilitySchedule(pool, selection));
    await tester.pumpAndSettle();

    final screen = tester.widget<ScheduleScreen>(find.byType(ScheduleScreen));
    expect(screen.facilityId, pool);
    expect(screen.selection, selection);
  });

  testWidgets('paths are built from the selection, never by hand', (
    tester,
  ) async {
    expect(
      AppPaths.facilitySchedule(pool, selection),
      '/facilities/$pool/schedule?day=2026-11-19&unit=u-pool-2&start=1800&end=1900',
    );
    expect(
      AppPaths.bookingSummary(pool, selection, shown: 40),
      '/facilities/$pool/schedule/summary?day=2026-11-19&unit=u-pool-2&start=1800&end=1900&shown=40',
    );
    expect(
      AppPaths.bookingCheckout(pool, selection),
      '/facilities/$pool/schedule/checkout?day=2026-11-19&unit=u-pool-2&start=1800&end=1900',
    );
    expect(
      AppPaths.bookingDone(pool, 'bk-1'),
      '/facilities/$pool/schedule/done/bk-1',
    );
  });

  for (final path in [
    AppPaths.bookingSummary(pool, selection),
    AppPaths.bookingCheckout(pool, selection),
    AppPaths.bookingDone(pool, 'bk-1'),
  ]) {
    testWidgets('a guest opening $path is sent to sign in and back', (
      tester,
    ) async {
      await pumpSprintApp(tester);
      routerOf(tester).go(path);
      await tester.pumpAndSettle();

      final uri = routerOf(tester).routerDelegate.currentConfiguration.uri;
      expect(uri.path, AppPaths.signIn);
      expect(uri.queryParameters['from'], path);
    });
  }

  testWidgets('summary without a complete selection goes to the schedule', (
    tester,
  ) async {
    await pumpSprintApp(tester);
    await containerOf(tester)
        .read(sessionProvider.notifier)
        .actAs(SeedIds.bookerInternal);
    await tester.pumpAndSettle();

    final partial = ScheduleSelection(
      day: DateTime(2026, 11, 19),
      unitId: 'u-pool-2',
    );
    routerOf(tester).go(AppPaths.bookingSummary(pool, partial));
    await tester.pumpAndSettle();

    expect(currentPath(tester), AppPaths.facilitySchedule(pool));
    final uri = routerOf(tester).routerDelegate.currentConfiguration.uri;
    expect(uri.queryParameters, {'day': '2026-11-19', 'unit': 'u-pool-2'});
    expect(find.byType(ScheduleScreen), findsOneWidget);
  });

  testWidgets('a signed-in person reaches the summary, and the old checkout address lands there', (
    tester,
  ) async {
    await pumpSprintApp(tester);
    await containerOf(tester)
        .read(sessionProvider.notifier)
        .actAs(SeedIds.bookerInternal);
    await tester.pumpAndSettle();

    routerOf(tester).go(AppPaths.bookingSummary(pool, selection, shown: 20));
    await tester.pumpAndSettle();
    expect(
      currentPath(tester),
      AppPaths.bookingSummary(pool, selection).split('?').first,
    );

    // 005's checkout address now lands on the summary (feature 006).
    routerOf(tester).go(AppPaths.bookingCheckout(pool, selection));
    await tester.pumpAndSettle();
    expect(
      currentPath(tester),
      AppPaths.bookingSummary(pool, selection).split('?').first,
    );
  });

  testWidgets(
    'at a medium width the schedule sits in the pane beside the list',
    (tester) async {
      await pumpSprintApp(tester, size: const Size(700, 900));
      routerOf(tester).go(AppPaths.facilitySchedule(pool));
      await tester.pumpAndSettle();

      expect(find.byKey(FacilitiesScreen.listSlotKey), findsOneWidget);
      expect(find.byKey(FacilitiesScreen.detailsSlotKey), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(FacilitiesScreen.detailsSlotKey),
          matching: find.byType(ScheduleScreen),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('at a compact width the schedule is full screen', (tester) async {
    await pumpSprintApp(tester);
    routerOf(tester).go(AppPaths.facilitySchedule(pool));
    await tester.pumpAndSettle();

    expect(find.byKey(FacilitiesScreen.listSlotKey), findsNothing);
    expect(find.byType(ScheduleScreen), findsOneWidget);
  });
}
