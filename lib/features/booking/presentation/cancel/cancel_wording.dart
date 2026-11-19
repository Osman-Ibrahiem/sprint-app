import 'package:flutter/widgets.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/cancel_preview.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Wording of the cancel dialog and the result for one [CancelPreview]: every
/// amount comes from the preview (computed from `refundPercent` and the paid
/// amount), never from text (BR-30, BR-31, BR-48). The refund line promises no
/// time, only the way back ("على نفس وسيلة الدفع").
abstract final class CancelWording {
  /// The dialog's message. [pending] is a booking still holding (BR-48).
  static String message(
    BuildContext context,
    CancelPreview p, {
    required bool pending,
  }) {
    final l10n = AppLocalizations.of(context);
    final format = SprintFormat.of(context);
    if (pending) return l10n.cancelMessagePending;
    return switch (p.kind) {
      CancelKind.full => l10n.cancelMessageFull(format.price(p.refundAmount)),
      CancelKind.partial => l10n.cancelMessagePartial(
        format.price(p.refundAmount),
        format.price(p.paidAmount),
      ),
      CancelKind.none => l10n.cancelMessageNone,
      CancelKind.free => l10n.cancelMessageFree,
      CancelKind.closed => l10n.cancelClosedTitle,
      CancelKind.notAllowed => l10n.cancelNotAllowedBody,
    };
  }

  /// The money sentence of the result and of a cancelled booking's details.
  static String refundLine(
    BuildContext context, {
    required Booking booking,
    required int paidAmount,
    required int refundAmount,
  }) {
    final l10n = AppLocalizations.of(context);
    final format = SprintFormat.of(context);
    if (booking.priceAtBooking == 0 || paidAmount == 0) {
      return booking.priceAtBooking == 0
          ? l10n.bookingDetailsFreeCancelled
          : l10n.bookingDetailsPendingCancelled;
    }
    if (refundAmount <= 0) return l10n.bookingDetailsRefundNone;
    if (refundAmount >= paidAmount) {
      return l10n.bookingDetailsRefundFull(format.price(refundAmount));
    }
    return l10n.bookingDetailsRefundPartial(
      format.price(refundAmount),
      format.price(paidAmount),
    );
  }
}
