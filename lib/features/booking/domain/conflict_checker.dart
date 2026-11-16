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
    this.slotMinutes,
  });

  final String userId;
  final String unitId;
  final DateTime start;
  final DateTime end;
  final int seats;
  final String? trainerId;

  /// Length of one grid slot of the request (granularity, or the session
  /// length). When set, places are checked for each slot; when null the
  /// request is one slot.
  final int? slotMinutes;
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
        return OverlapsOwnBooking(bookingId: b.id);
      }
    }

    // BR-14: optional cap on active bookings.
    final max = settings.maxActiveBookingsPerUser;
    if (max != null) {
      final active =
          existing.where((b) => b.userId == proposal.userId && b.isActiveAt(now));
      if (active.length >= max) return TooManyActiveBookings(max: max);
    }

    // BR-02, BR-03, BR-12: places in each slot of the request, counting live
    // holds. A range is checked hour by hour, never summed (BR-08).
    final step = proposal.slotMinutes == null || proposal.slotMinutes! <= 0
        ? null
        : Duration(minutes: proposal.slotMinutes!);
    var slotStart = proposal.start;
    while (slotStart.isBefore(proposal.end)) {
      final next = step == null ? proposal.end : slotStart.add(step);
      final slotEnd = next.isAfter(proposal.end) ? proposal.end : next;

      var unitTaken = 0;
      var trainerTaken = 0;
      for (final b in existing) {
        if (b.unitId != proposal.unitId || !b.holdsPlace(now)) continue;
        if (!b.overlaps(slotStart, slotEnd)) continue;
        unitTaken += b.seats;
        if (proposal.trainerId != null && b.trainerId == proposal.trainerId) {
          trainerTaken += b.seats;
        }
      }
      if (settings.bookingMode == BookingMode.exclusive) {
        if (unitTaken > 0) return SlotTaken(at: slotStart);
      } else if (unitTaken + proposal.seats > settings.capacity) {
        return SlotFull(at: slotStart);
      }
      if (trainerCapacity != null &&
          proposal.trainerId != null &&
          trainerTaken + proposal.seats > trainerCapacity) {
        return SlotFull(at: slotStart);
      }
      slotStart = slotEnd;
    }
    return null;
  }
}
