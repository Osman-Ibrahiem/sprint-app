/// Plain values a [FacilityCard] shows (data-model.md). The caller decides
/// every one of them; the card never reads a repository.
library;

enum FacilityKind { paid, free, withTrainer }

enum FacilityCardLayout { vertical, horizontal }

enum AvailabilityLevel { plenty, few, none }

enum FacilityTagKind { sport, trainer, free, offer }

class FacilityTag {
  const FacilityTag({required this.label, required this.kind});

  final String label;
  final FacilityTagKind kind;
}

/// The one amount the user pays and whom it is for. A guest also gets
/// [externalAmount]; an offer carries [offerLabel] and the struck [oldAmount].
/// Free facilities carry none of these.
class FacilityPrice {
  const FacilityPrice({
    this.amount,
    this.audienceLabel,
    this.externalAmount,
    this.offerLabel,
    this.oldAmount,
  });

  /// Display strings (from `SprintFormat.price`).
  final String? amount;
  final String? audienceLabel;
  final String? externalAmount;
  final String? offerLabel;
  final String? oldAmount;
}
