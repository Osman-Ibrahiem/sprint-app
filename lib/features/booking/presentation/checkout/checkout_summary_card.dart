import 'package:flutter/material.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/features/booking/domain/booking_summary_view.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The booking on the payment screen (FR-BKG-04): the facility as the title,
/// then one line per fact with its label at the start and its value at the
/// end (unit, trainer, time, tier), a rule, and the total. Rows wrap, never
/// clip, so large text and long names stay readable.
class CheckoutSummaryCard extends StatelessWidget {
  const CheckoutSummaryCard({required this.view, super.key});

  final BookingSummaryView view;

  static const totalKey = ValueKey<String>('checkout-summary-total');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final format = SprintFormat.of(context);

    final coverage = switch (view.coverage) {
      WholeUnit() => null,
      OnePlace() => l10n.bookingCoverageOnePlace,
    };
    final unit = coverage == null
        ? view.unitName
        : '${view.unitName} · $coverage';
    final tier = view.tier == PriceTier.internal
        ? l10n.checkoutTierInternal
        : l10n.checkoutTierExternal;

    return Container(
      padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: SprintRadius.lgBorder,
        border: Border.all(color: colors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(view.facilityName, style: context.text.title),
          ),
          const SizedBox(height: SprintSpacing.space3),
          _Line(label: l10n.bookingRowUnit, value: unit),
          if (view.trainerName != null)
            _Line(label: l10n.bookingRowTrainer, value: view.trainerName!),
          _Line(
            label: l10n.checkoutRowTime,
            value:
                '${format.date(view.start)} · '
                '${format.time(view.start)} – ${format.time(view.end)}',
          ),
          _Line(label: l10n.bookingRowTier, value: tier),
          Divider(
            height: SprintSpacing.space4,
            thickness: SprintExtras.hairlineWidth,
            color: colors.line,
          ),
          _Line(
            label: l10n.checkoutRowTotal,
            value: format.price(view.amount),
            valueKey: totalKey,
            strong: true,
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.label,
    required this.value,
    this.strong = false,
    this.valueKey,
  });

  final String label;
  final String value;
  final bool strong;
  final Key? valueKey;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        vertical: SprintSpacing.space1,
      ),
      child: Semantics(
        container: true,
        label: '$label: $value',
        child: ExcludeSemantics(
          child: LayoutBuilder(
            builder: (context, box) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // The label keeps its own width up to under half the row, so
                // the value gets the rest instead of an even split.
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: box.maxWidth * SprintExtras.rowLabelShare,
                  ),
                  child: Text(
                    label,
                    style: context.text.body.copyWith(color: colors.inkMuted),
                  ),
                ),
                const SizedBox(width: SprintSpacing.space3),
                Expanded(
                  child: Text(
                    value,
                    key: valueKey,
                    style: strong ? context.text.bodyStrong : context.text.body,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
