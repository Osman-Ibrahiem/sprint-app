import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/domain/facility_summary.dart';

/// How many facilities the featured list shows (R4). A presentation choice,
/// not a setting.
const int homeFeaturedLimit = 6;

/// Why a facility is suggested on the signed-in home (FR-004, R4).
sealed class SuggestionReason {
  const SuggestionReason();
}

/// The user booked a facility of this type before.
final class BookedTypeBefore extends SuggestionReason {
  const BookedTypeBefore(this.type);

  final FacilityType type;
}

/// No personal history for this type: a plain suggestion.
final class OtherSuggestion extends SuggestionReason {
  const OtherSuggestion();
}

/// One suggested facility and the reason shown in words below its card.
class Suggestion {
  const Suggestion({required this.facility, required this.reason});

  final FacilitySummary facility;
  final SuggestionReason reason;
}

/// One upcoming confirmed booking, with its facility's name resolved so the
/// home screen needs no repository read.
class UpcomingBooking {
  const UpcomingBooking({required this.booking, required this.facilityName});

  final Booking booking;
  final String facilityName;
}

/// The pure home view model (data-model.md, FR-001 – FR-006).
class HomeContent {
  const HomeContent({
    required this.types,
    required this.featured,
    this.upcoming = const [],
    this.suggestions = const [],
  });

  /// Facility types that have at least one published facility, in enum order.
  final List<FacilityType> types;

  /// Up to [homeFeaturedLimit] facilities for discovery (R4).
  final List<FacilitySummary> featured;

  /// Upcoming confirmed bookings, soonest first; empty for a guest (US4).
  final List<UpcomingBooking> upcoming;

  /// Up to four explainable suggestions; empty when there is no history (US4).
  final List<Suggestion> suggestions;
}
