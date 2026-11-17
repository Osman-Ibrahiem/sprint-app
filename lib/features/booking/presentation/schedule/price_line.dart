import 'package:flutter/material.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/features/booking/domain/facility_schedule.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The price of the shown unit, as the catalogue shows it (FR-026 display
/// half, BR-15, BR-16): both tiers for a guest, the signed-in person's own
/// tier with "سعرك" otherwise, "مجاني" for a free facility. The binding price
/// is the repository's quote on the summary.
class PriceLine extends StatelessWidget {
  const PriceLine({
    required this.unit,
    required this.isFree,
    required this.session,
    super.key,
  });

  final ScheduleUnit? unit;
  final bool isFree;
  final Session session;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    if (isFree) {
      return Semantics(
        container: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.bookingFree, style: context.text.headline),
            Text(
              l10n.catalogueFreeNoPayment,
              style: context.text.caption.copyWith(color: colors.inkMuted),
            ),
          ],
        ),
      );
    }
    final u = unit;
    if (u == null) return const SizedBox.shrink();
    final tiers = session.isGuest
        ? [PriceTier.internal, PriceTier.external]
        : [session.tier];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final tier in tiers)
          Padding(
            padding: const EdgeInsetsDirectional.only(
              bottom: SprintSpacing.space1,
            ),
            child: _Row(unit: u, tier: tier, yours: !session.isGuest),
          ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.unit, required this.tier, required this.yours});

  final ScheduleUnit unit;
  final PriceTier tier;
  final bool yours;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final amount = unit.priceFor(tier);
    final label = tier == PriceTier.internal
        ? l10n.cataloguePriceInternalLabel
        : l10n.cataloguePriceExternalLabel;
    final basis = unit.isShared
        ? l10n.cataloguePriceBasisShared
        : l10n.cataloguePriceBasisExclusive;
    final value = amount == null
        ? l10n.cataloguePriceNotSet
        : '${SprintFormat.of(context).price(amount)} $basis';
    final text = yours ? '${l10n.cataloguePriceYours} · $label' : label;
    return Semantics(
      container: true,
      label: '$text: $value',
      child: ExcludeSemantics(
        child: Wrap(
          spacing: SprintSpacing.space2,
          children: [
            Text(
              text,
              style: context.text.label.copyWith(color: colors.inkMuted),
            ),
            Text(value, style: context.text.number),
          ],
        ),
      ),
    );
  }
}
