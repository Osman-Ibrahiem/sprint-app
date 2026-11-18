import 'package:sprint/features/catalogue/domain/arabic_normalizer.dart';
import 'package:sprint/features/catalogue/domain/facility_summary.dart';

/// The two suggestion groups above a search (FR-014, data-model): the two most
/// booked facilities and the recent terms kept on the device.
class SearchSuggestions {
  const SearchSuggestions({required this.mostBooked, required this.recents});

  /// Facility ids, most booked first, at most two; ties by normalised name.
  final List<String> mostBooked;

  /// Raw recent terms, newest first, already limited by the store.
  final List<String> recents;

  static const int mostBookedLimit = 2;

  /// Picks the two ids from [all] using `bookedCounts` (30-day confirmed and
  /// attended starts).
  static List<String> mostBookedFrom(
    List<FacilitySummary> all,
    Map<String, int> counts,
  ) {
    final sorted = [...all]..sort((a, b) {
        final ca = counts[a.facility.id] ?? 0;
        final cb = counts[b.facility.id] ?? 0;
        if (ca != cb) return cb.compareTo(ca);
        return ArabicNormalizer.normalize(a.facility.name)
            .compareTo(ArabicNormalizer.normalize(b.facility.name));
      });
    return [
      for (final s in sorted.take(mostBookedLimit)) s.facility.id,
    ];
  }
}
