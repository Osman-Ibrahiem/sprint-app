import 'package:flutter/material.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/status_badge/sprint_status.dart';
import 'package:sprint/core/widgets/status_badge/status_badge.dart';
import 'package:sprint/features/booking/domain/booking_summary_view.dart';

/// The booking in one card, for the processing, awaiting and expired states:
/// where and when, the price, a status badge and an optional line (such as the
/// time left on the Hold).
class CheckoutBookingCard extends StatelessWidget {
  const CheckoutBookingCard({
    required this.view,
    required this.status,
    this.footer,
    super.key,
  });

  final BookingSummaryView view;
  final SprintStatus status;
  final String? footer;

  static const footerKey = ValueKey<String>('checkout-card-footer');

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final format = SprintFormat.of(context);
    return Container(
      padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: SprintRadius.lgBorder,
        border: Border.all(color: colors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(view.facilityName, style: context.text.bodyStrong),
              ),
              const SizedBox(width: SprintSpacing.space2),
              StatusBadge(status: status),
            ],
          ),
          Text(
            '${view.unitName} · ${format.date(view.start)} · '
            '${format.time(view.start)} – ${format.time(view.end)}',
            style: context.text.body.copyWith(color: colors.inkMuted),
          ),
          const SizedBox(height: SprintSpacing.space1),
          Text(format.price(view.amount), style: context.text.bodyStrong),
          if (footer != null) ...[
            const SizedBox(height: SprintSpacing.space2),
            Text(
              footer!,
              key: footerKey,
              style: context.text.body.copyWith(color: colors.inkMuted),
            ),
          ],
        ],
      ),
    );
  }
}
