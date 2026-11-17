import 'package:flutter/material.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The cancellation policy of the booking in the checkout wording
/// (`checkoutPolicyBody`): the last moment to cancel, how long before the
/// start that is, and the refund percent, all from the settings (BR-30,
/// BR-31), never fixed numbers.
class CheckoutPolicyCard extends StatelessWidget {
  const CheckoutPolicyCard({
    required this.start,
    required this.cutoffHours,
    required this.refundPercent,
    super.key,
  });

  final DateTime start;
  final int cutoffHours;
  final int refundPercent;

  static const bodyKey = ValueKey<String>('checkout-policy-body');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final format = SprintFormat.of(context);
    final until = start.subtract(Duration(hours: cutoffHours));
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
          Text(l10n.checkoutPolicyTitle, style: context.text.bodyStrong),
          const SizedBox(height: SprintSpacing.space1),
          Text(
            l10n.checkoutPolicyBody(
              '${format.date(until)} ${format.time(until)}',
              l10n.bookingLengthHours(cutoffHours),
              refundPercent,
            ),
            key: bodyKey,
            style: context.text.body.copyWith(color: colors.inkMuted),
          ),
        ],
      ),
    );
  }
}
