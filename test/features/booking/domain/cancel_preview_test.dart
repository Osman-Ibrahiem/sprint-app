import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/cancel_preview.dart';
import 'package:sprint/features/booking/domain/cancellation_policy.dart';

import '../../../helpers/domain_builders.dart';

/// The one cancellation rule the dialog and the repository share (BR-30 –
/// BR-32, BR-48): what kind of refund applies, how much, and until when.
void main() {
  const policy = CancellationPolicy();
  final start = cairo(2026, 11, 18, 18); // slot 6 pm - 7 pm
  final beforeCutoff = start.subtract(const Duration(hours: 5));

  CancelPreview preview({
    Booking? booking_,
    DateTime? now,
    CancelledBy by = CancelledBy.owner,
    int cutoffHours = 2,
    int refundPercent = 100,
    int paidAmount = 80,
    bool paymentPending = false,
  }) =>
      policy.preview(
        booking: booking_ ?? booking(start: start),
        now: now ?? beforeCutoff,
        by: by,
        cutoffHours: cutoffHours,
        refundPercent: refundPercent,
        paidAmount: paidAmount,
        paymentPending: paymentPending,
      );

  test('100% is a full refund of everything paid', () {
    final p = preview();
    expect(p.kind, CancelKind.full);
    expect(p.paidAmount, 80);
    expect(p.refundAmount, 80);
    expect(p.refundPercent, 100);
    expect(p.cancelUntil, start.subtract(const Duration(hours: 2)));
  });

  test('50 on 80 is a partial refund of 40', () {
    final p = preview(refundPercent: 50);
    expect(p.kind, CancelKind.partial);
    expect(p.refundAmount, 40);
    expect(p.paidAmount, 80);
  });

  test('0 percent is no refund at all', () {
    final p = preview(refundPercent: 0);
    expect(p.kind, CancelKind.none);
    expect(p.refundAmount, 0);
  });

  test('a free booking is nothing paid and nothing returned', () {
    final p = preview(
      booking_: booking(start: start, price: 0),
      paidAmount: 0,
    );
    expect(p.kind, CancelKind.free);
    expect(p.paidAmount, 0);
    expect(p.refundAmount, 0);
  });

  test('after the cutoff the preview is closed, never a refund', () {
    final p = preview(now: start.subtract(const Duration(minutes: 119)));
    expect(p.kind, CancelKind.closed);
    expect(p.refundAmount, 0);
  });

  test('at the cutoff instant the cancel is still open', () {
    final p = preview(now: start.subtract(const Duration(hours: 2)));
    expect(p.kind, CancelKind.full);
  });

  test('every other status and a payment being processed are not allowed', () {
    for (final status in [
      BookingStatus.attended,
      BookingStatus.noShow,
      BookingStatus.cancelled,
      BookingStatus.expired,
    ]) {
      expect(
        preview(booking_: booking(start: start, status: status)).kind,
        CancelKind.notAllowed,
        reason: '$status',
      );
    }
    expect(
      preview(
        booking_: booking(
          start: start,
          status: BookingStatus.pendingPayment,
          holdExpiresAt: beforeCutoff.add(const Duration(minutes: 10)),
        ),
        paymentPending: true,
      ).kind,
      CancelKind.notAllowed,
    );
  });

  test('a booking holding with no payment pending is cancelled with no refund '
      '(BR-48)', () {
    final p = preview(
      booking_: booking(
        start: start,
        status: BookingStatus.pendingPayment,
        holdExpiresAt: beforeCutoff.add(const Duration(minutes: 10)),
      ),
      paidAmount: 0,
    );
    expect(p.kind, CancelKind.free);
    expect(p.refundAmount, 0);
  });

  test('a Hold that already ended cannot be cancelled (BR-48)', () {
    final p = preview(
      booking_: booking(
        start: start,
        status: BookingStatus.pendingPayment,
        holdExpiresAt: beforeCutoff.subtract(const Duration(minutes: 1)),
      ),
      paidAmount: 0,
    );
    expect(p.kind, CancelKind.notAllowed);
  });

  test('a facility cancel is always a full refund whatever the setting '
      '(BR-32)', () {
    final p = preview(by: CancelledBy.admin, refundPercent: 0);
    expect(p.kind, CancelKind.full);
    expect(p.refundAmount, 80);
  });

  test('a facility cancel after the end is not allowed (BR-32)', () {
    final p = preview(
      by: CancelledBy.admin,
      now: start.add(const Duration(hours: 1)),
    );
    expect(p.kind, CancelKind.notAllowed);
  });

  test('decide() speaks the same language as preview()', () {
    CancellationDecision? ok(Result<CancellationDecision> r) =>
        r is Ok<CancellationDecision> ? r.value : null;
    Failure? err(Result<CancellationDecision> r) =>
        r is Err<CancellationDecision> ? r.failure : null;

    final full = policy.decide(
      booking: booking(start: start),
      now: beforeCutoff,
      by: CancelledBy.owner,
      cutoffHours: 2,
      refundPercent: 100,
      paidAmount: 80,
    );
    expect(ok(full)!.refundAmount, preview().refundAmount);

    final closed = policy.decide(
      booking: booking(start: start),
      now: start.subtract(const Duration(minutes: 1)),
      by: CancelledBy.owner,
      cutoffHours: 2,
      refundPercent: 100,
      paidAmount: 80,
    );
    expect(err(closed), isA<CancellationClosed>());
  });

  test('canOfferCancel is the single "button shown" check', () {
    final confirmed = booking(start: start);
    expect(
      policy.canOfferCancel(confirmed, beforeCutoff, cutoffHours: 2),
      isTrue,
    );
    expect(
      policy.canOfferCancel(
        confirmed,
        start.subtract(const Duration(minutes: 1)),
        cutoffHours: 2,
      ),
      isFalse,
    );

    final holding = booking(
      start: start,
      status: BookingStatus.pendingPayment,
      holdExpiresAt: beforeCutoff.add(const Duration(minutes: 10)),
    );
    expect(
      policy.canOfferCancel(holding, beforeCutoff, cutoffHours: 2),
      isTrue,
    );
    expect(
      policy.canOfferCancel(
        holding,
        beforeCutoff,
        cutoffHours: 2,
        paymentPending: true,
      ),
      isFalse,
    );
    expect(
      policy.canOfferCancel(
        booking(start: start, status: BookingStatus.attended),
        beforeCutoff,
        cutoffHours: 2,
      ),
      isFalse,
    );
  });
}
