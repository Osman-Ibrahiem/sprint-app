import 'package:sprint/features/booking/domain/booking.dart';

/// The temporary hold on a place while paying (BR-12). Pure.
class HoldPolicy {
  const HoldPolicy();

  DateTime expiryFrom(DateTime now, {required int holdMinutes}) =>
      now.add(Duration(minutes: holdMinutes));

  /// A pending booking whose hold has run out.
  bool isExpired(Booking booking, DateTime now) =>
      booking.status == BookingStatus.pendingPayment &&
      booking.holdExpiresAt != null &&
      !now.isBefore(booking.holdExpiresAt!);
}
