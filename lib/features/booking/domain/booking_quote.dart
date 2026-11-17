import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/settings/domain/booking_mode.dart';

/// What a booking would be, checked but not created (research R6). The summary
/// shows it; `BookingRepository.create` repeats every check.
class BookingQuote {
  const BookingQuote({
    required this.facilityId,
    required this.unitId,
    this.trainerId,
    required this.start,
    required this.end,
    required this.tier,
    required this.amount,
    required this.mode,
    this.maxParticipants,
    required this.cancellationCutoffHours,
    required this.refundPercent,
  });

  final String facilityId;
  final String unitId;
  final String? trainerId;

  /// UTC instants.
  final DateTime start;
  final DateTime end;

  /// The booker's tier at this moment (BR-17).
  final PriceTier tier;

  /// Whole Egyptian pounds for this booking; 0 when free.
  final int amount;

  /// Whole unit (`exclusive`) or one place (`shared`), and the price basis
  /// (BR-16).
  final BookingMode mode;

  /// Shown for an exclusive unit (BR-02).
  final int? maxParticipants;

  /// For the cancellation policy line (BR-30, BR-31).
  final int cancellationCutoffHours;
  final int refundPercent;

  /// Free facilities, and anything that comes to zero, skip payment (BR-19).
  bool get requiresPayment => amount > 0;

  @override
  bool operator ==(Object other) =>
      other is BookingQuote &&
      other.facilityId == facilityId &&
      other.unitId == unitId &&
      other.trainerId == trainerId &&
      other.start == start &&
      other.end == end &&
      other.tier == tier &&
      other.amount == amount &&
      other.mode == mode &&
      other.maxParticipants == maxParticipants &&
      other.cancellationCutoffHours == cancellationCutoffHours &&
      other.refundPercent == refundPercent;

  @override
  int get hashCode => Object.hash(
        facilityId,
        unitId,
        trainerId,
        start,
        end,
        tier,
        amount,
        mode,
        maxParticipants,
        cancellationCutoffHours,
        refundPercent,
      );

  @override
  String toString() => 'BookingQuote($unitId, $start, $tier, $amount)';
}
