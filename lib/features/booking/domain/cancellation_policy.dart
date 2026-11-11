import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/features/booking/domain/booking.dart';

class CancellationDecision {
  const CancellationDecision({required this.refundAmount});

  /// Whole Egyptian pounds to give back.
  final int refundAmount;
}

/// Who may cancel, until when, and how much is refunded (BR-30 – BR-32). Pure.
class CancellationPolicy {
  const CancellationPolicy();

  Result<CancellationDecision> decide({
    required Booking booking,
    required DateTime now,
    required CancelledBy by,
    required int cutoffHours,
    required int refundPercent,
    required int paidAmount,
  }) {
    if (booking.status != BookingStatus.confirmed) {
      return const Err(InvalidTransition());
    }
    if (by == CancelledBy.admin) {
      // BR-32: the facility cancelled, so always a full refund.
      if (!now.isBefore(booking.end)) return const Err(InvalidTransition());
      return Ok(CancellationDecision(refundAmount: paidAmount));
    }
    if (!canOfferCancel(booking, now, cutoffHours: cutoffHours)) {
      return const Err(CancellationClosed());
    }
    return Ok(CancellationDecision(refundAmount: paidAmount * refundPercent ~/ 100));
  }

  /// BR-30, BR-40: the owner may cancel up to [cutoffHours] before the start,
  /// and a reminder offers the button only while that holds.
  bool canOfferCancel(Booking booking, DateTime at, {required int cutoffHours}) =>
      !at.isAfter(booking.start.subtract(Duration(hours: cutoffHours)));
}
