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

/// The device storage has no room left (demo snapshot photos, research R7).
final class StorageFull extends Failure {
  const StorageFull();
}

// ---------------------------------------------------- auth and verification
// Feature 003 (contracts/repositories.md).

/// A field failed validation; [field] is the form field name and [reason] a
/// stable reason code (FR-002).
final class InvalidField extends Failure {
  const InvalidField(this.field, this.reason);
  final String field;
  final String reason;
}

final class EmailTaken extends Failure {
  const EmailTaken();
}

final class PhoneTaken extends Failure {
  const PhoneTaken();
}

/// Wrong code; [triesLeft] tries remain on it (FR-005).
final class CodeWrong extends Failure {
  const CodeWrong(this.triesLeft);
  final int triesLeft;
}

final class CodeExpired extends Failure {
  const CodeExpired();
}

/// Too many wrong tries: a new code must be sent (FR-005).
final class CodeDead extends Failure {
  const CodeDead();
}

final class NoPendingConfirmation extends Failure {
  const NoPendingConfirmation();
}

/// A new code was asked for before [wait] has passed (FR-005).
final class ResendTooSoon extends Failure {
  const ResendTooSoon(this.wait);
  final Duration wait;
}

/// Wrong password, unknown email or unknown phone: one failure (FR-010).
final class BadCredentials extends Failure {
  const BadCredentials();
}

final class LockedOut extends Failure {
  const LockedOut(this.until);
  final DateTime until;
}

final class Suspended extends Failure {
  const Suspended();
}

final class NeedsConfirmation extends Failure {
  const NeedsConfirmation(this.email);
  final String email;
}

final class AlreadyPending extends Failure {
  const AlreadyPending();
}

/// The person's approval is still valid: nothing to request until it expires
/// (FR-030).
final class AlreadyVerified extends Failure {
  const AlreadyVerified();
}

final class NotSignedIn extends Failure {
  const NotSignedIn();
}

/// Not a reviewer, or the request is out of the reviewer's scope (FR-032).
final class NoAccess extends Failure {
  const NoAccess();
}

final class AlreadyDecided extends Failure {
  const AlreadyDecided();
}

/// A reviewer never decides their own request (FR-035).
final class OwnRequest extends Failure {
  const OwnRequest();
}

final class ReasonTooShort extends Failure {
  const ReasonTooShort();
}

/// The CSV header or column count is not the expected one (FR-036).
final class BadColumns extends Failure {
  const BadColumns();
}

final class NoValidRows extends Failure {
  const NoValidRows();
}
