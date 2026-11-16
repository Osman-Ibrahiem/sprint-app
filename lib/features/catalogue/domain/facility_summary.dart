import 'package:sprint/core/widgets/facility_card/facility_card_data.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/domain/today_availability.dart';

/// The prices of one tier over a facility's active units: one amount when every
/// priced unit shares it, a range otherwise (R8).
class TierPriceRange {
  const TierPriceRange({required this.min, required this.max});

  final int min;
  final int max;

  bool get isSingle => min == max;
}

/// A facility as the list and the cards show it (data-model.md).
class FacilitySummary {
  const FacilitySummary({
    required this.facility,
    required this.owningUnitName,
    required this.activeUnitCount,
    required this.today,
    this.priceInternal,
    this.priceExternal,
  });

  final Facility facility;
  final String owningUnitName;
  final int activeUnitCount;
  final TodayAvailability today;

  /// Null for a free facility and when no active unit has a price yet
  /// (never 0).
  final TierPriceRange? priceInternal;
  final TierPriceRange? priceExternal;

  /// The card's rendering path (BR-08 – BR-10).
  FacilityKind get kind {
    if (facility.isFree) return FacilityKind.free;
    if (facility.requiresTrainer) return FacilityKind.withTrainer;
    return FacilityKind.paid;
  }
}
