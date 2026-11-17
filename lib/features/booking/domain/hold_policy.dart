import 'package:sprint/features/booking/domain/booking.dart';

/// What to do with a pending booking whose Hold is being checked (BR-12,
/// BR-46).
sealed class HoldDecision {
  const HoldDecision();
}

/// Nothing changes.
class HoldKeep extends HoldDecision {
  const HoldKeep();
}

/// A payment is pending: move the expiry once, straight to the maximum.
class HoldExtend extends HoldDecision {
  const HoldExtend(this.to);
  final DateTime to;
}

/// The Hold is over: release the place.
class HoldExpire extends HoldDecision {
  const HoldExpire();
}

/// The temporary hold on a place while paying (BR-12) and its one extension
/// while the provider has not answered (BR-46). Pure.
class HoldPolicy {
  const HoldPolicy();

  /// The normal expiry, never later than the start of the booking.
  DateTime expiryFrom(
    DateTime now, {
    required int holdMinutes,
    DateTime? start,
  }) =>
      _capped(now.add(Duration(minutes: holdMinutes)), start);

  /// The longest the Hold can run while a payment is pending (BR-46). A
  /// `holdMaxMinutes` below `holdMinutes` gives no extension.
  DateTime maxExpiryFrom(
    DateTime now, {
    required int holdMinutes,
    required int holdMaxMinutes,
    DateTime? start,
  }) =>
      _capped(
        now.add(Duration(
            minutes: holdMaxMinutes > holdMinutes ? holdMaxMinutes : holdMinutes)),
        start,
      );

  DateTime _capped(DateTime at, DateTime? start) =>
      start != null && start.isBefore(at) ? start : at;

  /// A pending booking whose (possibly extended) hold has run out.
  bool isExpired(Booking booking, DateTime now) =>
      booking.status == BookingStatus.pendingPayment &&
      booking.holdExpiresAt != null &&
      !now.isBefore(booking.holdExpiresAt!);

  /// BR-12 + BR-46 for one booking at [now].
  HoldDecision nextExpiry(
    Booking b,
    DateTime now, {
    required bool hasPendingPayment,
  }) {
    final expires = b.holdExpiresAt;
    if (b.status != BookingStatus.pendingPayment || expires == null) {
      return const HoldKeep();
    }
    if (now.isBefore(expires)) return const HoldKeep();
    final max = b.holdMaxExpiresAt;
    if (hasPendingPayment &&
        max != null &&
        expires.isBefore(max) &&
        now.isBefore(max)) {
      return HoldExtend(max);
    }
    return const HoldExpire();
  }

  /// Whether a failed or cancelled answer arriving at [now] ends the booking
  /// at once: the Hold had been extended and its normal time is over, so the
  /// extension never buys retry time (BR-46 "لحد رد المزوّد").
  bool expiresOnAnswer(Booking b, DateTime now) {
    final extendedAt = b.holdExtendedAt;
    return b.holdExpiresAt != null &&
        b.holdExpiresAt == b.holdMaxExpiresAt &&
        extendedAt != null &&
        !now.isBefore(extendedAt);
  }
}
