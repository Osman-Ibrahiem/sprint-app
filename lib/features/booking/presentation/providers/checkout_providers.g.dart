// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkout_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(checkoutAccess)
final checkoutAccessProvider = CheckoutAccessFamily._();

final class CheckoutAccessProvider
    extends
        $FunctionalProvider<
          AsyncValue<CheckoutAccess>,
          CheckoutAccess,
          FutureOr<CheckoutAccess>
        >
    with $FutureModifier<CheckoutAccess>, $FutureProvider<CheckoutAccess> {
  CheckoutAccessProvider._({
    required CheckoutAccessFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'checkoutAccessProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$checkoutAccessHash();

  @override
  String toString() {
    return r'checkoutAccessProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CheckoutAccess> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CheckoutAccess> create(Ref ref) {
    final argument = this.argument as String;
    return checkoutAccess(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CheckoutAccessProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$checkoutAccessHash() => r'4eb1cd9634880b01ce38fb76329616cbca583f9b';

final class CheckoutAccessFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CheckoutAccess>, String> {
  CheckoutAccessFamily._()
    : super(
        retry: null,
        name: r'checkoutAccessProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CheckoutAccessProvider call(String bookingId) =>
      CheckoutAccessProvider._(argument: bookingId, from: this);

  @override
  String toString() => r'checkoutAccessProvider';
}

/// A booking with its latest payment and refund, kept up to date from the
/// repository (the screens only watch; they never confirm anything, BR-28).

@ProviderFor(bookingCheckout)
final bookingCheckoutProvider = BookingCheckoutFamily._();

/// A booking with its latest payment and refund, kept up to date from the
/// repository (the screens only watch; they never confirm anything, BR-28).

final class BookingCheckoutProvider
    extends
        $FunctionalProvider<
          AsyncValue<BookingCheckoutState>,
          BookingCheckoutState,
          Stream<BookingCheckoutState>
        >
    with
        $FutureModifier<BookingCheckoutState>,
        $StreamProvider<BookingCheckoutState> {
  /// A booking with its latest payment and refund, kept up to date from the
  /// repository (the screens only watch; they never confirm anything, BR-28).
  BookingCheckoutProvider._({
    required BookingCheckoutFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'bookingCheckoutProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookingCheckoutHash();

  @override
  String toString() {
    return r'bookingCheckoutProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<BookingCheckoutState> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<BookingCheckoutState> create(Ref ref) {
    final argument = this.argument as String;
    return bookingCheckout(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BookingCheckoutProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookingCheckoutHash() => r'0bca321d9d3fd33efb7835fbf6e6fa7d71e397fb';

/// A booking with its latest payment and refund, kept up to date from the
/// repository (the screens only watch; they never confirm anything, BR-28).

final class BookingCheckoutFamily extends $Family
    with $FunctionalFamilyOverride<Stream<BookingCheckoutState>, String> {
  BookingCheckoutFamily._()
    : super(
        retry: null,
        name: r'bookingCheckoutProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A booking with its latest payment and refund, kept up to date from the
  /// repository (the screens only watch; they never confirm anything, BR-28).

  BookingCheckoutProvider call(String bookingId) =>
      BookingCheckoutProvider._(argument: bookingId, from: this);

  @override
  String toString() => r'bookingCheckoutProvider';
}

/// One tick a second while a screen shows a countdown, from the app clock.

@ProviderFor(checkoutTick)
final checkoutTickProvider = CheckoutTickProvider._();

/// One tick a second while a screen shows a countdown, from the app clock.

final class CheckoutTickProvider
    extends
        $FunctionalProvider<AsyncValue<DateTime>, DateTime, Stream<DateTime>>
    with $FutureModifier<DateTime>, $StreamProvider<DateTime> {
  /// One tick a second while a screen shows a countdown, from the app clock.
  CheckoutTickProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checkoutTickProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkoutTickHash();

  @$internal
  @override
  $StreamProviderElement<DateTime> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<DateTime> create(Ref ref) {
    return checkoutTick(ref);
  }
}

String _$checkoutTickHash() => r'169c543f7a15afe8f80205dbc229fca861f34069';

/// When the booker came back from the provider page, per booking. Processing
/// is counted from here or from the payment's start, whichever is later.

@ProviderFor(CheckoutReturnedAt)
final checkoutReturnedAtProvider = CheckoutReturnedAtFamily._();

/// When the booker came back from the provider page, per booking. Processing
/// is counted from here or from the payment's start, whichever is later.
final class CheckoutReturnedAtProvider
    extends $NotifierProvider<CheckoutReturnedAt, DateTime?> {
  /// When the booker came back from the provider page, per booking. Processing
  /// is counted from here or from the payment's start, whichever is later.
  CheckoutReturnedAtProvider._({
    required CheckoutReturnedAtFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'checkoutReturnedAtProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$checkoutReturnedAtHash();

  @override
  String toString() {
    return r'checkoutReturnedAtProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CheckoutReturnedAt create() => CheckoutReturnedAt();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CheckoutReturnedAtProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$checkoutReturnedAtHash() =>
    r'360ed830c94c3bed473ac6f3c113745589c8ca1c';

/// When the booker came back from the provider page, per booking. Processing
/// is counted from here or from the payment's start, whichever is later.

final class CheckoutReturnedAtFamily extends $Family
    with
        $ClassFamilyOverride<
          CheckoutReturnedAt,
          DateTime?,
          DateTime?,
          DateTime?,
          String
        > {
  CheckoutReturnedAtFamily._()
    : super(
        retry: null,
        name: r'checkoutReturnedAtProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// When the booker came back from the provider page, per booking. Processing
  /// is counted from here or from the payment's start, whichever is later.

  CheckoutReturnedAtProvider call(String bookingId) =>
      CheckoutReturnedAtProvider._(argument: bookingId, from: this);

  @override
  String toString() => r'checkoutReturnedAtProvider';
}

/// When the booker came back from the provider page, per booking. Processing
/// is counted from here or from the payment's start, whichever is later.

abstract class _$CheckoutReturnedAt extends $Notifier<DateTime?> {
  late final _$args = ref.$arg as String;
  String get bookingId => _$args;

  DateTime? build(String bookingId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DateTime?, DateTime?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime?, DateTime?>,
              DateTime?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// The state of the checkout screen, derived (FR-024). Null while loading.

@ProviderFor(checkoutView)
final checkoutViewProvider = CheckoutViewFamily._();

/// The state of the checkout screen, derived (FR-024). Null while loading.

final class CheckoutViewProvider
    extends $FunctionalProvider<CheckoutView?, CheckoutView?, CheckoutView?>
    with $Provider<CheckoutView?> {
  /// The state of the checkout screen, derived (FR-024). Null while loading.
  CheckoutViewProvider._({
    required CheckoutViewFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'checkoutViewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$checkoutViewHash();

  @override
  String toString() {
    return r'checkoutViewProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<CheckoutView?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CheckoutView? create(Ref ref) {
    final argument = this.argument as String;
    return checkoutView(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CheckoutView? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CheckoutView?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CheckoutViewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$checkoutViewHash() => r'f5667fb07bebf0279a3430a01d5f4dad741ca57c';

/// The state of the checkout screen, derived (FR-024). Null while loading.

final class CheckoutViewFamily extends $Family
    with $FunctionalFamilyOverride<CheckoutView?, String> {
  CheckoutViewFamily._()
    : super(
        retry: null,
        name: r'checkoutViewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The state of the checkout screen, derived (FR-024). Null while loading.

  CheckoutViewProvider call(String bookingId) =>
      CheckoutViewProvider._(argument: bookingId, from: this);

  @override
  String toString() => r'checkoutViewProvider';
}

/// Time left on the Hold, from `holdExpiresAt` and the clock; never its own
/// start (R8), so it survives backgrounding, resizing and folding. At zero it
/// asks the repository to apply the Hold rule instead of deciding itself.

@ProviderFor(holdCountdown)
final holdCountdownProvider = HoldCountdownFamily._();

/// Time left on the Hold, from `holdExpiresAt` and the clock; never its own
/// start (R8), so it survives backgrounding, resizing and folding. At zero it
/// asks the repository to apply the Hold rule instead of deciding itself.

final class HoldCountdownProvider
    extends $FunctionalProvider<Duration?, Duration?, Duration?>
    with $Provider<Duration?> {
  /// Time left on the Hold, from `holdExpiresAt` and the clock; never its own
  /// start (R8), so it survives backgrounding, resizing and folding. At zero it
  /// asks the repository to apply the Hold rule instead of deciding itself.
  HoldCountdownProvider._({
    required HoldCountdownFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'holdCountdownProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$holdCountdownHash();

  @override
  String toString() {
    return r'holdCountdownProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Duration?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Duration? create(Ref ref) {
    final argument = this.argument as String;
    return holdCountdown(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HoldCountdownProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$holdCountdownHash() => r'fed08e67718bd4be1f56e76ef4ed42ff4c039060';

/// Time left on the Hold, from `holdExpiresAt` and the clock; never its own
/// start (R8), so it survives backgrounding, resizing and folding. At zero it
/// asks the repository to apply the Hold rule instead of deciding itself.

final class HoldCountdownFamily extends $Family
    with $FunctionalFamilyOverride<Duration?, String> {
  HoldCountdownFamily._()
    : super(
        retry: null,
        name: r'holdCountdownProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Time left on the Hold, from `holdExpiresAt` and the clock; never its own
  /// start (R8), so it survives backgrounding, resizing and folding. At zero it
  /// asks the repository to apply the Hold rule instead of deciding itself.

  HoldCountdownProvider call(String bookingId) =>
      HoldCountdownProvider._(argument: bookingId, from: this);

  @override
  String toString() => r'holdCountdownProvider';
}

@ProviderFor(checkoutSettings)
final checkoutSettingsProvider = CheckoutSettingsFamily._();

final class CheckoutSettingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<CheckoutSettings>,
          CheckoutSettings,
          FutureOr<CheckoutSettings>
        >
    with $FutureModifier<CheckoutSettings>, $FutureProvider<CheckoutSettings> {
  CheckoutSettingsProvider._({
    required CheckoutSettingsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'checkoutSettingsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$checkoutSettingsHash();

  @override
  String toString() {
    return r'checkoutSettingsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CheckoutSettings> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CheckoutSettings> create(Ref ref) {
    final argument = this.argument as String;
    return checkoutSettings(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CheckoutSettingsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$checkoutSettingsHash() => r'1ba70fbf7906b276d8b142d6ab625f3826f0024a';

final class CheckoutSettingsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CheckoutSettings>, String> {
  CheckoutSettingsFamily._()
    : super(
        retry: null,
        name: r'checkoutSettingsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CheckoutSettingsProvider call(String bookingId) =>
      CheckoutSettingsProvider._(argument: bookingId, from: this);

  @override
  String toString() => r'checkoutSettingsProvider';
}

/// The booking as the summary rows show it (names and quote-shaped values),
/// built from the stored booking so checkout and confirmation reuse the 005
/// rows (FR-024).

@ProviderFor(checkoutSummary)
final checkoutSummaryProvider = CheckoutSummaryFamily._();

/// The booking as the summary rows show it (names and quote-shaped values),
/// built from the stored booking so checkout and confirmation reuse the 005
/// rows (FR-024).

final class CheckoutSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<BookingSummaryView?>,
          BookingSummaryView?,
          FutureOr<BookingSummaryView?>
        >
    with
        $FutureModifier<BookingSummaryView?>,
        $FutureProvider<BookingSummaryView?> {
  /// The booking as the summary rows show it (names and quote-shaped values),
  /// built from the stored booking so checkout and confirmation reuse the 005
  /// rows (FR-024).
  CheckoutSummaryProvider._({
    required CheckoutSummaryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'checkoutSummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$checkoutSummaryHash();

  @override
  String toString() {
    return r'checkoutSummaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<BookingSummaryView?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BookingSummaryView?> create(Ref ref) {
    final argument = this.argument as String;
    return checkoutSummary(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CheckoutSummaryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$checkoutSummaryHash() => r'0a297e9f5c0006f2bb765c295d6560a682460cc3';

/// The booking as the summary rows show it (names and quote-shaped values),
/// built from the stored booking so checkout and confirmation reuse the 005
/// rows (FR-024).

final class CheckoutSummaryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<BookingSummaryView?>, String> {
  CheckoutSummaryFamily._()
    : super(
        retry: null,
        name: r'checkoutSummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The booking as the summary rows show it (names and quote-shaped values),
  /// built from the stored booking so checkout and confirmation reuse the 005
  /// rows (FR-024).

  CheckoutSummaryProvider call(String bookingId) =>
      CheckoutSummaryProvider._(argument: bookingId, from: this);

  @override
  String toString() => r'checkoutSummaryProvider';
}

/// The receipt of a paid, confirmed booking of the signed-in person, or null
/// (FR-025). Never someone else's, never for a free booking.

@ProviderFor(receipt)
final receiptProvider = ReceiptFamily._();

/// The receipt of a paid, confirmed booking of the signed-in person, or null
/// (FR-025). Never someone else's, never for a free booking.

final class ReceiptProvider
    extends
        $FunctionalProvider<AsyncValue<Receipt?>, Receipt?, FutureOr<Receipt?>>
    with $FutureModifier<Receipt?>, $FutureProvider<Receipt?> {
  /// The receipt of a paid, confirmed booking of the signed-in person, or null
  /// (FR-025). Never someone else's, never for a free booking.
  ReceiptProvider._({
    required ReceiptFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'receiptProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$receiptHash();

  @override
  String toString() {
    return r'receiptProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Receipt?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Receipt?> create(Ref ref) {
    final argument = this.argument as String;
    return receipt(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ReceiptProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$receiptHash() => r'e9cf9f1bb94f94a6bc868ae73b2b33cd2113ed27';

/// The receipt of a paid, confirmed booking of the signed-in person, or null
/// (FR-025). Never someone else's, never for a free booking.

final class ReceiptFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Receipt?>, String> {
  ReceiptFamily._()
    : super(
        retry: null,
        name: r'receiptProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The receipt of a paid, confirmed booking of the signed-in person, or null
  /// (FR-025). Never someone else's, never for a free booking.

  ReceiptProvider call(String bookingId) =>
      ReceiptProvider._(argument: bookingId, from: this);

  @override
  String toString() => r'receiptProvider';
}

/// Keeps Holds honest while the app is open, also off the checkout screen
/// (FR-004): one timer, set for the earliest Hold of the signed-in person's
/// pending bookings, that asks the repository to apply the Hold rule (expire,
/// or extend while a payment is pending, BR-12, BR-46) and then re-arms.

@ProviderFor(holdHousekeeping)
final holdHousekeepingProvider = HoldHousekeepingProvider._();

/// Keeps Holds honest while the app is open, also off the checkout screen
/// (FR-004): one timer, set for the earliest Hold of the signed-in person's
/// pending bookings, that asks the repository to apply the Hold rule (expire,
/// or extend while a payment is pending, BR-12, BR-46) and then re-arms.

final class HoldHousekeepingProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Keeps Holds honest while the app is open, also off the checkout screen
  /// (FR-004): one timer, set for the earliest Hold of the signed-in person's
  /// pending bookings, that asks the repository to apply the Hold rule (expire,
  /// or extend while a payment is pending, BR-12, BR-46) and then re-arms.
  HoldHousekeepingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'holdHousekeepingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$holdHousekeepingHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return holdHousekeeping(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$holdHousekeepingHash() => r'3daf4813cc3e94facb3923961d5b85608c7b9d74';

/// The checkout location of the booking a provider session belongs to, when
/// the signed-in person has such a booking (a session the fake no longer
/// knows after a restart); null otherwise (FR-024).

@ProviderFor(bookingOfSession)
final bookingOfSessionProvider = BookingOfSessionFamily._();

/// The checkout location of the booking a provider session belongs to, when
/// the signed-in person has such a booking (a session the fake no longer
/// knows after a restart); null otherwise (FR-024).

final class BookingOfSessionProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// The checkout location of the booking a provider session belongs to, when
  /// the signed-in person has such a booking (a session the fake no longer
  /// knows after a restart); null otherwise (FR-024).
  BookingOfSessionProvider._({
    required BookingOfSessionFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'bookingOfSessionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookingOfSessionHash();

  @override
  String toString() {
    return r'bookingOfSessionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as String;
    return bookingOfSession(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BookingOfSessionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookingOfSessionHash() => r'a56027d57bf881ff0b1b1407618bbbb5fd3c66ab';

/// The checkout location of the booking a provider session belongs to, when
/// the signed-in person has such a booking (a session the fake no longer
/// knows after a restart); null otherwise (FR-024).

final class BookingOfSessionFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, String> {
  BookingOfSessionFamily._()
    : super(
        retry: null,
        name: r'bookingOfSessionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The checkout location of the booking a provider session belongs to, when
  /// the signed-in person has such a booking (a session the fake no longer
  /// knows after a restart); null otherwise (FR-024).

  BookingOfSessionProvider call(String sessionId) =>
      BookingOfSessionProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'bookingOfSessionProvider';
}
