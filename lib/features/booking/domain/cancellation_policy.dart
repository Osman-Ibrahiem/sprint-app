import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/cancel_preview.dart';

class CancellationDecision {
  const CancellationDecision({required this.refundAmount});

  /// Whole Egyptian pounds to give back.
  final int refundAmount;
}

/// Who may cancel, until when, and how much is refunded (BR-30 – BR-32,
/// BR-48). Pure: the settings and the paid amount arrive as arguments, so the
/// dialog, a reminder and the repository can never disagree.
class CancellationPolicy {
  const CancellationPolicy();

  /// The one preview behind every cancel decision. [by] is `admin` when the
  /// facility cancels (always a full refund, BR-32); [paymentPending] is the
  /// provider still working on a payment (BR-47), which closes the action.
  CancelPreview preview({
    required Booking booking,
    required DateTime now,
    required CancelledBy by,
    required int cutoffHours,
    required int refundPercent,
    required int paidAmount,
    required bool paymentPending,
  }) {
    final cancelUntil = booking.start.subtract(Duration(hours: cutoffHours));

    if (by == CancelledBy.admin) {
      // BR-32: the facility cancelled, so always everything back, and never
      // after the slot has ended.
      final allowed = booking.status == BookingStatus.confirmed &&
          now.isBefore(booking.end);
      return CancelPreview(
        kind: allowed ? CancelKind.full : CancelKind.notAllowed,
        paidAmount: paidAmount,
        refundAmount: allowed ? paidAmount : 0,
        refundPercent: refundPercent,
        cancelUntil: cancelUntil,
      );
    }

    // BR-48: a booking still holding, with no payment being processed.
    if (booking.status == BookingStatus.pendingPayment) {
      final hold = booking.holdExpiresAt;
      final allowed = !paymentPending &&
          hold != null &&
          now.isBefore(hold) &&
          now.isBefore(booking.end);
      return CancelPreview(
        kind: allowed ? CancelKind.free : CancelKind.notAllowed,
        paidAmount: 0,
        refundAmount: 0,
        refundPercent: refundPercent,
        cancelUntil: cancelUntil,
      );
    }

    if (booking.status != BookingStatus.confirmed) {
      return CancelPreview(
        kind: CancelKind.notAllowed,
        paidAmount: paidAmount,
        refundAmount: 0,
        refundPercent: refundPercent,
        cancelUntil: cancelUntil,
      );
    }

    // BR-30: up to the cutoff, inclusive, exactly as canOfferCancel says.
    if (now.isAfter(cancelUntil)) {
      return CancelPreview(
        kind: CancelKind.closed,
        paidAmount: paidAmount,
        refundAmount: 0,
        refundPercent: refundPercent,
        cancelUntil: cancelUntil,
      );
    }

    // "Free" is the frozen price being zero, not the facility type.
    if (booking.priceAtBooking == 0) {
      return CancelPreview(
        kind: CancelKind.free,
        paidAmount: 0,
        refundAmount: 0,
        refundPercent: refundPercent,
        cancelUntil: cancelUntil,
      );
    }

    if (paidAmount <= 0) {
      return CancelPreview(
        kind: CancelKind.none,
        paidAmount: 0,
        refundAmount: 0,
        refundPercent: refundPercent,
        cancelUntil: cancelUntil,
      );
    }

    // BR-31: the setting decides the share; whole pounds, rounded down.
    final refund = paidAmount * refundPercent ~/ 100;
    final kind = refund <= 0
        ? CancelKind.none
        : refund >= paidAmount
            ? CancelKind.full
            : CancelKind.partial;
    return CancelPreview(
      kind: kind,
      paidAmount: paidAmount,
      refundAmount: refund,
      refundPercent: refundPercent,
      cancelUntil: cancelUntil,
    );
  }

  Result<CancellationDecision> decide({
    required Booking booking,
    required DateTime now,
    required CancelledBy by,
    required int cutoffHours,
    required int refundPercent,
    required int paidAmount,
    bool paymentPending = false,
  }) {
    final p = preview(
      booking: booking,
      now: now,
      by: by,
      cutoffHours: cutoffHours,
      refundPercent: refundPercent,
      paidAmount: paidAmount,
      paymentPending: paymentPending,
    );
    return switch (p.kind) {
      CancelKind.closed => const Err(CancellationClosed()),
      CancelKind.notAllowed => const Err(InvalidTransition()),
      _ => Ok(CancellationDecision(refundAmount: p.refundAmount)),
    };
  }

  /// BR-30, BR-40, BR-48: the one "is the cancel action shown" check, used by
  /// the details, the reminder and the dialog's re-check at confirmation time.
  bool canOfferCancel(
    Booking booking,
    DateTime at, {
    required int cutoffHours,
    bool paymentPending = false,
  }) {
    if (booking.status == BookingStatus.pendingPayment) {
      final hold = booking.holdExpiresAt;
      return !paymentPending &&
          hold != null &&
          at.isBefore(hold) &&
          at.isBefore(booking.end);
    }
    if (booking.status != BookingStatus.confirmed) return false;
    return !at.isAfter(booking.start.subtract(Duration(hours: cutoffHours)));
  }
}
