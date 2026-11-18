import 'package:sprint/features/catalogue/domain/arabic_normalizer.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/domain/facility_summary.dart';

/// The facility list's search (FR-014): a normalised substring over the name,
/// the type's label and the owning unit's name, with open facilities first.
/// The type label comes from the caller, so this stays pure and the l10n text
/// lives in one place.
class FacilitySearch {
  const FacilitySearch._();

  static List<FacilitySummary> filter(
    List<FacilitySummary> all,
    String query, {
    String Function(FacilityType type)? typeLabelOf,
  }) {
    final needle = ArabicNormalizer.normalize(query);
    final matched = needle.isEmpty
        ? [...all]
        : all.where((s) {
            if (ArabicNormalizer.contains(s.facility.name, needle) ||
                ArabicNormalizer.contains(s.owningUnitName, needle)) {
              return true;
            }
            final label = typeLabelOf?.call(s.facility.type);
            return label != null && ArabicNormalizer.contains(label, needle);
          }).toList();

    matched.sort((a, b) {
      // Open today first, the fullest first.
      if (a.today.closedToday != b.today.closedToday) {
        return a.today.closedToday ? 1 : -1;
      }
      if (!a.today.closedToday && a.today.count != b.today.count) {
        return b.today.count.compareTo(a.today.count);
      }
      return ArabicNormalizer.normalize(a.facility.name)
          .compareTo(ArabicNormalizer.normalize(b.facility.name));
    });
    return matched;
  }
}
