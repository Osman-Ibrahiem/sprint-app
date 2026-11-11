import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/features/catalogue/domain/price.dart';

part 'booking.freezed.dart';

/// BRD §5. Terminal: expired, cancelled, attended, noShow.
enum BookingStatus {
  pendingPayment,
  confirmed,
  expired,
  cancelled,
  attended,
  noShow,
}

enum CancelledBy { owner, admin }

/// A booking, with the tier and price frozen at creation (BR-17). Instants are
/// UTC. It is not transferable (BR-38).
@freezed
abstract class Booking with _$Booking {
  const Booking._();

  const factory Booking({
    required String id,
    required String code,
    required String userId,
    required String facilityId,
    required String unitId,
    String? trainerId,
    required DateTime start,
    required DateTime end,
    required int seats,
    required PriceTier tierAtBooking,
    required int priceAtBooking,
    required BookingStatus status,
    required String qrToken,
    DateTime? holdExpiresAt,
    CancelledBy? cancelledBy,
    String? cancelReason,
  }) = _Booking;

  /// Whether this booking takes a place in its slot at [now]: confirmed or
  /// finished bookings do, and so does a pending one whose hold is live
  /// (BR-12). Cancelled and expired ones do not.
  bool holdsPlace(DateTime now) => switch (status) {
        BookingStatus.confirmed ||
        BookingStatus.attended ||
        BookingStatus.noShow =>
          true,
        BookingStatus.pendingPayment =>
          holdExpiresAt != null && holdExpiresAt!.isAfter(now),
        BookingStatus.expired || BookingStatus.cancelled => false,
      };

  /// A live or confirmed booking that has not ended (BR-14).
  bool isActiveAt(DateTime now) =>
      (status == BookingStatus.confirmed ||
          (status == BookingStatus.pendingPayment && holdsPlace(now))) &&
      end.isAfter(now);

  bool overlaps(DateTime otherStart, DateTime otherEnd) =>
      start.isBefore(otherEnd) && otherStart.isBefore(end);

  Result<Booking> _only(BookingStatus from, Booking Function() to) =>
      status == from ? Ok(to()) : const Err(InvalidTransition());

  /// Payment succeeded.
  Result<Booking> confirm() => _only(
        BookingStatus.pendingPayment,
        () => copyWith(status: BookingStatus.confirmed, holdExpiresAt: null),
      );

  /// Payment failed or the hold ran out.
  Result<Booking> expire() => _only(
        BookingStatus.pendingPayment,
        () => copyWith(status: BookingStatus.expired),
      );

  Result<Booking> attend() => _only(
        BookingStatus.confirmed,
        () => copyWith(status: BookingStatus.attended),
      );

  Result<Booking> cancel(CancelledBy by, {String? reason}) => _only(
        BookingStatus.confirmed,
        () => copyWith(
          status: BookingStatus.cancelled,
          cancelledBy: by,
          cancelReason: reason,
        ),
      );

  /// After the slot ends with no attendance (BR-37). Nothing else changes: no
  /// penalty of any kind.
  Result<Booking> markNoShow(DateTime now) =>
      status == BookingStatus.confirmed && !now.isBefore(end)
          ? Ok(copyWith(status: BookingStatus.noShow))
          : const Err(InvalidTransition());
}
