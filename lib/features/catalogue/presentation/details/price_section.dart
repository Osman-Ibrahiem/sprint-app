import 'package:flutter/material.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/catalogue/domain/price_groups.dart';
import 'package:sprint/features/catalogue/presentation/widgets/section_card.dart';
import 'package:sprint/features/settings/domain/booking_mode.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Both tiers per group with the booking basis; a signed-in user's tier is
/// labelled "سعرك" and the other stays visible. A free facility shows "مجاني"
/// and the no-payment note (R8, FR-017 – FR-019).
class PriceSection extends StatelessWidget {
  const PriceSection({
    required this.groups,
    required this.isFree,
    required this.session,
    super.key,
  });

  final List<PriceGroup> groups;
  final bool isFree;
  final Session session;

  static const freeKey = ValueKey<String>('price-free');
  static ValueKey<String> rowKey(int group, PriceTier tier) =>
      ValueKey<String>('price-$group-${tier.name}');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    if (isFree) {
      return SectionCard(
        title: l10n.catalogueSectionPrices,
        child: Column(
          key: freeKey,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.catalogueTagFree, style: context.text.headline),
            const SizedBox(height: SprintSpacing.space1),
            Text(
              l10n.catalogueFreeNoPayment,
              style: context.text.body.copyWith(color: colors.inkMuted),
            ),
          ],
        ),
      );
    }

    final f = SprintFormat(l10n.localeName);
    String amount(int? a) => a == null ? l10n.cataloguePriceNotSet : f.price(a);

    return SectionCard(
      title: l10n.catalogueSectionPrices,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < groups.length; i++) ...[
            if (i > 0) const SizedBox(height: SprintSpacing.space4),
            Text(
              groups[i].coversAllUnits
                  ? l10n.cataloguePriceAllUnits
                  : groups[i].unitNames.join('، '),
              style: context.text.label,
            ),
            Text(
              groups[i].mode == BookingMode.shared
                  ? l10n.cataloguePriceBasisShared
                  : l10n.cataloguePriceBasisExclusive,
              style: context.text.caption.copyWith(color: colors.inkMuted),
            ),
            const SizedBox(height: SprintSpacing.space2),
            for (final tier in PriceTier.values)
              _TierRow(
                key: rowKey(i, tier),
                label: tier == PriceTier.internal
                    ? l10n.cataloguePriceInternalLabel
                    : l10n.cataloguePriceExternalLabel,
                value: amount(
                  tier == PriceTier.internal
                      ? groups[i].internal
                      : groups[i].external,
                ),
                yours: !session.isGuest && session.tier == tier,
                yoursLabel: l10n.cataloguePriceYours,
              ),
          ],
        ],
      ),
    );
  }
}

class _TierRow extends StatelessWidget {
  const _TierRow({
    required this.label,
    required this.value,
    required this.yours,
    required this.yoursLabel,
    super.key,
  });

  final String label;
  final String value;
  final bool yours;
  final String yoursLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spoken = yours ? '$yoursLabel: $label, $value' : '$label: $value';
    return Semantics(
      container: true,
      label: spoken,
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            vertical: SprintSpacing.space1,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  yours ? '$label · $yoursLabel' : label,
                  style: yours ? context.text.label : context.text.body,
                ),
              ),
              Text(
                value,
                style: context.text.number.copyWith(
                  color: yours ? colors.primary : colors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
