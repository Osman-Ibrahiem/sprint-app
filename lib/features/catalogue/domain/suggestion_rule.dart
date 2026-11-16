import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/domain/facility_summary.dart';
import 'package:sprint/features/catalogue/domain/home_content.dart';

/// How many suggestions the signed-in home shows (research R4). A presentation
/// choice, not a setting.
const int suggestionLimit = 4;

/// The explainable, deterministic suggestion rule: no AI (FR-004, R4).
abstract final class SuggestionRule {
  /// Facilities of types the user booked before come first, by how often the
  /// type was booked, then by name; the rest follow by name. Facilities with an
  /// upcoming booking never appear, and a user with no history gets none.
  static List<Suggestion> pick({
    required List<FacilitySummary> facilities,
    required List<Booking> pastBookings,
    required Set<String> upcomingFacilityIds,
    int limit = suggestionLimit,
  }) {
    const past = {
      BookingStatus.confirmed,
      BookingStatus.attended,
      BookingStatus.noShow,
    };
    final typeOf = {for (final s in facilities) s.facility.id: s.facility.type};
    final counts = <FacilityType, int>{};
    for (final b in pastBookings) {
      final type = typeOf[b.facilityId];
      if (type != null && past.contains(b.status)) {
        counts[type] = (counts[type] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) return const [];

    final candidates = facilities
        .where((s) => !upcomingFacilityIds.contains(s.facility.id))
        .toList();
    int byName(FacilitySummary a, FacilitySummary b) =>
        a.facility.name.compareTo(b.facility.name);

    final booked = candidates
        .where((s) => counts.containsKey(s.facility.type))
        .toList()
      ..sort((a, b) {
        final byCount =
            counts[b.facility.type]!.compareTo(counts[a.facility.type]!);
        return byCount != 0 ? byCount : byName(a, b);
      });
    final rest = candidates
        .where((s) => !counts.containsKey(s.facility.type))
        .toList()
      ..sort(byName);

    return [
      for (final s in booked)
        Suggestion(
          facility: s,
          reason: BookedTypeBefore(s.facility.type),
        ),
      for (final s in rest)
        Suggestion(facility: s, reason: const OtherSuggestion()),
    ].take(limit).toList();
  }
}
