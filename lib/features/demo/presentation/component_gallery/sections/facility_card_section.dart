import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/facility_card/facility_card.dart';
import 'package:sprint/features/catalogue/domain/catalogue_repository.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/catalogue/presentation/widgets/facility_card_mapper.dart';
import 'package:sprint/features/demo/presentation/component_gallery/gallery_section.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Cards built from the seed facilities through the repositories (FR-066):
/// both price tiers, the guest view, an offer, free, with a trainer, no photo
/// and a loading form.
class FacilityCardSection extends ConsumerWidget {
  const FacilityCardSection({required this.l10n, super.key});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogue = ref.watch(catalogueRepositoryProvider);
    final format = SprintFormat(Localizations.localeOf(context).languageCode);
    return GallerySection(
      title: l10n.galleryFacilityCardSection,
      caption: l10n.gallerySampleNote,
      children: [
        FutureBuilder<List<_Row>>(
          future: _load(catalogue),
          builder: (context, snapshot) {
            final rows = snapshot.data ?? const <_Row>[];
            return Wrap(
              spacing: SprintSpacing.space4,
              runSpacing: SprintSpacing.space4,
              children: [
                for (final (index, row) in rows.indexed)
                  SizedBox(
                    width: SprintExtras.ticketWidth,
                    child: _card(row, index, format),
                  ),
                const SizedBox(
                  width: SprintExtras.ticketWidth,
                  child: FacilityCard.loading(),
                ),
                const SizedBox(
                  width: SprintExtras.ticketWidth,
                  child: FacilityCard.loading(
                    layout: FacilityCardLayout.horizontal,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _card(_Row row, int index, SprintFormat format) {
    final f = row.facility;
    final kind = f.isFree
        ? FacilityKind.free
        : f.requiresTrainer
            ? FacilityKind.withTrainer
            : FacilityKind.paid;
    final internal = row.internal;
    final external = row.external;
    final guest = index == 1;
    final offer = index == 2 && internal != null;
    return FacilityCard(
      kind: kind,
      layout: index.isOdd ? FacilityCardLayout.horizontal : FacilityCardLayout.vertical,
      name: f.name,
      owningUnit: row.owner,
      unitCount: row.unitCount,
      availability: AvailabilityLevel.values[index % 3],
      tags: [
        // The type in the reader's language, as the real cards (decision V2).
        FacilityTag(label: typeLabelOf(f.type, l10n), kind: FacilityTagKind.sport),
        if (f.requiresTrainer)
          FacilityTag(label: l10n.facilityTrainerTag, kind: FacilityTagKind.trainer),
        if (f.isFree)
          FacilityTag(label: l10n.facilityFreeTag, kind: FacilityTagKind.free),
      ],
      price: kind == FacilityKind.free
          ? const FacilityPrice()
          : FacilityPrice(
              amount: internal == null
                  ? null
                  : format.price(offer ? internal * 0.8 : internal),
              audienceLabel: l10n.facilityPriceInternalLabel,
              externalAmount:
                  guest && external != null ? format.price(external) : null,
              offerLabel: offer ? '20%' : null,
              oldAmount: offer ? format.price(internal) : null,
            ),
      onTap: () {},
    );
  }

  Future<List<_Row>> _load(CatalogueRepository catalogue) async {
    final facilities = await catalogue.listFacilities();
    final owners = {
      for (final o in await catalogue.listOwningUnits()) o.id: o.name,
    };
    final rows = <_Row>[];
    for (final f in facilities) {
      final units = await catalogue.listUnits(f.id);
      int? internal;
      int? external;
      if (units.isNotEmpty) {
        final prices = await catalogue.prices(units.first.id);
        for (final p in prices) {
          if (p.tier == PriceTier.internal) internal = p.amount;
          if (p.tier == PriceTier.external) external = p.amount;
        }
      }
      rows.add(_Row(f, owners[f.owningUnitId] ?? '', units.length, internal, external));
    }
    return rows;
  }
}

class _Row {
  const _Row(this.facility, this.owner, this.unitCount, this.internal, this.external);
  final Facility facility;
  final String owner;
  final int unitCount;
  final int? internal;
  final int? external;
}
