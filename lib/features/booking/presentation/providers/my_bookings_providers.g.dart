// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_bookings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The signed-in person's bookings of one [segment]: upcoming is confirmed or
/// holding and not yet ended, soonest first; past is everything else, newest
/// first. Reloads on every booking write and when the session changes.

@ProviderFor(myBookings)
final myBookingsProvider = MyBookingsFamily._();

/// The signed-in person's bookings of one [segment]: upcoming is confirmed or
/// holding and not yet ended, soonest first; past is everything else, newest
/// first. Reloads on every booking write and when the session changes.

final class MyBookingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Booking>>,
          List<Booking>,
          FutureOr<List<Booking>>
        >
    with $FutureModifier<List<Booking>>, $FutureProvider<List<Booking>> {
  /// The signed-in person's bookings of one [segment]: upcoming is confirmed or
  /// holding and not yet ended, soonest first; past is everything else, newest
  /// first. Reloads on every booking write and when the session changes.
  MyBookingsProvider._({
    required MyBookingsFamily super.from,
    required BookingSegment super.argument,
  }) : super(
         retry: null,
         name: r'myBookingsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$myBookingsHash();

  @override
  String toString() {
    return r'myBookingsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Booking>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Booking>> create(Ref ref) {
    final argument = this.argument as BookingSegment;
    return myBookings(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MyBookingsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$myBookingsHash() => r'2c5239a28185ef0a4a3e849c8b6d1744905d1c5f';

/// The signed-in person's bookings of one [segment]: upcoming is confirmed or
/// holding and not yet ended, soonest first; past is everything else, newest
/// first. Reloads on every booking write and when the session changes.

final class MyBookingsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Booking>>, BookingSegment> {
  MyBookingsFamily._()
    : super(
        retry: null,
        name: r'myBookingsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The signed-in person's bookings of one [segment]: upcoming is confirmed or
  /// holding and not yet ended, soonest first; past is everything else, newest
  /// first. Reloads on every booking write and when the session changes.

  MyBookingsProvider call(BookingSegment segment) =>
      MyBookingsProvider._(argument: segment, from: this);

  @override
  String toString() => r'myBookingsProvider';
}

/// The same lists with the names each row shows: facility, unit and trainer.

@ProviderFor(myBookingRows)
final myBookingRowsProvider = MyBookingRowsFamily._();

/// The same lists with the names each row shows: facility, unit and trainer.

final class MyBookingRowsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BookingRowInfo>>,
          List<BookingRowInfo>,
          FutureOr<List<BookingRowInfo>>
        >
    with
        $FutureModifier<List<BookingRowInfo>>,
        $FutureProvider<List<BookingRowInfo>> {
  /// The same lists with the names each row shows: facility, unit and trainer.
  MyBookingRowsProvider._({
    required MyBookingRowsFamily super.from,
    required BookingSegment super.argument,
  }) : super(
         retry: null,
         name: r'myBookingRowsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$myBookingRowsHash();

  @override
  String toString() {
    return r'myBookingRowsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<BookingRowInfo>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BookingRowInfo>> create(Ref ref) {
    final argument = this.argument as BookingSegment;
    return myBookingRows(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MyBookingRowsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$myBookingRowsHash() => r'092115d95243c18cfd41d5139911be6afb131f40';

/// The same lists with the names each row shows: facility, unit and trainer.

final class MyBookingRowsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<BookingRowInfo>>,
          BookingSegment
        > {
  MyBookingRowsFamily._()
    : super(
        retry: null,
        name: r'myBookingRowsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The same lists with the names each row shows: facility, unit and trainer.

  MyBookingRowsProvider call(BookingSegment segment) =>
      MyBookingRowsProvider._(argument: segment, from: this);

  @override
  String toString() => r'myBookingRowsProvider';
}

/// The details of one booking of the signed-in person, or null when it does
/// not exist or is somebody else's (FR-009: nothing is revealed). Reloads when
/// bookings, payments or the minute change.

@ProviderFor(bookingDetails)
final bookingDetailsProvider = BookingDetailsFamily._();

/// The details of one booking of the signed-in person, or null when it does
/// not exist or is somebody else's (FR-009: nothing is revealed). Reloads when
/// bookings, payments or the minute change.

final class BookingDetailsProvider
    extends
        $FunctionalProvider<
          AsyncValue<BookingDetails?>,
          BookingDetails?,
          FutureOr<BookingDetails?>
        >
    with $FutureModifier<BookingDetails?>, $FutureProvider<BookingDetails?> {
  /// The details of one booking of the signed-in person, or null when it does
  /// not exist or is somebody else's (FR-009: nothing is revealed). Reloads when
  /// bookings, payments or the minute change.
  BookingDetailsProvider._({
    required BookingDetailsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'bookingDetailsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookingDetailsHash();

  @override
  String toString() {
    return r'bookingDetailsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<BookingDetails?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BookingDetails?> create(Ref ref) {
    final argument = this.argument as String;
    return bookingDetails(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BookingDetailsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookingDetailsHash() => r'd18dfa5f821007fe5f97b6495133bab1f3bfd85f';

/// The details of one booking of the signed-in person, or null when it does
/// not exist or is somebody else's (FR-009: nothing is revealed). Reloads when
/// bookings, payments or the minute change.

final class BookingDetailsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<BookingDetails?>, String> {
  BookingDetailsFamily._()
    : super(
        retry: null,
        name: r'bookingDetailsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The details of one booking of the signed-in person, or null when it does
  /// not exist or is somebody else's (FR-009: nothing is revealed). Reloads when
  /// bookings, payments or the minute change.

  BookingDetailsProvider call(String bookingId) =>
      BookingDetailsProvider._(argument: bookingId, from: this);

  @override
  String toString() => r'bookingDetailsProvider';
}
