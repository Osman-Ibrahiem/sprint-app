import 'package:flutter/material.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/status_badge/sprint_status.dart';
import 'package:sprint/core/widgets/status_badge/status_badge.dart';
import 'package:sprint/features/booking/domain/booking_summary_view.dart';

/// The booking in one card, for the processing, awaiting and expired states:
/// where and when, a status badge and an optional line (such as the
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
          // Wraps, never clips: the badge drops under the name when the text
          // is large or the card narrow.
          Wrap(
            spacing: SprintSpacing.space2,
            runSpacing: SprintSpacing.space1,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(view.facilityName, style: context.text.bodyStrong),
              StatusBadge(status: status),
            ],
          ),
          Text(
            view.trainerName == null
                ? view.unitName
                : '${view.unitName} · ${view.trainerName}',
            style: context.text.body.copyWith(color: colors.inkMuted),
          ),
          const SizedBox(height: SprintSpacing.space1),
          Text(
            '${format.date(view.start)} · '
            '${format.instantRange(view.start, view.end)}',
            style: context.text.body,
          ),
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
