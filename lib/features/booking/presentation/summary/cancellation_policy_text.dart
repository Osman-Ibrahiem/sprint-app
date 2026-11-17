import 'package:flutter/material.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The cancellation policy in words, built from the cutoff and refund-percent
/// settings of the unit, never fixed wording (FR-025, BR-30, BR-31). A free
/// booking has nothing to refund, so [showRefund] is off for it.
class CancellationPolicyText extends StatelessWidget {
  const CancellationPolicyText({
    required this.cutoffHours,
    required this.refundPercent,
    this.showRefund = true,
    super.key,
  });

  final int cutoffHours;
  final int refundPercent;
  final bool showRefund;

  /// The sentence, for tests and the screen reader.
  static String sentence(
    AppLocalizations l10n, {
    required int cutoffHours,
    required int refundPercent,
    required bool showRefund,
  }) {
    final cutoff = l10n.bookingPolicyCutoff(cutoffHours);
    if (!showRefund) return cutoff;
    final refund = refundPercent >= 100
        ? l10n.bookingPolicyRefundFull
        : refundPercent <= 0
        ? l10n.bookingPolicyRefundNone
        : l10n.bookingPolicyRefundPartial(refundPercent);
    return '$cutoff $refund';
  }

  @override
  Widget build(BuildContext context) => Text(
    sentence(
      AppLocalizations.of(context),
      cutoffHours: cutoffHours,
      refundPercent: refundPercent,
      showRefund: showRefund,
    ),
    style: context.text.body,
  );
}
