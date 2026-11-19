import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/adaptive/adaptive_pressable.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/features/booking/presentation/bookings/booking_row_data.dart';
import 'package:sprint/core/widgets/status_badge/sprint_status.dart';
import 'package:sprint/core/widgets/status_badge/status_badge.dart';
import 'package:sprint/features/catalogue/domain/home_content.dart';
import 'package:sprint/features/catalogue/presentation/widgets/clock_text.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Compact rows for the user's upcoming confirmed bookings. The full ticket and
/// its QR belong to the bookings feature (research R4).
class UpcomingBookingsSection extends StatelessWidget {
  const UpcomingBookingsSection({required this.bookings, super.key});

  final List<UpcomingBooking> bookings;

  static const noneKey = ValueKey<String>('upcoming-none');
  static const seeAllKey = ValueKey<String>('upcoming-see-all');
  static ValueKey<String> rowKey(String id) => ValueKey<String>('upcoming-$id');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    if (bookings.isEmpty) {
      return Text(
        l10n.catalogueUpcomingNone,
        key: noneKey,
        style: context.text.body.copyWith(color: colors.inkMuted),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(l10n.catalogueUpcomingTitle, style: context.text.titleLg),
              ),
            ),
            SprintButton(
              key: seeAllKey,
              label: l10n.catalogueUpcomingSeeAll,
              variant: SprintButtonVariant.secondary,
              onPressed: () => context.go(AppPaths.bookings),
            ),
          ],
        ),
        const SizedBox(height: SprintSpacing.space3),
        for (final u in bookings) ...[
          _Row(booking: u),
          const SizedBox(height: SprintSpacing.space2),
        ],
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.booking});

  final UpcomingBooking booking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final b = booking.booking;
    final date = cairoDateText(b.start, l10n);
    final time = cairoTimeText(b.start, l10n);
    final when = '$date · $time';
    final status = sprintStatusOf(b.status);
    return AdaptivePressable(
      key: UpcomingBookingsSection.rowKey(b.id),
      label: l10n.catalogueBookingSpoken(
          booking.facilityName, date, time, status.label(l10n)),
      onTap: () => context.go(AppPaths.bookingDetails(b.id)),
      restingColor: colors.surface,
      hoverColor: colors.surfaceSunken,
      borderRadius: SprintRadius.lgBorder,
      builder: (context, state) => Container(
        constraints: const BoxConstraints(minHeight: SprintSize.controlHeight),
        padding: const EdgeInsetsDirectional.all(SprintSpacing.space3),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(booking.facilityName, style: context.text.label),
                  Text(when,
                      style: context.text.caption.copyWith(color: colors.inkMuted)),
                ],
              ),
            ),
            const SizedBox(width: SprintSpacing.space2),
            StatusBadge(status: status),
          ],
        ),
      ),
    );
  }
}
