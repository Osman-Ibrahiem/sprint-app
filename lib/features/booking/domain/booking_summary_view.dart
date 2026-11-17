import 'package:sprint/features/booking/domain/booking_quote.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/settings/domain/booking_mode.dart';

/// Whole unit (with how many may play, BR-02) or one place (BR-03).
sealed class BookingCoverage {
  const BookingCoverage();
}

final class WholeUnit extends BookingCoverage {
  const WholeUnit({this.maxParticipants});
  final int? maxParticipants;
}

final class OnePlace extends BookingCoverage {
  const OnePlace();
}

/// What the summary says about the booker's verification (FR-027). Never
/// blocks the booking (BR-21).
enum VerificationHint { none, canVerify, underReview }

/// Everything the summary screen shows (FR-024), built from a
/// [BookingQuote] and the names the catalogue gives. Pure.
class BookingSummaryView {
  const BookingSummaryView({
    required this.quote,
    required this.facilityName,
    required this.unitName,
    this.trainerName,
    required this.coverage,
    required this.verificationHint,
    required this.priceChanged,
  });

  factory BookingSummaryView.from({
    required BookingQuote quote,
    required String facilityName,
    required String unitName,
    String? trainerName,
    required VerificationHint verificationHint,

    /// The amount the schedule displayed; null when it showed none.
    int? shown,
  }) => BookingSummaryView(
    quote: quote,
    facilityName: facilityName,
    unitName: unitName,
    trainerName: trainerName,
    coverage: quote.mode == BookingMode.exclusive
        ? WholeUnit(maxParticipants: quote.maxParticipants)
        : const OnePlace(),
    verificationHint: quote.requiresPayment
        ? verificationHint
        : VerificationHint.none,
    priceChanged: shown != null && shown != quote.amount,
  );

  final BookingQuote quote;
  final String facilityName;
  final String unitName;
  final String? trainerName;
  final BookingCoverage coverage;
  final VerificationHint verificationHint;

  /// The quote differs from what the schedule showed (BR-17, FR-026).
  final bool priceChanged;

  bool get isFree => !quote.requiresPayment;
  PriceTier get tier => quote.tier;
  int get amount => quote.amount;
  DateTime get start => quote.start;
  DateTime get end => quote.end;
  int get lengthMinutes => quote.end.difference(quote.start).inMinutes;
  bool get isPerPlace => quote.mode == BookingMode.shared;
}
