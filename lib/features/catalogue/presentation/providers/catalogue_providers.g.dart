// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalogue_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The list's filters. Keep-alive, so they survive navigation and resizes
/// (FR-013, R5).

@ProviderFor(FacilityFilterNotifier)
final facilityFilterProvider = FacilityFilterNotifierProvider._();

/// The list's filters. Keep-alive, so they survive navigation and resizes
/// (FR-013, R5).
final class FacilityFilterNotifierProvider
    extends $NotifierProvider<FacilityFilterNotifier, FacilityFilter> {
  /// The list's filters. Keep-alive, so they survive navigation and resizes
  /// (FR-013, R5).
  FacilityFilterNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'facilityFilterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$facilityFilterNotifierHash();

  @$internal
  @override
  FacilityFilterNotifier create() => FacilityFilterNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FacilityFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FacilityFilter>(value),
    );
  }
}

String _$facilityFilterNotifierHash() =>
    r'0f8d18a189aa3ad7c84e2e485ece386e9329745b';

/// The list's filters. Keep-alive, so they survive navigation and resizes
/// (FR-013, R5).

abstract class _$FacilityFilterNotifier extends $Notifier<FacilityFilter> {
  FacilityFilter build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<FacilityFilter, FacilityFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FacilityFilter, FacilityFilter>,
              FacilityFilter,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The list's scroll offset, restored when the list is built again (FR-013).

@ProviderFor(FacilitiesListScrollOffset)
final facilitiesListScrollOffsetProvider =
    FacilitiesListScrollOffsetProvider._();

/// The list's scroll offset, restored when the list is built again (FR-013).
final class FacilitiesListScrollOffsetProvider
    extends $NotifierProvider<FacilitiesListScrollOffset, double> {
  /// The list's scroll offset, restored when the list is built again (FR-013).
  FacilitiesListScrollOffsetProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'facilitiesListScrollOffsetProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$facilitiesListScrollOffsetHash();

  @$internal
  @override
  FacilitiesListScrollOffset create() => FacilitiesListScrollOffset();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$facilitiesListScrollOffsetHash() =>
    r'18c1759876eb36691f0fd9927e01e0bbb4913068';

/// The list's scroll offset, restored when the list is built again (FR-013).

abstract class _$FacilitiesListScrollOffset extends $Notifier<double> {
  double build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<double, double>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<double, double>,
              double,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Owning units for the filter chips.

@ProviderFor(owningUnitOptions)
final owningUnitOptionsProvider = OwningUnitOptionsProvider._();

/// Owning units for the filter chips.

final class OwningUnitOptionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<OwningUnit>>,
          List<OwningUnit>,
          FutureOr<List<OwningUnit>>
        >
    with $FutureModifier<List<OwningUnit>>, $FutureProvider<List<OwningUnit>> {
  /// Owning units for the filter chips.
  OwningUnitOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'owningUnitOptionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$owningUnitOptionsHash();

  @$internal
  @override
  $FutureProviderElement<List<OwningUnit>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<OwningUnit>> create(Ref ref) {
    return owningUnitOptions(ref);
  }
}

String _$owningUnitOptionsHash() => r'6a8e47845b089f053c5ecfd0f155c88033b3fb53';

/// One published facility by id, or null (missing or unpublished): the details
/// slot and the not-found screen share it (FR-026).

@ProviderFor(facilityById)
final facilityByIdProvider = FacilityByIdFamily._();

/// One published facility by id, or null (missing or unpublished): the details
/// slot and the not-found screen share it (FR-026).

final class FacilityByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<Facility?>,
          Facility?,
          FutureOr<Facility?>
        >
    with $FutureModifier<Facility?>, $FutureProvider<Facility?> {
  /// One published facility by id, or null (missing or unpublished): the details
  /// slot and the not-found screen share it (FR-026).
  FacilityByIdProvider._({
    required FacilityByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'facilityByIdProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$facilityByIdHash();

  @override
  String toString() {
    return r'facilityByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Facility?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Facility?> create(Ref ref) {
    final argument = this.argument as String;
    return facilityById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FacilityByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$facilityByIdHash() => r'ad7b4878101a70e70e0dc9ec485209b1b04505f9';

/// One published facility by id, or null (missing or unpublished): the details
/// slot and the not-found screen share it (FR-026).

final class FacilityByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Facility?>, String> {
  FacilityByIdFamily._()
    : super(
        retry: null,
        name: r'facilityByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// One published facility by id, or null (missing or unpublished): the details
  /// slot and the not-found screen share it (FR-026).

  FacilityByIdProvider call(String id) =>
      FacilityByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'facilityByIdProvider';
}

/// Published facilities with the filter applied, each with today's
/// availability and both price ranges (FR-007 – FR-011, FR-027, R3, R8).
///
/// Not keep-alive: it depends on "now" and on bookings, so it is rebuilt each
/// time its screen is shown again instead of freezing today's counts.

@ProviderFor(facilitySummaries)
final facilitySummariesProvider = FacilitySummariesProvider._();

/// Published facilities with the filter applied, each with today's
/// availability and both price ranges (FR-007 – FR-011, FR-027, R3, R8).
///
/// Not keep-alive: it depends on "now" and on bookings, so it is rebuilt each
/// time its screen is shown again instead of freezing today's counts.

final class FacilitySummariesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FacilitySummary>>,
          List<FacilitySummary>,
          FutureOr<List<FacilitySummary>>
        >
    with
        $FutureModifier<List<FacilitySummary>>,
        $FutureProvider<List<FacilitySummary>> {
  /// Published facilities with the filter applied, each with today's
  /// availability and both price ranges (FR-007 – FR-011, FR-027, R3, R8).
  ///
  /// Not keep-alive: it depends on "now" and on bookings, so it is rebuilt each
  /// time its screen is shown again instead of freezing today's counts.
  FacilitySummariesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'facilitySummariesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$facilitySummariesHash();

  @$internal
  @override
  $FutureProviderElement<List<FacilitySummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<FacilitySummary>> create(Ref ref) {
    return facilitySummaries(ref);
  }
}

String _$facilitySummariesHash() => r'9be884e0650e67197f352dc485ead74e760fff00';

/// The guest home's discovery content: the types that have a published
/// facility (fixed enum order) and up to six featured facilities sorted by
/// today's availability count then name (FR-001, FR-002, FR-006, R4).
///
/// Unfiltered on purpose: the list's filters never narrow the home page.

@ProviderFor(homeContent)
final homeContentProvider = HomeContentProvider._();

/// The guest home's discovery content: the types that have a published
/// facility (fixed enum order) and up to six featured facilities sorted by
/// today's availability count then name (FR-001, FR-002, FR-006, R4).
///
/// Unfiltered on purpose: the list's filters never narrow the home page.

final class HomeContentProvider
    extends
        $FunctionalProvider<
          AsyncValue<HomeContent>,
          HomeContent,
          FutureOr<HomeContent>
        >
    with $FutureModifier<HomeContent>, $FutureProvider<HomeContent> {
  /// The guest home's discovery content: the types that have a published
  /// facility (fixed enum order) and up to six featured facilities sorted by
  /// today's availability count then name (FR-001, FR-002, FR-006, R4).
  ///
  /// Unfiltered on purpose: the list's filters never narrow the home page.
  HomeContentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeContentProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeContentHash();

  @$internal
  @override
  $FutureProviderElement<HomeContent> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HomeContent> create(Ref ref) {
    return homeContent(ref);
  }
}

String _$homeContentHash() => r'a83977e9a0dfb4f7d469a5b3e59712332e82a60a';

/// The details page of one published facility, or null for a missing or
/// unpublished id (FR-014 – FR-021, FR-026 – FR-028).

@ProviderFor(facilityDetails)
final facilityDetailsProvider = FacilityDetailsFamily._();

/// The details page of one published facility, or null for a missing or
/// unpublished id (FR-014 – FR-021, FR-026 – FR-028).

final class FacilityDetailsProvider
    extends
        $FunctionalProvider<
          AsyncValue<FacilityDetails?>,
          FacilityDetails?,
          FutureOr<FacilityDetails?>
        >
    with $FutureModifier<FacilityDetails?>, $FutureProvider<FacilityDetails?> {
  /// The details page of one published facility, or null for a missing or
  /// unpublished id (FR-014 – FR-021, FR-026 – FR-028).
  FacilityDetailsProvider._({
    required FacilityDetailsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'facilityDetailsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$facilityDetailsHash();

  @override
  String toString() {
    return r'facilityDetailsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<FacilityDetails?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<FacilityDetails?> create(Ref ref) {
    final argument = this.argument as String;
    return facilityDetails(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FacilityDetailsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$facilityDetailsHash() => r'c355508cc72b739251037d38630ffde6a2dbd999';

/// The details page of one published facility, or null for a missing or
/// unpublished id (FR-014 – FR-021, FR-026 – FR-028).

final class FacilityDetailsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<FacilityDetails?>, String> {
  FacilityDetailsFamily._()
    : super(
        retry: null,
        name: r'facilityDetailsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The details page of one published facility, or null for a missing or
  /// unpublished id (FR-014 – FR-021, FR-026 – FR-028).

  FacilityDetailsProvider call(String id) =>
      FacilityDetailsProvider._(argument: id, from: this);

  @override
  String toString() => r'facilityDetailsProvider';
}
