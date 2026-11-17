import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/data/in_memory_data_layer.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/core/widgets/slot_chip/slot_state.dart' as chip;
import 'package:sprint/features/booking/domain/booking_repository.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';
import 'package:sprint/features/booking/presentation/schedule/schedule_screen.dart';
import 'package:sprint/features/catalogue/domain/bookable_unit.dart';
import 'package:sprint/features/catalogue/domain/catalogue_repository.dart';
import 'package:sprint/features/catalogue/domain/closure.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/domain/offer.dart';
import 'package:sprint/features/catalogue/domain/operating_hours.dart';
import 'package:sprint/features/catalogue/domain/owning_unit.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/catalogue/domain/trainer.dart';
import 'package:sprint/features/catalogue/domain/trainer_availability.dart';
import 'package:sprint/features/catalogue/presentation/facilities/facility_not_found.dart';
import 'package:sprint/features/settings/domain/booking_mode.dart';
import 'package:sprint/features/settings/domain/setting_definition.dart';
import 'package:sprint/features/settings/domain/setting_registry.dart';

import '../../../helpers/pump_app.dart';
import 'schedule_harness.dart';

/// A catalogue the test can hold, break, count and empty.
class _TestCatalogue implements CatalogueRepository {
  _TestCatalogue(this._inner);

  final CatalogueRepository _inner;
  Completer<void>? gate;
  int failures = 0;
  int facilityReads = 0;
  bool noUnits = false;

  @override
  Future<Facility?> getFacility(String id) async {
    facilityReads++;
    if (gate != null) await gate!.future;
    if (failures > 0) {
      failures--;
      throw StateError('انقطاع مؤقت');
    }
    return _inner.getFacility(id);
  }

  @override
  Future<List<BookableUnit>> listUnits(String facilityId) async =>
      noUnits ? const [] : _inner.listUnits(facilityId);

  @override
  Future<List<Facility>> listFacilities({
    FacilityType? type,
    String? owningUnitId,
    bool? free,
    bool includeUnpublished = false,
  }) => _inner.listFacilities(
    type: type,
    owningUnitId: owningUnitId,
    free: free,
    includeUnpublished: includeUnpublished,
  );

  @override
  Future<List<OwningUnit>> listOwningUnits() => _inner.listOwningUnits();
  @override
  Future<BookableUnit?> getUnit(String id) => _inner.getUnit(id);
  @override
  Future<List<OperatingHours>> hours(String ownerId) => _inner.hours(ownerId);
  @override
  Future<List<Closure>> closures({String? facilityId, String? unitId}) =>
      _inner.closures(facilityId: facilityId, unitId: unitId);
  @override
  Future<List<Price>> prices(String unitId) => _inner.prices(unitId);
  @override
  Future<List<Trainer>> trainers(String facilityId) =>
      _inner.trainers(facilityId);
  @override
  Future<List<TrainerAvailability>> trainerAvailability(
    String trainerId, {
    String? unitId,
  }) => _inner.trainerAvailability(trainerId, unitId: unitId);
  @override
  Future<List<Offer>> offers({String? facilityId, String? unitId}) =>
      _inner.offers(facilityId: facilityId, unitId: unitId);
}

/// US1 states and settings (spec US1 scenarios 8, 9; FR-009, FR-011, SC-008).
void main() {
  late InMemoryDataLayer layer;
  late _TestCatalogue catalogue;

  Future<void> open(
    WidgetTester tester,
    String facility, {
    ScheduleSelection selection = ScheduleSelection.empty,
    DateTime? now,
    bool settle = true,
    void Function(_TestCatalogue catalogue)? prepare,
  }) async {
    final t = now ?? satMorning;
    layer = InMemoryDataLayer.create(
      clock: Clock(() => t),
      paymentDelay: Duration.zero,
    );
    catalogue = _TestCatalogue(layer.catalogue);
    prepare?.call(catalogue);
    await pumpSprintApp(
      tester,
      size: const Size(400, 1400),
      overrides: [
        dataLayerProvider.overrideWithValue(layer),
        catalogueRepositoryProvider.overrideWithValue(catalogue),
        appClockProvider.overrideWithValue(Clock(() => t)),
      ],
    );
    routerOf(tester).go(AppPaths.facilitySchedule(facility, selection));
    if (settle) await tester.pumpAndSettle();
  }

  Future<void> openWith(
    WidgetTester tester,
    String facility,
    Future<void> Function(InMemoryDataLayer layer) arrange, {
    ScheduleSelection selection = ScheduleSelection.empty,
    DateTime? now,
  }) async {
    final t = now ?? satMorning;
    layer = InMemoryDataLayer.create(
      clock: Clock(() => t),
      paymentDelay: Duration.zero,
    );
    await arrange(layer);
    catalogue = _TestCatalogue(layer.catalogue);
    await pumpSprintApp(
      tester,
      size: const Size(400, 1400),
      overrides: [
        dataLayerProvider.overrideWithValue(layer),
        catalogueRepositoryProvider.overrideWithValue(catalogue),
        appClockProvider.overrideWithValue(Clock(() => t)),
      ],
    );
    routerOf(tester).go(AppPaths.facilitySchedule(facility, selection));
    await tester.pumpAndSettle();
  }

  Future<void> setSetting<T>(
    InMemoryDataLayer l,
    SettingKey<T> key,
    T value,
    SettingScope scope,
  ) async {
    await l.settings.set(key, value, scope, actorId: SeedIds.superAdmin);
  }

  ScheduleSelection sel(int day, String unit) =>
      ScheduleSelection(day: DateTime(2026, 11, 14 + day), unitId: unit);

  group('states', () {
    testWidgets('the first load shows skeletons shaped like the content', (
      tester,
    ) async {
      await open(
        tester,
        SeedIds.poolFacility,
        selection: sel(1, SeedIds.pool1),
        settle: false,
        prepare: (c) => c.gate = Completer<void>(),
      );
      await tester.pump();
      expect(find.byKey(ScheduleScreen.loadingKey), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      catalogue.gate!.complete();
      await tester.pumpAndSettle();
      expect(find.byKey(ScheduleScreen.loadingKey), findsNothing);
      expect(chips(tester), isNotEmpty);
    });

    testWidgets('a failing load shows the error and retry reloads in place', (
      tester,
    ) async {
      await open(
        tester,
        SeedIds.poolFacility,
        selection: sel(1, SeedIds.pool1),
        prepare: (c) => c.failures = 1000,
      );
      expect(find.text(ar.bookingErrorTitle), findsOneWidget);
      final before = currentUri(tester);
      catalogue.failures = 0;
      await tester.tap(find.text(ar.bookingRetry));
      await tester.pumpAndSettle();
      expect(find.text(ar.bookingErrorTitle), findsNothing);
      expect(chips(tester), isNotEmpty);
      expect(currentUri(tester), before);
    });

    testWidgets(
      'a facility with no active units says there is nothing to book',
      (tester) async {
        await open(
          tester,
          SeedIds.poolFacility,
          prepare: (c) => c.noUnits = true,
        );
        expect(find.byKey(ScheduleScreen.emptyKey), findsOneWidget);
        expect(find.text(ar.bookingNoUnitsTitle), findsOneWidget);
        expect(find.text(ar.bookingBackToFacility), findsOneWidget);
      },
    );

    testWidgets(
      'a day with only past slots keeps the grid and says nothing is left',
      (tester) async {
        await open(
          tester,
          SeedIds.poolFacility,
          selection: sel(0, SeedIds.pool1),
          now: cairoAt(0, 21, 30),
        );
        expect(chips(tester), isNotEmpty);
        expect(
          chips(tester).every((c) => c.state == chip.SlotState.past),
          isTrue,
        );
        expect(find.text(ar.bookingNothingLeftDay), findsOneWidget);
      },
    );

    testWidgets('a missing facility shows the catalogue not-found screen', (
      tester,
    ) async {
      await open(tester, 'nope');
      expect(find.byType(FacilityNotFound), findsOneWidget);
    });

    testWidgets('refresh keeps the data on screen while it reloads', (
      tester,
    ) async {
      await open(
        tester,
        SeedIds.poolFacility,
        selection: sel(1, SeedIds.pool1),
      );
      final before = chips(tester).length;
      await tester.tap(find.byKey(ScheduleScreen.refreshKey));
      await tester.pump();
      expect(find.byKey(ScheduleScreen.loadingKey), findsNothing);
      expect(chips(tester), hasLength(before));
      await tester.pumpAndSettle();
      expect(chips(tester), hasLength(before));
    });

    testWidgets('coming back to the app reloads the schedule', (tester) async {
      await open(
        tester,
        SeedIds.poolFacility,
        selection: sel(1, SeedIds.pool1),
      );
      final reads = catalogue.facilityReads;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(catalogue.facilityReads, greaterThan(reads));
    });

    testWidgets('resetting the demo data while open reloads from the seed', (
      tester,
    ) async {
      await pumpSprintApp(
        tester,
        size: const Size(400, 1400),
        overrides: [
          appClockProvider.overrideWithValue(Clock(() => satMorning)),
        ],
      );
      routerOf(tester).go(
        AppPaths.facilitySchedule(SeedIds.hallFacility, sel(1, SeedIds.hall2)),
      );
      await tester.pumpAndSettle();
      await containerOf(tester)
          .read(bookingRepositoryProvider)
          .create(
            BookingRequest(
              userId: SeedIds.bookerExternal,
              unitId: SeedIds.hall2,
              start: cairoAt(1, 10),
              end: cairoAt(1, 12),
            ),
          );
      await tester.pumpAndSettle();
      expect(chipAtHour(tester, 10)!.state, chip.SlotState.full);
      await containerOf(tester).read(resetDemoDataProvider)();
      await tester.pumpAndSettle();
      expect(chipAtHour(tester, 10)!.state, chip.SlotState.available);
    });
  });

  group('settings are read with inheritance (FR-036, SC-008)', () {
    testWidgets('booking window: university, then facility override', (
      tester,
    ) async {
      await openWith(tester, SeedIds.poolFacility, (l) async {
        await setSetting(
          l,
          SettingKeys.bookingWindowDays,
          3,
          const SettingScope.university(),
        );
      });
      expect(dayStrip(tester).days, hasLength(3));
    });

    testWidgets('a facility value wins over the university value', (
      tester,
    ) async {
      await openWith(tester, SeedIds.poolFacility, (l) async {
        await setSetting(
          l,
          SettingKeys.bookingWindowDays,
          3,
          const SettingScope.university(),
        );
        await setSetting(
          l,
          SettingKeys.bookingWindowDays,
          5,
          const SettingScope.facility(SeedIds.poolFacility),
        );
      });
      expect(dayStrip(tester).days, hasLength(5));
    });

    testWidgets('minimum lead makes the next hours past', (tester) async {
      await openWith(
        tester,
        SeedIds.poolFacility,
        (l) async => setSetting(
          l,
          SettingKeys.minLeadMinutes,
          120,
          const SettingScope.university(),
        ),
        selection: sel(0, SeedIds.pool1),
      );
      expect(chipAtHour(tester, 9)!.state, chip.SlotState.past);
      expect(chipAtHour(tester, 10)!.state, chip.SlotState.past);
      expect(chipAtHour(tester, 11)!.state, isNot(chip.SlotState.past));
    });

    testWidgets('capacity at the unit changes the places shown', (
      tester,
    ) async {
      await openWith(
        tester,
        SeedIds.poolFacility,
        (l) async => setSetting(
          l,
          SettingKeys.capacity,
          4,
          const SettingScope.unit(SeedIds.pool1),
        ),
        selection: sel(1, SeedIds.pool1),
      );
      expect(chipAtHour(tester, 9)!.remaining, 4);
    });

    testWidgets('the few-left threshold at the facility changes the state', (
      tester,
    ) async {
      await openWith(
        tester,
        SeedIds.poolFacility,
        (l) async => setSetting(
          l,
          SettingKeys.fewLeftThreshold,
          8,
          const SettingScope.facility(SeedIds.poolFacility),
        ),
        selection: sel(1, SeedIds.pool1),
      );
      expect(chipAtHour(tester, 9)!.state, chip.SlotState.fewLeft);
    });

    testWidgets('booking mode: shared to exclusive hides the count', (
      tester,
    ) async {
      await openWith(
        tester,
        SeedIds.poolFacility,
        (l) async => setSetting(
          l,
          SettingKeys.bookingMode,
          BookingMode.exclusive,
          const SettingScope.unit(SeedIds.pool5),
        ),
        selection: sel(1, SeedIds.pool5),
      );
      expect(chipAtHour(tester, 9)!.remaining, isNull);
      expect(
        find.textContaining(ar.cataloguePriceBasisExclusive),
        findsWidgets,
      );
    });

    testWidgets('granularity 60 to 30 doubles the slots', (tester) async {
      await open(
        tester,
        SeedIds.poolFacility,
        selection: sel(1, SeedIds.pool1),
      );
      final hourly = chips(tester).length;
      await openWith(
        tester,
        SeedIds.poolFacility,
        (l) async => setSetting(
          l,
          SettingKeys.slotGranularityMinutes,
          30,
          const SettingScope.university(),
        ),
        selection: sel(1, SeedIds.pool1),
      );
      expect(chips(tester).length, hourly * 2);
    });
  });
}
