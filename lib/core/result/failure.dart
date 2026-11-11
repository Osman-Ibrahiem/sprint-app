/// Expected business refusals, returned as values instead of thrown
/// (contracts/repositories.md). Every case is immutable.
sealed class Failure {
  const Failure();
}

/// Exclusive slot already booked, or a live hold sits on it (BR-02, BR-12).
final class SlotTaken extends Failure {
  const SlotTaken();
}

/// Shared slot has no places left (BR-03).
final class SlotFull extends Failure {
  const SlotFull();
}

/// The slot has started or starts inside `minLeadMinutes` (BR-07).
final class SlotPast extends Failure {
  const SlotPast();
}

/// Beyond `bookingWindowDays` (BR-06).
final class OutsideWindow extends Failure {
  const OutsideWindow();
}

/// Outside opening hours, on a closure, or not on the slot grid (BR-05).
final class ClosedSlot extends Failure {
  const ClosedSlot();
}

/// Longer than `maxRangeHours`, or more than one slot where one is allowed
/// (BR-08).
final class RangeTooLong extends Failure {
  const RangeTooLong();
}

/// The same user already holds an overlapping booking (BR-13).
final class OverlapsOwnBooking extends Failure {
  const OverlapsOwnBooking();
}

/// `maxActiveBookingsPerUser` reached (BR-14).
final class TooManyActiveBookings extends Failure {
  const TooManyActiveBookings();
}

/// The hold ran out (BR-12).
final class HoldExpired extends Failure {
  const HoldExpired();
}

/// A state change the booking state machine does not allow (BRD §5).
final class InvalidTransition extends Failure {
  const InvalidTransition();
}

/// Past `cancellationCutoffHours` (BR-30).
final class CancellationClosed extends Failure {
  const CancellationClosed();
}

/// Attendance is not open yet, or the slot has ended (BR-35).
final class CheckInClosed extends Failure {
  const CheckInClosed();
}

/// The role x scope rules refuse this action (BRD §6).
final class NotPermitted extends Failure {
  const NotPermitted();
}

/// A setting value is out of range or not allowed at that scope.
final class InvalidSetting extends Failure {
  const InvalidSetting(this.key, this.reason);
  final String key;
  final String reason;
}

final class NotFound extends Failure {
  const NotFound([this.what]);
  final String? what;
}

/// A change clashes with existing data (for example BR-04).
final class Conflict extends Failure {
  const Conflict(this.details);
  final String details;
}
