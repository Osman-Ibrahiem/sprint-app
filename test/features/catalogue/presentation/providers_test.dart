import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/data/in_memory_data_layer.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/seed/seed_data.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/core/widgets/facility_card/facility_card_data.dart';
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
import 'package:sprint/features/catalogue/presentation/providers/catalogue_providers.dart';

import '../fixtures/catalogue_fixtures.dart';

ProviderContainer _container(
  DateTime now, {
  SeedData Function(DateTime)? seed,
  CatalogueRepository Function(CatalogueRepository)? catalogue,
}) {
  final layer = InMemoryDataLayer.create(
    clock: Clock(() => now),
    seed: seed?.call(now),
    paymentDelay: Duration.zero,
  );
  return ProviderContainer(
    overrides: [
      dataLayerProvider.overrideWithValue(layer),
      appClockProvider.overrideWithValue(Clock(() => now)),
      if (catalogue != null)
        catalogueRepositoryProvider.overrideWithValue(
          catalogue(layer.catalogue),
        ),
    ],
  );
}

/// Wraps the real repository and throws on the next listFacilities call while
/// [failures] is above zero, for the error-and-retry path.
class _FlakyCatalogue implements CatalogueRepository {
  _FlakyCatalogue(this._inner, this.failures);

  final CatalogueRepository _inner;
  int failures;

  Future<T> _guard<T>(Future<T> Function() call) {
    if (failures > 0) {
      failures--;
      throw StateError('انقطاع مؤقت');
    }
    return call();
  }

  @override
  Future<List<Facility>> listFacilities({
    FacilityType? type,
    String? owningUnitId,
    bool? free,
    bool includeUnpublished = false,
  }) =>
      _guard(() => _inner.listFacilities(
            type: type,
            owningUnitId: owningUnitId,
            free: free,
            includeUnpublished: includeUnpublished,
          ));

  @override
  Future<List<OwningUnit>> listOwningUnits() => _inner.listOwningUnits();

  @override
  Future<Facility?> getFacility(String id) => _inner.getFacility(id);

  @override
  Future<List<BookableUnit>> listUnits(String facilityId) =>
      _inner.listUnits(facilityId);

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
  }) =>
      _inner.trainerAvailability(trainerId, unitId: unitId);

  @override
  Future<List<Offer>> offers({String? facilityId, String? unitId}) =>
      _inner.offers(facilityId: facilityId, unitId: unitId);
}

void main() {
  final now = CairoTime.atWallClock(2026, 11, 14, 8);

  Future<List<String>> ids(ProviderContainer container) async {
    final list = await container.read(facilitySummariesProvider.future);
    return list.map((s) => s.facility.id).toList();
  }

  test('the list holds every published facility by default', () async {
    final container = _container(now);
    addTearDown(container.dispose);
    final list = await container.read(facilitySummariesProvider.future);
    expect(list, hasLength(6));
    expect(
      list.map((s) => s.facility.id),
      containsAll([
        SeedIds.poolFacility,
        SeedIds.futsalFacility,
        SeedIds.gymFacility,
        SeedIds.tennisFacility,
        SeedIds.hallFacility,
        SeedIds.academyFacility,
      ]),
    );
    expect(container.read(facilityFilterProvider).isActive, isFalse);
  });

  test('filters: type alone', () async {
    final container = _container(now);
    addTearDown(container.dispose);
    container.read(facilityFilterProvider.notifier).setType(FacilityType.swimming);
    expect(await ids(container), [SeedIds.poolFacility]);
  });

  test('filters: owning unit alone', () async {
    final container = _container(now);
    addTearDown(container.dispose);
    container
        .read(facilityFilterProvider.notifier)
        .setOwningUnit(SeedIds.ouEng);
    expect(await ids(container), [SeedIds.tennisFacility]);
  });

  test('filters: free only', () async {
    final container = _container(now);
    addTearDown(container.dispose);
    container.read(facilityFilterProvider.notifier).setFree(true);
    expect(await ids(container), [SeedIds.hallFacility]);
  });

  test('filters: paid only', () async {
    final container = _container(now);
    addTearDown(container.dispose);
    container.read(facilityFilterProvider.notifier).setFree(false);
    final result = await ids(container);
    expect(result, isNot(contains(SeedIds.hallFacility)));
    expect(result, hasLength(5));
  });

  test('filters combine with AND', () async {
    final container = _container(now);
    addTearDown(container.dispose);
    final notifier = container.read(facilityFilterProvider.notifier);
    notifier.setType(FacilityType.tennis);
    notifier.setOwningUnit(SeedIds.ouEng);
    notifier.setFree(false);
    expect(await ids(container), [SeedIds.tennisFacility]);
  });

  test('clear resets every filter', () async {
    final container = _container(now);
    addTearDown(container.dispose);
    final notifier = container.read(facilityFilterProvider.notifier);
    notifier.setType(FacilityType.swimming);
    notifier.setFree(true);
    expect(container.read(facilityFilterProvider).activeCount, 2);
    notifier.clear();
    expect(container.read(facilityFilterProvider).isActive, isFalse);
    expect(await ids(container), hasLength(6));
  });

  test('the scroll offset is kept across reads', () {
    final container = _container(now);
    addTearDown(container.dispose);
    expect(container.read(facilitiesListScrollOffsetProvider), 0);
    container.read(facilitiesListScrollOffsetProvider.notifier).save(240);
    expect(container.read(facilitiesListScrollOffsetProvider), 240);
  });

  test('an unpublished facility never appears', () async {
    final unused = Facility(
      id: 'f-hidden',
      owningUnitId: SeedIds.ouPe,
      name: 'منشأة مخفية',
      type: FacilityType.gym,
      description: 'وصف',
      location: 'الموقع',
      isFree: false,
      requiresTrainer: false,
      isPublished: false,
    );
    final container = _container(
      now,
      seed: (n) => catalogueSeed(n, extraFacilities: [unused]),
    );
    addTearDown(container.dispose);
    final result = await ids(container);
    expect(result, isNot(contains('f-hidden')));
    expect(result, hasLength(6));
  });

  test('the pool summary carries today and both price ranges', () async {
    final container = _container(now);
    addTearDown(container.dispose);
    final list = await container.read(facilitySummariesProvider.future);
    final pool = list.firstWhere((s) => s.facility.id == SeedIds.poolFacility);
    expect(pool.activeUnitCount, 6);
    expect(pool.owningUnitName, 'كلية التربية الرياضية');
    expect(pool.priceInternal!.isSingle, isTrue);
    expect(pool.priceInternal!.min, 20);
    expect(pool.priceExternal!.isSingle, isTrue);
    expect(pool.priceExternal!.min, 40);
    expect(pool.today.closedToday, isFalse);
  });

  test('a free facility has no price ranges', () async {
    final container = _container(now);
    addTearDown(container.dispose);
    final list = await container.read(facilitySummariesProvider.future);
    final hall = list.firstWhere((s) => s.facility.id == SeedIds.hallFacility);
    expect(hall.priceInternal, isNull);
    expect(hall.priceExternal, isNull);
    expect(hall.kind, FacilityKind.free);
  });

  test('a facility closed today is none, not closed-in-general', () async {
    final container = _container(now, seed: closedTodaySeed);
    addTearDown(container.dispose);
    final list = await container.read(facilitySummariesProvider.future);
    final tennis =
        list.firstWhere((s) => s.facility.id == SeedIds.tennisFacility);
    expect(tennis.today.level, AvailabilityLevel.none);
    expect(tennis.today.count, 0);
    expect(tennis.today.closedToday, isTrue);
  });

  test('a throwing catalogue gives an error state and invalidate recovers',
      () async {
    final flaky = <_FlakyCatalogue>[];
    final container = _container(
      now,
      catalogue: (inner) {
        final wrapper = _FlakyCatalogue(inner, 1);
        flaky.add(wrapper);
        return wrapper;
      },
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(facilitySummariesProvider.future),
      throwsA(isA<StateError>()),
    );
    expect(flaky.single.failures, 0);

    container.invalidate(facilitySummariesProvider);
    final list = await container.read(facilitySummariesProvider.future);
    expect(list, hasLength(6));
  });

  test('owning unit options come from the catalogue', () async {
    final container = _container(now);
    addTearDown(container.dispose);
    final units = await container.read(owningUnitOptionsProvider.future);
    expect(units.map((u) => u.id), containsAll([SeedIds.ouPe, SeedIds.ouEng]));
  });

  test('the tennis closure is in the seed but not today', () async {
    final container = _container(now);
    addTearDown(container.dispose);
    final closures = await container
        .read(catalogueRepositoryProvider)
        .closures(facilityId: SeedIds.tennisFacility);
    final closure =
        closures.singleWhere((c) => c.scope == ClosureScope.facility);
    expect(closure.from.isAfter(now), isTrue);
  });

  test('home types are the seeded types in enum order', () async {
    final container = _container(now);
    addTearDown(container.dispose);
    final content = await container.read(homeContentProvider.future);
    expect(content.types, FacilityType.values);
    expect(content.upcoming, isEmpty);
    expect(content.suggestions, isEmpty);
  });

  test('home featured is capped at six and sorted by count then name',
      () async {
    final container = _container(now);
    addTearDown(container.dispose);
    final content = await container.read(homeContentProvider.future);
    expect(content.featured, hasLength(6));
    for (var i = 0; i + 1 < content.featured.length; i++) {
      final a = content.featured[i];
      final b = content.featured[i + 1];
      final ordered = a.today.count > b.today.count ||
          (a.today.count == b.today.count &&
              a.facility.name.compareTo(b.facility.name) <= 0);
      expect(ordered, isTrue, reason: '${a.facility.name} before ${b.facility.name}');
    }
  });

  test('facilityDetails is null for a missing id', () async {
    final container = _container(now);
    addTearDown(container.dispose);
    expect(await container.read(facilityDetailsProvider('nope').future), isNull);
  });

  test('facilityDetails gathers hours, price groups, units and facts', () async {
    final container = _container(now);
    addTearDown(container.dispose);
    final d = await container
        .read(facilityDetailsProvider(SeedIds.poolFacility).future);
    expect(d, isNotNull);
    expect(d!.hours.days, hasLength(7));
    expect(d.priceGroups, isNotEmpty);
    expect(d.units, isNotEmpty);
    expect(d.trainers, isEmpty);
    expect(d.facts.bookingWindowDays, greaterThan(0));
  });

  test('facilityDetails has trainers for the academy and no prices when free',
      () async {
    final container = _container(now);
    addTearDown(container.dispose);
    final academy = await container
        .read(facilityDetailsProvider(SeedIds.academyFacility).future);
    expect(academy!.trainers, hasLength(3));
    expect(academy.facts.sessionMinutes, isNotNull);
    final hall =
        await container.read(facilityDetailsProvider(SeedIds.hallFacility).future);
    expect(hall!.priceGroups, isEmpty);
    expect(hall.facts.maxRangeHours, isNotNull);
  });
}
