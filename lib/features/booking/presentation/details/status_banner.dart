import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/core/widgets/banner/banner.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/cancel_preview.dart';
import 'package:sprint/features/booking/presentation/cancel/cancel_wording.dart';
import 'package:sprint/features/booking/presentation/providers/my_bookings_providers.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The one banner a booking's details (and the cancel result) show for its
/// state, or nothing (FR-MYB-02, BR-30, BR-31, BR-32, BR-41, BR-48). Money
/// sentences come from the amounts, never from text.
class StatusBanner extends StatelessWidget {
  const StatusBanner({required this.details, required this.now, super.key});

  final BookingDetails details;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final format = SprintFormat.of(context);
    final b = details.booking;
    switch (b.status) {
      case BookingStatus.pendingPayment:
        final left = b.holdExpiresAt == null
            ? 0
            : (b.holdExpiresAt!.difference(now).inSeconds / 60).ceil().clamp(
                0,
                1 << 20,
              );
        return SprintBanner(
          tone: SprintBannerTone.hold,
          icon: PhosphorIconsRegular.hourglass,
          text:
              '${l10n.bookingDetailsHoldTitle}\n${l10n.bookingDetailsHoldSub(left)}',
        );
      case BookingStatus.confirmed:
        if (details.cancelPreview.kind != CancelKind.closed) {
          return const SizedBox.shrink();
        }
        final until = CairoTime.toCairo(details.cancelPreview.cancelUntil);
        return SprintBanner(
          tone: SprintBannerTone.info,
          icon: PhosphorIconsRegular.clock,
          text: l10n.bookingDetailsAfterCutoff(
            '${format.date(until)} ${format.localTime(until)}',
          ),
        );
      case BookingStatus.attended:
        return SprintBanner(
          tone: SprintBannerTone.info,
          icon: PhosphorIconsRegular.checkCircle,
          text: l10n.bookingDetailsAttended,
        );
      case BookingStatus.noShow:
        return SprintBanner(
          tone: SprintBannerTone.info,
          icon: PhosphorIconsRegular.userMinus,
          text: l10n.bookingDetailsNoShow,
        );
      case BookingStatus.expired:
        return SprintBanner(
          tone: SprintBannerTone.info,
          icon: PhosphorIconsRegular.hourglass,
          text: l10n.bookingDetailsExpired,
        );
      case BookingStatus.cancelled:
        return _cancelled(context, l10n, format);
    }
  }

  Widget _cancelled(
    BuildContext context,
    AppLocalizations l10n,
    SprintFormat format,
  ) {
    final b = details.booking;
    if (b.cancelledBy == CancelledBy.admin) {
      // BR-32, BR-41: the facility cancelled, everything comes back, and the
      // booker was told right away.
      final parts = <String>[
        l10n.bookingDetailsCancelledByFacility,
        if (b.cancelReason != null && b.cancelReason!.trim().isNotEmpty)
          l10n.bookingDetailsCancelReason(b.cancelReason!.trim()),
        if (details.paidAmount > 0)
          l10n.bookingDetailsFacilityRefund(format.price(details.paidAmount)),
      ];
      // The facility's cancel is good news for the booker: everything comes
      // back (BR-32), so the tone is success.
      return SprintBanner(
        tone: SprintBannerTone.success,
        icon: PhosphorIconsRegular.xCircle,
        text: parts.join('. '),
      );
    }
    final line = CancelWording.refundLine(
      context,
      booking: b,
      paidAmount: details.paidAmount,
      refundAmount: details.refundAmount,
    );
    final refunded = details.refundAmount > 0;
    return SprintBanner(
      tone: refunded ? SprintBannerTone.success : SprintBannerTone.neutral,
      icon: refunded
          ? PhosphorIconsRegular.checkCircle
          : PhosphorIconsRegular.xCircle,
      text: line,
    );
  }
}
