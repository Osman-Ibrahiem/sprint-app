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

String _$bookingDetailsHash() => r'5b48d7d9fafa5e6368b322357e37fd193a03ce87';

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
