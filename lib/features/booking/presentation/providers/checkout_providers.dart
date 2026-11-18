import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/booking_quote.dart';
import 'package:sprint/features/booking/domain/booking_repository.dart';
import 'package:sprint/features/booking/domain/booking_summary_view.dart';
import 'package:sprint/features/booking/domain/checkout_view.dart';
import 'package:sprint/features/booking/domain/unit_settings.dart';
import 'package:sprint/features/payments/domain/payment.dart';
import 'package:sprint/features/payments/domain/payment_provider.dart';
import 'package:sprint/features/payments/domain/receipt.dart';
import 'package:sprint/features/settings/domain/setting_registry.dart';

part 'checkout_providers.g.dart';

/// Presentation timings the BRD has no setting for (plan, Complexity
/// Tracking): how long processing may last before the screen says it is still
/// waiting.
abstract final class CheckoutTimings {
  static const Duration processingWait = SprintExtras.checkoutProcessingWait;
}

/// Whether the signed-in person may open a booking's checkout.
enum CheckoutAccess { allowed, notFound, notOwner }

@riverpod
Future<CheckoutAccess> checkoutAccess(Ref ref, String bookingId) async {
  final user = ref.watch(currentSessionProvider).user;
  final result = await ref.watch(bookingRepositoryProvider).get(bookingId);
  if (result is! Ok<Booking>) return CheckoutAccess.notFound;
  return user != null && result.value.userId == user.id
      ? CheckoutAccess.allowed
      : CheckoutAccess.notOwner;
}

/// A booking with its latest payment and refund, kept up to date from the
/// repository (the screens only watch; they never confirm anything, BR-28).
@riverpod
Stream<BookingCheckoutState> bookingCheckout(Ref ref, String bookingId) =>
    ref.watch(bookingRepositoryProvider).watchBooking(bookingId);

/// One tick a second while a screen shows a countdown, from the app clock.
@riverpod
Stream<DateTime> checkoutTick(Ref ref) {
  final clock = ref.watch(appClockProvider);
  final out = StreamController<DateTime>();
  out.add(clock.now());
  final timer = Timer.periodic(
    SprintExtras.countdownTick,
    (_) => out.add(clock.now()),
  );
  ref.onDispose(() {
    timer.cancel();
    out.close();
  });
  return out.stream;
}

/// When the booker came back from the provider page, per booking. Processing
/// is counted from here or from the payment's start, whichever is later.
@Riverpod(keepAlive: true)
class CheckoutReturnedAt extends _$CheckoutReturnedAt {
  @override
  DateTime? build(String bookingId) => null;

  void mark(DateTime at) => state = at;
}

/// The state of the checkout screen, derived (FR-024). Null while loading.
@riverpod
CheckoutView? checkoutView(Ref ref, String bookingId) {
  final async = ref.watch(bookingCheckoutProvider(bookingId));
  final now =
      ref.watch(checkoutTickProvider).value ?? ref.watch(appClockProvider).now();
  final returned = ref.watch(checkoutReturnedAtProvider(bookingId));
  if (async.isLoading && !async.hasValue) return null;
  final state = async.value;
  final started = state?.latestPayment?.startedAt;
  final since = returned != null && (started == null || returned.isAfter(started))
      ? returned
      : started;
  return checkoutViewOf(
    state,
    now,
    processingSince: since,
    processingWait: CheckoutTimings.processingWait,
  );
}

/// The expiries the countdown has already asked the repository to apply, so
/// a rebuild at zero never asks twice.
@Riverpod(keepAlive: true)
Set<String> holdExpiryRequests(Ref ref) => <String>{};

/// Time left on the Hold, from `holdExpiresAt` and the clock; never its own
/// start (R8), so it survives backgrounding, resizing and folding. At zero it
/// asks the repository to apply the Hold rule instead of deciding itself.
@riverpod
Duration? holdCountdown(Ref ref, String bookingId) {
  final state = ref.watch(bookingCheckoutProvider(bookingId)).value;
  final now =
      ref.watch(checkoutTickProvider).value ?? ref.watch(appClockProvider).now();
  final b = state?.booking;
  final expires = b?.holdExpiresAt;
  if (b == null || b.status != BookingStatus.pendingPayment || expires == null) {
    return null;
  }
  final left = expires.difference(now);
  if (left <= Duration.zero) {
    // Ask once per expiry instant, never on every rebuild: the repository
    // applies the rule (and its answer rebuilds this provider).
    if (ref.read(holdExpiryRequestsProvider).add('$bookingId@$expires')) {
      unawaited(Future<void>.microtask(
        () => ref.read(bookingRepositoryProvider).expireHolds(),
      ));
    }
    return Duration.zero;
  }
  return left;
}

/// What the checkout and confirmation screens read from the settings (BR-30,
/// BR-31, BR-39, BR-29), resolved for the booking's unit.
class CheckoutSettings {
  const CheckoutSettings({
    required this.cancellationCutoffHours,
    required this.refundPercent,
    required this.reminderLeadMinutes,
    required this.isTestProvider,
  });

  final int cancellationCutoffHours;
  final int refundPercent;
  final int reminderLeadMinutes;

  /// The provider is the fake or the sandbox: show the test-mode tag.
  final bool isTestProvider;
}

@riverpod
Future<CheckoutSettings> checkoutSettings(Ref ref, String bookingId) async {
  final bookings = ref.watch(bookingRepositoryProvider);
  final settings = ref.watch(settingsRepositoryProvider);
  final got = await bookings.get(bookingId);
  final b = got is Ok<Booking> ? got.value : null;
  final cfg = await UnitSettings.resolve(
    settings,
    unitId: b?.unitId,
    facilityId: b?.facilityId,
  );
  final kind = await settings.resolve(
    SettingKeys.paymentProvider,
    unitId: b?.unitId,
    facilityId: b?.facilityId,
  );
  return CheckoutSettings(
    cancellationCutoffHours: cfg.cancellationCutoffHours,
    refundPercent: cfg.refundPercent,
    reminderLeadMinutes: cfg.reminderLeadMinutes,
    isTestProvider: kind == PaymentProviderKind.fake ||
        kind == PaymentProviderKind.sandbox,
  );
}

/// The booking as the summary rows show it (names and quote-shaped values),
/// built from the stored booking so checkout and confirmation reuse the 005
/// rows (FR-024).
@riverpod
Future<BookingSummaryView?> checkoutSummary(Ref ref, String bookingId) async {
  final bookings = ref.watch(bookingRepositoryProvider);
  final catalogue = ref.watch(catalogueRepositoryProvider);
  final identity = ref.watch(identityRepositoryProvider);
  final settings = await ref.watch(checkoutSettingsProvider(bookingId).future);
  final got = await bookings.get(bookingId);
  if (got is! Ok<Booking>) return null;
  final b = got.value;
  final facility = await catalogue.getFacility(b.facilityId);
  final unit = await catalogue.getUnit(b.unitId);
  final cfg = await UnitSettings.resolve(
    ref.watch(settingsRepositoryProvider),
    unitId: b.unitId,
    facilityId: b.facilityId,
  );
  String? trainerName;
  if (b.trainerId != null) {
    for (final t in await catalogue.trainers(b.facilityId)) {
      if (t.id == b.trainerId) {
        trainerName = (await identity.getUser(t.userId))?.name;
      }
    }
  }
  return BookingSummaryView.from(
    quote: BookingQuote(
      facilityId: b.facilityId,
      unitId: b.unitId,
      trainerId: b.trainerId,
      start: b.start,
      end: b.end,
      tier: b.tierAtBooking,
      amount: b.priceAtBooking,
      mode: cfg.bookingMode,
      maxParticipants: cfg.maxParticipants,
      cancellationCutoffHours: settings.cancellationCutoffHours,
      refundPercent: settings.refundPercent,
    ),
    facilityName: facility?.name ?? '',
    unitName: unit?.name ?? '',
    trainerName: trainerName,
    verificationHint: VerificationHint.none,
  );
}

/// The receipt of a paid, confirmed booking of the signed-in person, or null
/// (FR-025). Never someone else's, never for a free booking.
@riverpod
Future<Receipt?> receipt(Ref ref, String bookingId) async {
  final user = ref.watch(currentSessionProvider).user;
  if (user == null) return null;
  final got = await ref.watch(bookingRepositoryProvider).get(bookingId);
  if (got is! Ok<Booking>) return null;
  final b = got.value;
  if (b.userId != user.id || b.status != BookingStatus.confirmed) return null;
  final payments = ref.watch(paymentRepositoryProvider);
  Payment? paid;
  for (final p in await payments.payments(bookingId)) {
    if (p.status == PaymentStatus.succeeded) paid = p;
  }
  if (paid == null) return null;
  final catalogue = ref.watch(catalogueRepositoryProvider);
  final facility = await catalogue.getFacility(b.facilityId);
  final unit = await catalogue.getUnit(b.unitId);
  if (facility == null || unit == null) return null;
  return Receipt.fromPayment(paid, b, facility, unit);
}

/// Keeps Holds honest while the app is open, also off the checkout screen
/// (FR-004): one timer, set for the earliest Hold of the signed-in person's
/// pending bookings, that asks the repository to apply the Hold rule (expire,
/// or extend while a payment is pending, BR-12, BR-46) and then re-arms.
@Riverpod(keepAlive: true)
bool holdHousekeeping(Ref ref) {
  final user = ref.watch(currentSessionProvider).user;
  final bookings = ref.watch(bookingRepositoryProvider);
  final clock = ref.watch(appClockProvider);
  if (user == null) return false;

  Timer? timer;
  var disposed = false;

  Future<void> arm() async {
    timer?.cancel();
    final mine = await bookings.listForUser(user.id);
    if (disposed) return;
    DateTime? next;
    for (final b in mine) {
      final at = b.holdExpiresAt;
      if (b.status == BookingStatus.pendingPayment &&
          at != null &&
          (next == null || at.isBefore(next))) {
        next = at;
      }
    }
    if (next == null) return;
    var wait = next.difference(clock.now());
    if (wait < SprintExtras.countdownTick) wait = SprintExtras.countdownTick;
    timer = Timer(wait, () => unawaited(bookings.expireHolds()));
  }

  final sub = bookings.changes.listen((_) => unawaited(arm()));
  unawaited(arm());
  ref.onDispose(() {
    disposed = true;
    timer?.cancel();
    unawaited(sub.cancel());
  });
  return true;
}

/// The checkout location of the booking a provider session belongs to, when
/// the signed-in person has such a booking (a session the fake no longer
/// knows after a restart); null otherwise (FR-024).
@riverpod
Future<String?> bookingOfSession(Ref ref, String sessionId) async {
  final user = ref.watch(currentSessionProvider).user;
  if (user == null) return null;
  final bookings = ref.watch(bookingRepositoryProvider);
  final payments = ref.watch(paymentRepositoryProvider);
  for (final b in await bookings.listForUser(user.id)) {
    for (final p in await payments.payments(b.id)) {
      if (p.providerRef == sessionId) {
        return b.status == BookingStatus.confirmed
            ? AppPaths.bookingConfirmed(b.id)
            : AppPaths.bookingCheckoutFor(b.facilityId, b.id);
      }
    }
  }
  return null;
}
