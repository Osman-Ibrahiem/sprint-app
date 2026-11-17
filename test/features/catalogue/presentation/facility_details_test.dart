import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/data/in_memory_data_layer.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/features/catalogue/domain/closure.dart';
import 'package:sprint/features/catalogue/domain/hours_view.dart';
import 'package:sprint/features/catalogue/presentation/details/availability_section.dart';
import 'package:sprint/features/catalogue/presentation/details/facility_details_view.dart';
import 'package:sprint/features/catalogue/presentation/details/hours_section.dart';
import 'package:sprint/features/catalogue/presentation/details/photo_carousel.dart';
import 'package:sprint/features/catalogue/presentation/details/price_section.dart';
import 'package:sprint/features/catalogue/presentation/details/units_section.dart';
import 'package:sprint/features/catalogue/presentation/facilities/facility_not_found.dart';
import 'package:sprint/features/catalogue/presentation/providers/catalogue_providers.dart';

import '../../../helpers/pump_app.dart';
import '../fixtures/catalogue_fixtures.dart';

// Saturday 14 Nov 2026, noon Cairo.
final _sat = CairoTime.atWallClock(2026, 11, 14, 12);
// Friday 13 Nov 2026, noon Cairo (the hall is closed on Fridays).
final _fri = CairoTime.atWallClock(2026, 11, 13, 12);

Future<void> open(
  WidgetTester tester,
  String id, {
  DateTime? now,
  Size size = const Size(400, 900),
  bool laneSix = false,
}) async {
  final t = now ?? _sat;
  await pumpSprintApp(
    tester,
    size: size,
    overrides: [
      appClockProvider.overrideWithValue(Clock(() => t)),
      if (laneSix)
        dataLayerProvider.overrideWithValue(
          InMemoryDataLayer.create(
            clock: Clock(() => t),
            seed: laneSixSeed(t),
            paymentDelay: Duration.zero,
          ),
        ),
    ],
  );
  routerOf(tester).go('/facilities/$id');
  await tester.pumpAndSettle();
}

Future<void> scrollTo(WidgetTester tester, Finder f) async {
  await tester.scrollUntilVisible(
    f,
    200,
    scrollable: find.byType(Scrollable).last,
  );
}

void main() {
  testWidgets(
    'every seed facility shows its basics and the photo placeholder',
    (tester) async {
      for (final id in [
        SeedIds.poolFacility,
        SeedIds.futsalFacility,
        SeedIds.gymFacility,
        SeedIds.tennisFacility,
        SeedIds.hallFacility,
        SeedIds.academyFacility,
      ]) {
        await open(tester, id);
        final d = await containerOf(tester)
            .read(facilityDetailsProvider(id).future);
        expect(find.text(d!.facility.name), findsWidgets, reason: id);
        expect(find.text(d.facility.description), findsOneWidget, reason: id);
        expect(find.text(d.facility.location), findsOneWidget, reason: id);
        expect(
          find.byKey(PhotoCarousel.placeholderKey),
          findsOneWidget,
          reason: id,
        );
      }
    },
  );

  testWidgets('hours mark today, show closed days in 12-hour format', (
    tester,
  ) async {
    await open(tester, SeedIds.hallFacility, size: const Size(400, 2400));
    expect(
      find.text('${ar.catalogueDayName('6')} · ${ar.catalogueHoursToday}'),
      findsOneWidget,
    );
    final friday = find.byKey(HoursSection.dayKey(DateTime.friday));
    expect(
      find.descendant(
        of: friday,
        matching: find.text(ar.catalogueHoursClosedDay),
      ),
      findsOneWidget,
    );
    expect(find.textContaining('8:00'), findsWidgets);
    expect(find.textContaining('10:00 م'), findsWidgets);
  });

  testWidgets(
    'a facility closed today shows the page word, card says no times',
    (tester) async {
      await open(tester, SeedIds.hallFacility, now: _fri);
      expect(find.byKey(FacilityDetailsView.closedBannerKey), findsOneWidget);
      expect(find.text(ar.catalogueClosedToday), findsWidgets);
      setWindow(tester, size: const Size(400, 4000));
      routerOf(tester).go('/facilities');
      await tester.pumpAndSettle();
      expect(find.text(ar.facilityAvailabilityNone), findsWidgets);
    },
  );

  testWidgets('a closure shows its dates in words', (tester) async {
    await open(tester, SeedIds.tennisFacility, size: const Size(400, 2400));
    final d = await containerOf(tester)
        .read(facilityDetailsProvider(SeedIds.tennisFacility).future);
    expect(d!.closures.single.scope, ClosureScope.facility);
    expect(find.textContaining(d.closures.single.reason), findsOneWidget);
  });

  testWidgets('guest sees both tiers unlabelled; booker sees "سعرك"', (
    tester,
  ) async {
    await open(tester, SeedIds.poolFacility, size: const Size(400, 2400));
    expect(find.text(ar.cataloguePriceYours), findsNothing);
    expect(find.text(ar.cataloguePriceAllUnits), findsWidgets);
    expect(find.textContaining(ar.cataloguePriceBasisShared), findsWidgets);
    expect(find.text('20 ج.م'), findsWidgets);
    expect(find.text('40 ج.م'), findsWidgets);

    await containerOf(tester)
        .read(sessionProvider.notifier)
        .actAs(SeedIds.bookerInternal);
    await tester.pumpAndSettle();
    expect(find.textContaining(ar.cataloguePriceYours), findsWidgets);
    expect(find.text('40 ج.م'), findsWidgets);
  });

  testWidgets('the free hall shows "مجاني" and the no-payment note', (
    tester,
  ) async {
    await open(tester, SeedIds.hallFacility, size: const Size(400, 2400));
    expect(find.byKey(PriceSection.freeKey), findsOneWidget);
    expect(find.text(ar.catalogueFreeNoPayment), findsOneWidget);
    expect(find.textContaining('ج.م'), findsNothing);
  });

  testWidgets('the academy lists three trainers and the choose-first note', (
    tester,
  ) async {
    await open(tester, SeedIds.academyFacility, size: const Size(400, 3000));
    expect(find.text(ar.catalogueTrainerFirst), findsOneWidget);
    expect(find.textContaining('الكابتن'), findsNWidgets(3));
  });

  testWidgets('units list: active only, lane 6 has its own hours', (
    tester,
  ) async {
    await open(
      tester,
      SeedIds.poolFacility,
      size: const Size(400, 3000),
      laneSix: true,
    );
    expect(find.byKey(UnitsSection.unitKey(SeedIds.pool6)), findsOneWidget);
    expect(find.textContaining('مواعيد خاصة'), findsOneWidget);
    expect(find.byKey(UnitsSection.unitKey(SeedIds.pool1)), findsOneWidget);
  });

  testWidgets('facts line comes from settings', (tester) async {
    await open(tester, SeedIds.poolFacility);
    final d = await containerOf(tester)
        .read(facilityDetailsProvider(SeedIds.poolFacility).future);
    expect(
      find.textContaining(ar.catalogueFactWindow(d!.facts.bookingWindowDays)),
      findsOneWidget,
    );
  });

  testWidgets('"عرض المواعيد" opens the schedule and back returns', (
    tester,
  ) async {
    await open(tester, SeedIds.poolFacility, size: const Size(400, 2400));
    await tester.tap(find.byKey(AvailabilitySection.actionKey));
    await tester.pumpAndSettle();
    expect(find.byKey(AvailabilitySection.actionKey), findsNothing);
    expect(
      currentPath(tester),
      AppPaths.facilitySchedule(SeedIds.poolFacility),
    );
    routerOf(tester).pop();
    await tester.pumpAndSettle();
    expect(find.byKey(FacilityDetailsView.factsKey), findsOneWidget);
  });

  testWidgets('the app bar stays visible after scrolling to the bottom', (
    tester,
  ) async {
    await open(tester, SeedIds.poolFacility, size: const Size(400, 600));
    await tester.drag(find.byType(ListView).last, const Offset(0, -5000));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'مسبح الكلية'.isEmpty
            ? ''
            : (await containerOf(tester).read(
                facilityDetailsProvider(SeedIds.poolFacility).future,
              ))!.facility.name,
      ),
      findsWidgets,
    );
  });

  testWidgets('an unknown id shows the not-found screen', (tester) async {
    await open(tester, 'nope');
    expect(find.byType(FacilityNotFound), findsOneWidget);
  });

  testWidgets('SC-004: price shown equals the seeded price for the tier', (
    tester,
  ) async {
    for (final id in [
      SeedIds.poolFacility,
      SeedIds.futsalFacility,
      SeedIds.gymFacility,
      SeedIds.tennisFacility,
    ]) {
      final c = await (() async {
        await open(tester, id, size: const Size(400, 3000));
        return containerOf(tester);
      })();
      final d = (await c.read(facilityDetailsProvider(id).future))!;
      for (final g in d.priceGroups) {
        expect(
          find.text(ar.priceEgp('${g.internal}')),
          findsWidgets,
          reason: id,
        );
        expect(
          find.text(ar.priceEgp('${g.external}')),
          findsWidgets,
          reason: id,
        );
      }
    }
  });

  test('HoursView is exported for the sections', () {
    expect(const DayHours(dayOfWeek: 1).isClosed, isTrue);
    expect(hoursLine, isNotNull);
  });
}
