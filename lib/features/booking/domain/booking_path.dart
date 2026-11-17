import 'package:sprint/features/catalogue/domain/facility.dart';

/// How a facility is booked. The facility decides; the user is never asked
/// (FR-013, BR-10).
enum BookingPath {
  /// One slot in a paid facility, exclusive or shared.
  slot,

  /// A run of consecutive hours in a free facility (BR-08).
  range,

  /// A trainer first, then one of that trainer's sessions (BR-09).
  trainer;

  /// A facility that requires a trainer uses the trainer path even when it is
  /// free; this matches `AvailabilityService.checkRequest`.
  static BookingPath of(Facility facility) {
    if (facility.requiresTrainer) return BookingPath.trainer;
    if (facility.isFree) return BookingPath.range;
    return BookingPath.slot;
  }
}
