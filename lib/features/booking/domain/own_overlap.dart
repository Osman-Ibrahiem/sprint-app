import 'package:sprint/features/booking/domain/booking.dart';

/// The booker's own booking that a new time would overlap, if any (BR-13).
/// A fast answer at the tap; `BookingRepository.quote` repeats the check and
/// is the authority (feature 005 research R6).
abstract final class OwnOverlap {
  static Booking? find(
    List<Booking> mine,
    DateTime start,
    DateTime end,
    DateTime now,
  ) {
    for (final b in mine) {
      if (b.holdsPlace(now) && b.overlaps(start, end)) return b;
    }
    return null;
  }
}
