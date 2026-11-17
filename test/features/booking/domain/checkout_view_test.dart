import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/booking_repository.dart';
import 'package:sprint/features/booking/domain/checkout_view.dart';
import 'package:sprint/features/payments/domain/payment.dart';

import '../../../helpers/domain_builders.dart';

void main() {
  final t0 = cairo(2026, 11, 18, 10);
  final start = cairo(2026, 11, 20, 17);

  Booking b({
    BookingStatus status = BookingStatus.pendingPayment,
    Duration expiresIn = const Duration(minutes: 8),
    Duration maxIn = const Duration(minutes: 18),
  }) =>
      booking(
        start: start,
        status: status,
        holdStartedAt: t0,
        holdExpiresAt: t0.add(expiresIn),
        holdMaxExpiresAt: t0.add(maxIn),
      );

  Payment p(PaymentStatus s, {Duration startedAgo = Duration.zero}) => Payment(
        id: 'p',
        bookingId: 'b',
        provider: 'FAKE',
        providerRef: 'r',
        amount: 80,
        status: s,
        startedAt: t0.subtract(startedAgo),
        owningUnitId: 'ou1',
      );

  BookingCheckoutState st(Booking booking, [Payment? payment]) =>
      BookingCheckoutState(booking: booking, latestPayment: payment);

  final cases = <String, (BookingCheckoutState?, Duration after, CheckoutView)>{
    'no state': (null, Duration.zero, CheckoutView.notFound),
    'pending, no payment': (st(b()), Duration.zero, CheckoutView.holding),
    'pending, under a minute left':
        (st(b()), const Duration(minutes: 7, seconds: 1), CheckoutView.lastMinute),
    'pending, exactly 60 s left':
        (st(b()), const Duration(minutes: 7), CheckoutView.holding),
    'payment pending, just started':
        (st(b(), p(PaymentStatus.pending)), const Duration(seconds: 5), CheckoutView.processing),
    'payment pending, 20 s on':
        (st(b(), p(PaymentStatus.pending)), const Duration(seconds: 20), CheckoutView.awaiting),
    'payment failed': (st(b(), p(PaymentStatus.failed)), Duration.zero, CheckoutView.failed),
    'payment cancelled':
        (st(b(), p(PaymentStatus.cancelled)), Duration.zero, CheckoutView.cancelled),
    'confirmed': (st(b(status: BookingStatus.confirmed), p(PaymentStatus.succeeded)),
        Duration.zero, CheckoutView.confirmed),
    'free booking confirmed':
        (st(b(status: BookingStatus.confirmed)), Duration.zero, CheckoutView.confirmed),
    'expired booking': (st(b(status: BookingStatus.expired), p(PaymentStatus.pending)),
        Duration.zero, CheckoutView.expired),
    'Hold over, no payment':
        (st(b()), const Duration(minutes: 8), CheckoutView.expired),
    'Hold over, failed':
        (st(b(), p(PaymentStatus.failed)), const Duration(minutes: 8), CheckoutView.expired),
    'Hold over, payment pending: waits for the provider':
        (st(b(), p(PaymentStatus.pending)), const Duration(minutes: 9), CheckoutView.awaiting),
    'maximum over, payment pending':
        (st(b(), p(PaymentStatus.pending)), const Duration(minutes: 18), CheckoutView.expired),
    'cancelled booking': (st(b(status: BookingStatus.cancelled)), Duration.zero,
        CheckoutView.notFound),
  };

  cases.forEach((name, c) {
    test(name, () {
      expect(checkoutViewOf(c.$1, t0.add(c.$2)), c.$3);
    });
  });

  test('processing starts from processingSince when it is later', () {
    final s = st(b(), p(PaymentStatus.pending));
    final back = t0.add(const Duration(seconds: 50));
    expect(
      checkoutViewOf(s, back.add(const Duration(seconds: 5)), processingSince: back),
      CheckoutView.processing,
    );
    expect(
      checkoutViewOf(s, back.add(const Duration(seconds: 21)), processingSince: back),
      CheckoutView.awaiting,
    );
  });

  test('processingWait is honoured', () {
    final s = st(b(), p(PaymentStatus.pending));
    expect(
      checkoutViewOf(s, t0.add(const Duration(seconds: 3)),
          processingWait: const Duration(seconds: 2)),
      CheckoutView.awaiting,
    );
  });
}
