import 'package:sprint/core/result/failure.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/unit_settings.dart';

/// What someone wants to book.
class BookingProposal {
  const BookingProposal({
    required this.userId,
    required this.unitId,
    required this.start,
    required this.end,
    this.seats = 1,
    this.trainerId,
  });

  final String userId;
  final String unitId;
  final DateTime start;
  final DateTime end;
  final int seats;
  final String? trainerId;
}

/// Refuses a booking that clashes with existing ones (BR-11 – BR-14). Pure.
/// Run it inside the same atomic step that writes the booking.
class ConflictChecker {
  const ConflictChecker();

  Failure? check({
    required BookingProposal proposal,
    required List<Booking> existing,
    required UnitSettings settings,
    required DateTime now,
    int? trainerCapacity,
  }) {
    // BR-13: no overlapping bookings for the same user, in any facility.
    for (final b in existing) {
      if (b.userId == proposal.userId &&
          b.holdsPlace(now) &&
          b.overlaps(proposal.start, proposal.end)) {
        return const OverlapsOwnBooking();
      }
    }

    // BR-14: optional cap on active bookings.
    final max = settings.maxActiveBookingsPerUser;
    if (max != null) {
      final active =
          existing.where((b) => b.userId == proposal.userId && b.isActiveAt(now));
      if (active.length >= max) return const TooManyActiveBookings();
    }

    // BR-02, BR-03, BR-12: places in the slot, counting live holds.
    var unitTaken = 0;
    var trainerTaken = 0;
    for (final b in existing) {
      if (b.unitId != proposal.unitId || !b.holdsPlace(now)) continue;
      if (!b.overlaps(proposal.start, proposal.end)) continue;
      unitTaken += b.seats;
      if (proposal.trainerId != null && b.trainerId == proposal.trainerId) {
        trainerTaken += b.seats;
      }
    }
    if (settings.bookingMode == BookingMode.exclusive) {
      if (unitTaken > 0) return const SlotTaken();
    } else if (unitTaken + proposal.seats > settings.capacity) {
      return const SlotFull();
    }
    if (trainerCapacity != null &&
        proposal.trainerId != null &&
        trainerTaken + proposal.seats > trainerCapacity) {
      return const SlotFull();
    }
    return null;
  }
}
