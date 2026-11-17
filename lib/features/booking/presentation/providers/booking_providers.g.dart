// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The schedule of one facility over the whole booking window, loaded in one
/// parallel pass (feature 005 research R4). `null` means missing or
/// unpublished. [trainerId] is the chosen trainer in the trainer path.
///
/// Reloads when a booking is written, when the session changes and when the
/// next slot turns past, so the screen is right without a tap. Auto-dispose:
/// it is rebuilt each time its screen is shown again.

@ProviderFor(facilitySchedule)
final facilityScheduleProvider = FacilityScheduleFamily._();

/// The schedule of one facility over the whole booking window, loaded in one
/// parallel pass (feature 005 research R4). `null` means missing or
/// unpublished. [trainerId] is the chosen trainer in the trainer path.
///
/// Reloads when a booking is written, when the session changes and when the
/// next slot turns past, so the screen is right without a tap. Auto-dispose:
/// it is rebuilt each time its screen is shown again.

final class FacilityScheduleProvider
    extends
        $FunctionalProvider<
          AsyncValue<FacilitySchedule?>,
          FacilitySchedule?,
          FutureOr<FacilitySchedule?>
        >
    with
        $FutureModifier<FacilitySchedule?>,
        $FutureProvider<FacilitySchedule?> {
  /// The schedule of one facility over the whole booking window, loaded in one
  /// parallel pass (feature 005 research R4). `null` means missing or
  /// unpublished. [trainerId] is the chosen trainer in the trainer path.
  ///
  /// Reloads when a booking is written, when the session changes and when the
  /// next slot turns past, so the screen is right without a tap. Auto-dispose:
  /// it is rebuilt each time its screen is shown again.
  FacilityScheduleProvider._({
    required FacilityScheduleFamily super.from,
    required (String, String?) super.argument,
  }) : super(
         retry: null,
         name: r'facilityScheduleProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$facilityScheduleHash();

  @override
  String toString() {
    return r'facilityScheduleProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<FacilitySchedule?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<FacilitySchedule?> create(Ref ref) {
    final argument = this.argument as (String, String?);
    return facilitySchedule(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is FacilityScheduleProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$facilityScheduleHash() => r'fd01bf75c01f359f2290c7bad08346741a9c14c9';

/// The schedule of one facility over the whole booking window, loaded in one
/// parallel pass (feature 005 research R4). `null` means missing or
/// unpublished. [trainerId] is the chosen trainer in the trainer path.
///
/// Reloads when a booking is written, when the session changes and when the
/// next slot turns past, so the screen is right without a tap. Auto-dispose:
/// it is rebuilt each time its screen is shown again.

final class FacilityScheduleFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<FacilitySchedule?>,
          (String, String?)
        > {
  FacilityScheduleFamily._()
    : super(
        retry: null,
        name: r'facilityScheduleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The schedule of one facility over the whole booking window, loaded in one
  /// parallel pass (feature 005 research R4). `null` means missing or
  /// unpublished. [trainerId] is the chosen trainer in the trainer path.
  ///
  /// Reloads when a booking is written, when the session changes and when the
  /// next slot turns past, so the screen is right without a tap. Auto-dispose:
  /// it is rebuilt each time its screen is shown again.

  FacilityScheduleProvider call(String facilityId, String? trainerId) =>
      FacilityScheduleProvider._(argument: (facilityId, trainerId), from: this);

  @override
  String toString() => r'facilityScheduleProvider';
}

/// The signed-in person's bookings that have not ended, for the tap-time
/// overlap hint (clarify Q2, FR-033). Empty for a guest.

@ProviderFor(myUpcomingBookings)
final myUpcomingBookingsProvider = MyUpcomingBookingsProvider._();

/// The signed-in person's bookings that have not ended, for the tap-time
/// overlap hint (clarify Q2, FR-033). Empty for a guest.

final class MyUpcomingBookingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Booking>>,
          List<Booking>,
          FutureOr<List<Booking>>
        >
    with $FutureModifier<List<Booking>>, $FutureProvider<List<Booking>> {
  /// The signed-in person's bookings that have not ended, for the tap-time
  /// overlap hint (clarify Q2, FR-033). Empty for a guest.
  MyUpcomingBookingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myUpcomingBookingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myUpcomingBookingsHash();

  @$internal
  @override
  $FutureProviderElement<List<Booking>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Booking>> create(Ref ref) {
    return myUpcomingBookings(ref);
  }
}

String _$myUpcomingBookingsHash() =>
    r'db0ad1ecb2c471e1af9dad30a136f469eb30912a';
