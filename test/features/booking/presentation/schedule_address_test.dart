import 'package:flutter/painting.dart' show Size;
import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/widgets/day_strip/day_strip.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';
import 'package:sprint/features/catalogue/presentation/details/facility_details_view.dart';

import '../../../helpers/pump_app.dart';
import 'schedule_harness.dart';

/// The selection lives in the address and changes in place (FR-012,
/// contracts/routes.md).
void main() {
  final pool = SeedIds.poolFacility;
  ScheduleSelection sel(int day, String unit) =>
      ScheduleSelection(day: DateTime(2026, 11, 14 + day), unitId: unit);

  testWidgets('choosing a day writes it into the address in place', (
    tester,
  ) async {
    await openSchedule(tester, pool);
    final depth = stackDepth(tester);
    await tester.tap(
      find.descendant(of: find.byType(DayStrip), matching: find.text('16')),
    );
    await tester.pumpAndSettle();

    expect(currentUri(tester).queryParameters['day'], '2026-11-16');
    expect(currentUri(tester).queryParameters['unit'], SeedIds.pool1);
    expect(dayStrip(tester).selected, DateTime(2026, 11, 16));
    expect(stackDepth(tester), depth);
  });

  testWidgets('choosing a unit keeps the day and clears nothing else', (
    tester,
  ) async {
    await openSchedule(tester, pool, selection: sel(2, SeedIds.pool1));
    await tester.tap(find.text('حارة 3'));
    await tester.pumpAndSettle();
    expect(currentUri(tester).queryParameters, {
      'day': '2026-11-16',
      'unit': SeedIds.pool3,
    });
  });

  testWidgets(
    'back after several choices returns to the facility in one step',
    (tester) async {
      await pumpSprintApp(
      tester,
      size: const Size(400, 1400),
      overrides: [appClockProvider.overrideWithValue(Clock(() => satMorning))],
    );
      routerOf(tester).go(AppPaths.facilityDetails(pool));
      await tester.pumpAndSettle();
      routerOf(tester).push(AppPaths.facilitySchedule(pool));
      await tester.pumpAndSettle();
      final depth = stackDepth(tester);

      await tester.tap(
        find.descendant(of: find.byType(DayStrip), matching: find.text('15')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('حارة 2'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(of: find.byType(DayStrip), matching: find.text('18')),
      );
      await tester.pumpAndSettle();
      expect(stackDepth(tester), depth);

      routerOf(tester).pop();
      await tester.pumpAndSettle();
      expect(currentUri(tester).path, AppPaths.facilityDetails(pool));
      expect(find.byKey(FacilityDetailsView.factsKey), findsOneWidget);
    },
  );

  testWidgets('a location with day and unit reopens them', (tester) async {
    await openSchedule(tester, pool, selection: sel(4, SeedIds.pool4));
    expect(dayStrip(tester).selected, DateTime(2026, 11, 18));
    expect(find.bySemanticsLabel(RegExp('حارة 4')), findsWidgets);
    expect(find.text(ar.bookingChoiceGone), findsNothing);
  });

  testWidgets('an invalid day falls back, says so and replaces the address', (
    tester,
  ) async {
    await openSchedule(
      tester,
      pool,
      selection: ScheduleSelection(
        day: DateTime(2026, 12, 31),
        unitId: SeedIds.pool2,
      ),
    );
    expect(find.text(ar.bookingChoiceGone), findsOneWidget);
    expect(dayStrip(tester).selected, DateTime(2026, 11, 14));
    expect(currentUri(tester).queryParameters, {
      'day': '2026-11-14',
      'unit': SeedIds.pool2,
    });
  });

  testWidgets('an unknown unit falls back with the notice', (tester) async {
    await openSchedule(tester, pool, selection: sel(1, 'u-gone'));
    expect(find.text(ar.bookingChoiceGone), findsOneWidget);
    expect(currentUri(tester).queryParameters['unit'], SeedIds.pool1);
  });

  testWidgets('dismissing the notice removes it', (tester) async {
    await openSchedule(tester, pool, selection: sel(1, 'u-gone'));
    await tester.tap(find.byTooltip(ar.bookingNoticeDismiss));
    await tester.pumpAndSettle();
    expect(find.text(ar.bookingChoiceGone), findsNothing);
  });

  testWidgets('a time that is not bookable is cleared with the notice', (
    tester,
  ) async {
    await openSchedule(
      tester,
      pool,
      selection: ScheduleSelection(
        day: DateTime(2026, 11, 17),
        unitId: SeedIds.pool2,
        startMinutes: 10 * 60,
        endMinutes: 11 * 60,
      ),
    );
    // Lane 2 on day +3 at 10:00 is full: the notice says so.
    expect(find.text(ar.bookingFailSlotFull), findsOneWidget);
    expect(currentUri(tester).queryParameters.containsKey('start'), isFalse);
  });
}
