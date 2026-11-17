import 'package:flutter/material.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/features/booking/domain/booking_summary_view.dart';
import 'package:sprint/features/booking/presentation/schedule/selection_bar.dart';
import 'package:sprint/features/booking/presentation/summary/cancellation_policy_text.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Every line of the summary (FR-024), each with its label.
class SummaryRows extends StatelessWidget {
  const SummaryRows({required this.view, super.key});

  final BookingSummaryView view;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final format = SprintFormat.of(context);

    final coverage = switch (view.coverage) {
      WholeUnit(:final maxParticipants) =>
        maxParticipants == null
            ? l10n.bookingCoverageWhole
            : l10n.bookingCoverageWholeMax(maxParticipants),
      OnePlace() => l10n.bookingCoverageOnePlace,
    };
    final basis = view.isPerPlace
        ? l10n.cataloguePriceBasisShared
        : l10n.cataloguePriceBasisExclusive;
    final tierLabel = view.tier == PriceTier.internal
        ? l10n.cataloguePriceInternalLabel
        : l10n.cataloguePriceExternalLabel;
    final rows = <(String, String)>[
      (l10n.bookingRowFacility, view.facilityName),
      (l10n.bookingRowUnit, view.unitName),
      (l10n.bookingRowDate, format.date(view.start)),
      (
        l10n.bookingRowTime,
        '${format.time(view.start)} – ${format.time(view.end)}',
      ),
      (
        l10n.bookingRowLength,
        view.trainerName != null
            ? l10n.bookingSessionLength(view.lengthMinutes)
            : selectionLengthText(context, view.start, view.end),
      ),
      (l10n.bookingRowCoverage, coverage),
      if (view.trainerName != null)
        (l10n.bookingRowTrainer, view.trainerName!),
      if (!view.isFree) (l10n.bookingRowTier, tierLabel),
      (
        l10n.bookingRowPrice,
        view.isFree
            ? l10n.bookingFree
            : '${format.price(view.amount)} $basis',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: SprintRadius.lgBorder,
        border: Border.all(color: colors.line),
      ),
      padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (label, value) in rows)
            _Row(label: label, value: value),
          if (view.isFree)
            Padding(
              padding: const EdgeInsetsDirectional.only(
                bottom: SprintSpacing.space3,
              ),
              child: Text(
                l10n.bookingFreeNoPayment,
                style: context.text.body.copyWith(color: colors.inkMuted),
              ),
            ),
          Text(
            l10n.bookingRowPolicy,
            style: context.text.label.copyWith(color: colors.inkMuted),
          ),
          const SizedBox(height: SprintSpacing.space1),
          CancellationPolicyText(
            cutoffHours: view.quote.cancellationCutoffHours,
            refundPercent: view.quote.refundPercent,
            showRefund: !view.isFree,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: SprintSpacing.space3),
      child: Semantics(
        container: true,
        label: '$label: $value',
        child: ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.text.label.copyWith(color: colors.inkMuted),
              ),
              Text(value, style: context.text.bodyStrong),
            ],
          ),
        ),
      ),
    );
  }
}
