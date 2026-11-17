import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/booking_repository.dart';
import 'package:sprint/features/booking/domain/hold_policy.dart';
import 'package:sprint/features/payments/domain/payment.dart';

/// Which state the checkout screen shows. Derived from the booking and its
/// latest payment, never stored, so a refresh lands on the right one
/// (FR-024, data-model.md).
enum CheckoutView {
  holding,
  lastMinute,
  processing,
  awaiting,
  failed,
  cancelled,
  expired,
  confirmed,
  notFound,
}

/// The last minute of the Hold, when the banner turns urgent (FR-031).
const Duration lastMinuteWindow = Duration(seconds: 60);

/// [processingSince] is when processing began (the payment's `startedAt`, or
/// the moment the booker came back from the provider page, whichever is
/// later); [processingWait] is how long processing may last before the screen
/// says it is still waiting.
CheckoutView checkoutViewOf(
  BookingCheckoutState? state,
  DateTime now, {
  DateTime? processingSince,
  Duration processingWait = const Duration(seconds: 20),
}) {
  if (state == null) return CheckoutView.notFound;
  final b = state.booking;
  final payment = state.latestPayment;
  switch (b.status) {
    case BookingStatus.confirmed:
      return CheckoutView.confirmed;
    case BookingStatus.expired:
      return CheckoutView.expired;
    case BookingStatus.pendingPayment:
      break;
    case BookingStatus.cancelled ||
          BookingStatus.attended ||
          BookingStatus.noShow:
      return CheckoutView.notFound;
  }

  final status = payment?.status;
  final pending = status == PaymentStatus.pending;

  // The Hold may have run out a moment before the repository acts on it.
  if (const HoldPolicy().nextExpiry(b, now, hasPendingPayment: pending)
      is HoldExpire) {
    return CheckoutView.expired;
  }

  switch (status) {
    case PaymentStatus.pending || PaymentStatus.succeeded:
      final since = processingSince ?? payment!.startedAt;
      return now.difference(since) >= processingWait
          ? CheckoutView.awaiting
          : CheckoutView.processing;
    case PaymentStatus.failed:
      return CheckoutView.failed;
    case PaymentStatus.cancelled:
      return CheckoutView.cancelled;
    case null:
      final expires = b.holdExpiresAt;
      return expires != null && expires.difference(now) < lastMinuteWindow
          ? CheckoutView.lastMinute
          : CheckoutView.holding;
  }
}
