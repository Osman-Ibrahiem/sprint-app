import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/features/booking/domain/availability_repository.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/slot.dart';
import 'package:sprint/features/catalogue/domain/suggestion_rule.dart';
import 'package:sprint/features/catalogue/domain/catalogue_repository.dart';
import 'package:sprint/features/catalogue/domain/closure.dart';
import 'package:sprint/features/catalogue/domain/facility_details.dart';
import 'package:sprint/features/catalogue/domain/hours_view.dart';
import 'package:sprint/features/catalogue/domain/operating_hours.dart';
import 'package:sprint/features/catalogue/domain/price_groups.dart';
import 'package:sprint/features/settings/domain/booking_mode.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/domain/facility_filter.dart';
import 'package:sprint/features/catalogue/domain/facility_summary.dart';
import 'package:sprint/features/catalogue/domain/home_content.dart';
import 'package:sprint/features/catalogue/domain/owning_unit.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/catalogue/domain/today_availability.dart';
import 'package:sprint/features/settings/domain/setting_registry.dart';
import 'package:sprint/features/settings/domain/settings_repository.dart';

part 'catalogue_providers.g.dart';

/// The list's filters. Keep-alive, so they survive navigation and resizes
/// (FR-013, R5).
@Riverpod(keepAlive: true)
class FacilityFilterNotifier extends _$FacilityFilterNotifier {
  @override
  FacilityFilter build() => const FacilityFilter();

  void setType(FacilityType? type) => state = state.copyWith(type: type);
  void setOwningUnit(String? owningUnitId) =>
      state = state.copyWith(owningUnitId: owningUnitId);
  void setFree(bool? free) => state = state.copyWith(free: free);
  void clear() => state = const FacilityFilter();
}

/// The list's scroll offset, restored when the list is built again (FR-013).
@Riverpod(keepAlive: true)
class FacilitiesListScrollOffset extends _$FacilitiesListScrollOffset {
  @override
  double build() => 0;

  void save(double offset) => state = offset;
}

/// Owning units for the filter chips.
@Riverpod(keepAlive: true)
Future<List<OwningUnit>> owningUnitOptions(Ref ref) =>
    ref.watch(catalogueRepositoryProvider).listOwningUnits();

/// One published facility by id, or null (missing or unpublished): the details
/// slot and the not-found screen share it (FR-026).
@Riverpod(keepAlive: true)
Future<Facility?> facilityById(Ref ref, String id) async {
  final facility = await ref.watch(catalogueRepositoryProvider).getFacility(id);
  return facility != null && facility.isPublished ? facility : null;
}

/// Published facilities with the filter applied, each with today's
/// availability and both price ranges (FR-007 – FR-011, FR-027, R3, R8).
@Riverpod(keepAlive: true)
Future<List<FacilitySummary>> facilitySummaries(Ref ref) async {
  final filter = ref.watch(facilityFilterProvider);
  final catalogue = ref.watch(catalogueRepositoryProvider);
  final availability = ref.watch(availabilityRepositoryProvider);
  final settings = ref.watch(settingsRepositoryProvider);
  final now = ref.watch(appClockProvider).now();

  final owningUnits = await catalogue.listOwningUnits();
  final unitNames = {for (final u in owningUnits) u.id: u.name};

  // Never `includeUnpublished`: the catalogue is public (FR-027).
  final facilities = await catalogue.listFacilities(
    type: filter.type,
    owningUnitId: filter.owningUnitId,
    free: filter.free,
  );

  final summaries = <FacilitySummary>[];
  for (final facility in facilities) {
    summaries.add(await _summaryOf(
      facility: facility,
      owningUnitName: unitNames[facility.owningUnitId] ?? '',
      catalogue: catalogue,
      availability: availability,
      settings: settings,
      now: now,
    ));
  }
  return summaries;
}

/// The guest home's discovery content: the types that have a published
/// facility (fixed enum order) and up to six featured facilities sorted by
/// today's availability count then name (FR-001, FR-002, FR-006, R4).
///
/// Unfiltered on purpose: the list's filters never narrow the home page.
@Riverpod(keepAlive: true)
Future<HomeContent> homeContent(Ref ref) async {
  final catalogue = ref.watch(catalogueRepositoryProvider);
  final availability = ref.watch(availabilityRepositoryProvider);
  final settings = ref.watch(settingsRepositoryProvider);
  final now = ref.watch(appClockProvider).now();
  final session = ref.watch(currentSessionProvider);

  final owningUnits = await catalogue.listOwningUnits();
  final unitNames = {for (final u in owningUnits) u.id: u.name};

  final facilities = await catalogue.listFacilities();
  final summaries = <FacilitySummary>[];
  for (final facility in facilities) {
    summaries.add(await _summaryOf(
      facility: facility,
      owningUnitName: unitNames[facility.owningUnitId] ?? '',
      catalogue: catalogue,
      availability: availability,
      settings: settings,
      now: now,
    ));
  }

  final types = <FacilityType>[
    for (final type in FacilityType.values)
      if (summaries.any((s) => s.facility.type == type)) type,
  ];

  final featured = [...summaries]
    ..sort((a, b) {
      final byCount = b.today.count.compareTo(a.today.count);
      if (byCount != 0) return byCount;
      return a.facility.name.compareTo(b.facility.name);
    });

  var upcoming = <UpcomingBooking>[];
  var suggestions = <Suggestion>[];
  final user = session.user;
  if (user != null) {
    final bookings = ref.watch(bookingRepositoryProvider);
    final all = await bookings.listForUser(user.id);
    final names = {for (final s in summaries) s.facility.id: s.facility.name};
    final coming = all
        .where((b) => b.status == BookingStatus.confirmed && b.start.isAfter(now))
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    upcoming = [
      for (final b in coming)
        if (names.containsKey(b.facilityId))
          UpcomingBooking(booking: b, facilityName: names[b.facilityId]!),
    ];
    suggestions = SuggestionRule.pick(
      facilities: summaries,
      pastBookings: all,
      upcomingFacilityIds: {for (final b in coming) b.facilityId},
    );
  }

  return HomeContent(
    types: types,
    featured: featured.take(homeFeaturedLimit).toList(),
    upcoming: upcoming,
    suggestions: suggestions,
  );
}

/// The details page of one published facility, or null for a missing or
/// unpublished id (FR-014 – FR-021, FR-026 – FR-028).
@Riverpod(keepAlive: true)
Future<FacilityDetails?> facilityDetails(Ref ref, String id) async {
  final catalogue = ref.watch(catalogueRepositoryProvider);
  final identity = ref.watch(identityRepositoryProvider);
  final availability = ref.watch(availabilityRepositoryProvider);
  final settings = ref.watch(settingsRepositoryProvider);
  final now = ref.watch(appClockProvider).now();

  final facility = await catalogue.getFacility(id);
  if (facility == null || !facility.isPublished) return null;

  final owningUnits = await catalogue.listOwningUnits();
  final ownerName =
      owningUnits
          .where((u) => u.id == facility.owningUnitId)
          .firstOrNull
          ?.name ??
      '';

  final units = (await catalogue.listUnits(id))
      .where((u) => u.isActive)
      .toList();
  final facilityHours = await catalogue.hours(id);
  final unitHours = <String, List<OperatingHours>>{
    for (final u in units) u.id: await catalogue.hours(u.id),
  };
  final closures =
      <Closure>[
          ...await catalogue.closures(facilityId: id),
          for (final u in units) ...await catalogue.closures(unitId: u.id),
        ].where((c) => c.to.isAfter(now)).toList()
        ..sort((a, b) => a.from.compareTo(b.from));

  final hours = HoursView.build(
    facilityHours: facilityHours,
    unitHours: {
      for (final e in unitHours.entries)
        if (e.value.isNotEmpty) e.key: e.value,
    },
    closures: closures,
    now: now,
    allUnitIds: [for (final u in units) u.id],
  );

  final modes = <String, BookingMode>{
    for (final u in units)
      u.id: await settings.resolve(
        SettingKeys.bookingMode,
        unitId: u.id,
        facilityId: id,
      ),
  };
  final prices = facility.isFree
      ? <Price>[]
      : [for (final u in units) ...await catalogue.prices(u.id)];
  final priceGroups = facility.isFree
      ? <PriceGroup>[]
      : PriceGroups.build(
          units: units,
          prices: prices,
          modeOf: (unitId) => modes[unitId] ?? BookingMode.shared,
        );

  final trainers = <TrainerView>[];
  if (facility.requiresTrainer) {
    for (final t in await catalogue.trainers(id)) {
      final user = await identity.getUser(t.userId);
      trainers.add(
        TrainerView(
          trainerId: t.id,
          name: user?.name,
          bio: t.bio,
          capacity: t.trainerCapacity,
        ),
      );
    }
  }

  final threshold = await settings.resolve(
    SettingKeys.fewLeftThreshold,
    facilityId: id,
  );
  String? trainerId;
  if (facility.requiresTrainer && trainers.isNotEmpty) {
    trainerId = trainers.first.trainerId;
  }
  final slots = <Slot>[];
  for (final u in units) {
    slots.addAll(
      await availability.slots(u.id, now, now, trainerId: trainerId),
    );
  }

  final window = await settings.resolve(
    SettingKeys.bookingWindowDays,
    facilityId: id,
  );
  final facts = FacilityFacts(
    bookingWindowDays: window,
    maxRangeHours: facility.isFree
        ? await settings.resolve(SettingKeys.maxRangeHours, facilityId: id)
        : null,
    sessionMinutes: facility.requiresTrainer
        ? await settings.resolve(SettingKeys.sessionMinutes, facilityId: id)
        : null,
  );

  return FacilityDetails(
    facility: facility,
    owningUnitName: ownerName,
    hours: hours,
    closures: closures,
    priceGroups: priceGroups,
    trainers: trainers,
    units: [
      for (final u in units)
        UnitView(id: u.id, name: u.name, ownHours: hours.unitOverrides[u.id]),
    ],
    today: TodayAvailability.fromSlots(slots, fewLeftThreshold: threshold),
    facts: facts,
  );
}

Future<FacilitySummary> _summaryOf({
  required Facility facility,
  required String owningUnitName,
  required CatalogueRepository catalogue,
  required AvailabilityRepository availability,
  required SettingsRepository settings,
  required DateTime now,
}) async {
  final units = await catalogue.listUnits(facility.id);
  final active = units.where((u) => u.isActive).toList();
  final threshold = await settings.resolve(
    SettingKeys.fewLeftThreshold,
    facilityId: facility.id,
  );

  // A trainer facility only publishes slots once a trainer is chosen (BR-09);
  // its summary uses the first trainer so the card is not falsely "closed".
  String? trainerId;
  if (facility.requiresTrainer) {
    final trainers = await catalogue.trainers(facility.id);
    trainerId = trainers.isEmpty ? null : trainers.first.id;
  }

  final slots = <Slot>[];
  for (final unit in active) {
    slots.addAll(
      await availability.slots(unit.id, now, now, trainerId: trainerId),
    );
  }
  final today = TodayAvailability.fromSlots(
    slots,
    fewLeftThreshold: threshold,
  );

  final internalAmounts = <int>[];
  final externalAmounts = <int>[];
  if (!facility.isFree) {
    for (final unit in active) {
      final prices = await catalogue.prices(unit.id);
      for (final price in prices) {
        if (price.tier == PriceTier.internal) {
          internalAmounts.add(price.amount);
        } else {
          externalAmounts.add(price.amount);
        }
      }
    }
  }

  return FacilitySummary(
    facility: facility,
    owningUnitName: owningUnitName,
    activeUnitCount: active.length,
    today: today,
    priceInternal: _range(internalAmounts),
    priceExternal: _range(externalAmounts),
  );
}

TierPriceRange? _range(List<int> amounts) {
  if (amounts.isEmpty) return null;
  amounts.sort();
  return TierPriceRange(min: amounts.first, max: amounts.last);
}
