import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/widgets/facility_card/facility_card_data.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/domain/facility_summary.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The plain values a [FacilityCard] needs, resolved from a summary, the
/// session and the copy (FR-011, FR-017, FR-019, R8, US-11).
class FacilityCardInputs {
  const FacilityCardInputs({
    required this.kind,
    required this.name,
    required this.owningUnit,
    required this.unitCount,
    required this.tags,
    required this.availability,
    required this.availableCount,
    required this.price,
  });

  final FacilityKind kind;
  final String name;
  final String owningUnit;
  final int unitCount;
  final List<FacilityTag> tags;
  final AvailabilityLevel availability;
  final int availableCount;
  final FacilityPrice price;
}

/// Builds the card's inputs. A guest sees both tiers; a signed-in user sees
/// their own tier with its audience label; differing prices over a facility's
/// units show a range, never a lone lowest price (R8).
FacilityCardInputs facilityCardInputs({
  required FacilitySummary summary,
  required Session session,
  required AppLocalizations l10n,
}) {
  final format = SprintFormat(l10n.localeName);
  final facility = summary.facility;

  final tags = <FacilityTag>[
    FacilityTag(label: typeLabelOf(facility.type, l10n), kind: FacilityTagKind.sport),
    if (facility.requiresTrainer)
      FacilityTag(label: l10n.catalogueTagTrainer, kind: FacilityTagKind.trainer),
    if (facility.isFree)
      FacilityTag(label: l10n.catalogueTagFree, kind: FacilityTagKind.free),
  ];

  return FacilityCardInputs(
    kind: summary.kind,
    name: facility.name,
    owningUnit: summary.owningUnitName,
    unitCount: summary.activeUnitCount,
    tags: tags.take(3).toList(),
    availability: summary.today.level,
    availableCount: summary.today.count,
    price: _price(summary, session, format, l10n),
  );
}

FacilityPrice _price(
  FacilitySummary summary,
  Session session,
  SprintFormat format,
  AppLocalizations l10n,
) {
  if (summary.facility.isFree) return const FacilityPrice();

  // A guest sees both tiers, each labelled (FacilityCard README).
  if (session.isGuest) {
    return FacilityPrice(
      amount: _tierText(summary.priceInternal, format, l10n),
      audienceLabel: l10n.facilityPriceInternalLabel,
      externalAmount: _tierText(summary.priceExternal, format, l10n),
    );
  }

  final internal = session.tier == PriceTier.internal;
  final range = internal ? summary.priceInternal : summary.priceExternal;
  return FacilityPrice(
    amount: _tierText(range, format, l10n),
    audienceLabel: internal
        ? l10n.facilityPriceInternalLabel
        : l10n.facilityPriceExternalLabel,
  );
}

String? _tierText(
  TierPriceRange? range,
  SprintFormat format,
  AppLocalizations l10n,
) {
  if (range == null) return null;
  if (range.isSingle) return format.price(range.min);
  return l10n.cataloguePriceRange(
    format.number(range.min),
    format.number(range.max),
  );
}

/// The Arabic or English label of a facility type.
String typeLabelOf(FacilityType type, AppLocalizations l10n) => switch (type) {
      FacilityType.swimming => l10n.catalogueTypeSwimming,
      FacilityType.football => l10n.catalogueTypeFootball,
      FacilityType.gym => l10n.catalogueTypeGym,
      FacilityType.tennis => l10n.catalogueTypeTennis,
      FacilityType.hall => l10n.catalogueTypeHall,
      FacilityType.training => l10n.catalogueTypeTraining,
    };
