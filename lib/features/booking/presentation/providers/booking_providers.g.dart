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

/// The checked quote and names for the summary (FR-024 – FR-028). Re-runs when
/// the session changes, so a verification that was just approved shows the new
/// price and says so (FR-026). The repository's answer is binding; a refusal
/// comes back as `Err` for the screen to explain.

@ProviderFor(bookingSummary)
final bookingSummaryProvider = BookingSummaryFamily._();

/// The checked quote and names for the summary (FR-024 – FR-028). Re-runs when
/// the session changes, so a verification that was just approved shows the new
/// price and says so (FR-026). The repository's answer is binding; a refusal
/// comes back as `Err` for the screen to explain.

final class BookingSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<Result<BookingSummaryView>>,
          Result<BookingSummaryView>,
          FutureOr<Result<BookingSummaryView>>
        >
    with
        $FutureModifier<Result<BookingSummaryView>>,
        $FutureProvider<Result<BookingSummaryView>> {
  /// The checked quote and names for the summary (FR-024 – FR-028). Re-runs when
  /// the session changes, so a verification that was just approved shows the new
  /// price and says so (FR-026). The repository's answer is binding; a refusal
  /// comes back as `Err` for the screen to explain.
  BookingSummaryProvider._({
    required BookingSummaryFamily super.from,
    required (String, ScheduleSelection, int?) super.argument,
  }) : super(
         retry: null,
         name: r'bookingSummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookingSummaryHash();

  @override
  String toString() {
    return r'bookingSummaryProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Result<BookingSummaryView>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Result<BookingSummaryView>> create(Ref ref) {
    final argument = this.argument as (String, ScheduleSelection, int?);
    return bookingSummary(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is BookingSummaryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookingSummaryHash() => r'0418fb51de6189cd90cf9541751ba68e0083bae5';

/// The checked quote and names for the summary (FR-024 – FR-028). Re-runs when
/// the session changes, so a verification that was just approved shows the new
/// price and says so (FR-026). The repository's answer is binding; a refusal
/// comes back as `Err` for the screen to explain.

final class BookingSummaryFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Result<BookingSummaryView>>,
          (String, ScheduleSelection, int?)
        > {
  BookingSummaryFamily._()
    : super(
        retry: null,
        name: r'bookingSummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The checked quote and names for the summary (FR-024 – FR-028). Re-runs when
  /// the session changes, so a verification that was just approved shows the new
  /// price and says so (FR-026). The repository's answer is binding; a refusal
  /// comes back as `Err` for the screen to explain.

  BookingSummaryProvider call(
    String facilityId,
    ScheduleSelection selection,
    int? shown,
  ) => BookingSummaryProvider._(
    argument: (facilityId, selection, shown),
    from: this,
  );

  @override
  String toString() => r'bookingSummaryProvider';
}

/// The booking behind the success screen, or null when it is missing or not
/// the signed-in person's (FR-030). Never shows someone else's booking.

@ProviderFor(bookingDone)
final bookingDoneProvider = BookingDoneFamily._();

/// The booking behind the success screen, or null when it is missing or not
/// the signed-in person's (FR-030). Never shows someone else's booking.

final class BookingDoneProvider
    extends
        $FunctionalProvider<
          AsyncValue<BookingDoneView?>,
          BookingDoneView?,
          FutureOr<BookingDoneView?>
        >
    with $FutureModifier<BookingDoneView?>, $FutureProvider<BookingDoneView?> {
  /// The booking behind the success screen, or null when it is missing or not
  /// the signed-in person's (FR-030). Never shows someone else's booking.
  BookingDoneProvider._({
    required BookingDoneFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'bookingDoneProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookingDoneHash();

  @override
  String toString() {
    return r'bookingDoneProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<BookingDoneView?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BookingDoneView?> create(Ref ref) {
    final argument = this.argument as String;
    return bookingDone(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BookingDoneProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookingDoneHash() => r'fb3468b27250aeb77a8ea728c3500b659e54fffc';

/// The booking behind the success screen, or null when it is missing or not
/// the signed-in person's (FR-030). Never shows someone else's booking.

final class BookingDoneFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<BookingDoneView?>, String> {
  BookingDoneFamily._()
    : super(
        retry: null,
        name: r'bookingDoneProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The booking behind the success screen, or null when it is missing or not
  /// the signed-in person's (FR-030). Never shows someone else's booking.

  BookingDoneProvider call(String bookingId) =>
      BookingDoneProvider._(argument: bookingId, from: this);

  @override
  String toString() => r'bookingDoneProvider';
}

/// A notice another screen wants the schedule to show, such as the summary
/// sending the person back after a refusal. The schedule takes it once and
/// clears it, so it can never come back after being dismissed. Kept in a
/// provider, not in the route, because a route's `extra` outlives the screen's
/// state and would show it again after a resize.

@ProviderFor(PendingScheduleNotice)
final pendingScheduleNoticeProvider = PendingScheduleNoticeProvider._();

/// A notice another screen wants the schedule to show, such as the summary
/// sending the person back after a refusal. The schedule takes it once and
/// clears it, so it can never come back after being dismissed. Kept in a
/// provider, not in the route, because a route's `extra` outlives the screen's
/// state and would show it again after a resize.
final class PendingScheduleNoticeProvider
    extends $NotifierProvider<PendingScheduleNotice, ScheduleNotice?> {
  /// A notice another screen wants the schedule to show, such as the summary
  /// sending the person back after a refusal. The schedule takes it once and
  /// clears it, so it can never come back after being dismissed. Kept in a
  /// provider, not in the route, because a route's `extra` outlives the screen's
  /// state and would show it again after a resize.
  PendingScheduleNoticeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingScheduleNoticeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingScheduleNoticeHash();

  @$internal
  @override
  PendingScheduleNotice create() => PendingScheduleNotice();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScheduleNotice? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScheduleNotice?>(value),
    );
  }
}

String _$pendingScheduleNoticeHash() =>
    r'dd2e23271e8261bc34cc9d246de83de8fb4177b6';

/// A notice another screen wants the schedule to show, such as the summary
/// sending the person back after a refusal. The schedule takes it once and
/// clears it, so it can never come back after being dismissed. Kept in a
/// provider, not in the route, because a route's `extra` outlives the screen's
/// state and would show it again after a resize.

abstract class _$PendingScheduleNotice extends $Notifier<ScheduleNotice?> {
  ScheduleNotice? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ScheduleNotice?, ScheduleNotice?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ScheduleNotice?, ScheduleNotice?>,
              ScheduleNotice?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
