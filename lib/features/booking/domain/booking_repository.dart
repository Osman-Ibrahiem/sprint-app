import 'package:sprint/core/result/result.dart';
import 'package:sprint/features/attendance/domain/attendance.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/booking_quote.dart';
import 'package:sprint/features/booking/domain/cancel_preview.dart';
import 'package:sprint/features/payments/domain/payment.dart';
import 'package:sprint/features/payments/domain/payment_provider.dart';
import 'package:sprint/features/payments/domain/refund.dart';

class BookingRequest {
  const BookingRequest({
    required this.userId,
    required this.unitId,
    required this.start,
    required this.end,
    this.seats = 1,
    this.trainerId,
  });

  /// Null for a guest, who is refused with `NotPermitted`.
  final String? userId;
  final String unitId;
  final DateTime start;
  final DateTime end;
  final int seats;
  final String? trainerId;
}

/// A booking with its latest payment attempt and that payment's refund, if
/// any. Emitted by [BookingRepository.watchBooking]; the checkout screen is
/// derived from it (data-model.md).
class BookingCheckoutState {
  const BookingCheckoutState({
    required this.booking,
    this.latestPayment,
    this.refund,
  });
  final Booking booking;
  final Payment? latestPayment;
  final Refund? refund;
}

/// Bookings and their lifecycle. Expected refusals come back as `Err`.
abstract interface class BookingRepository {
  /// Atomic: permission, availability, conflicts, pricing and hold in one step
  /// (BR-11). A free facility confirms at once (BR-19); a paid one is
  /// `PENDING_PAYMENT` with `holdStartedAt`, `holdExpiresAt` and
  /// `holdMaxExpiresAt` (BR-12, BR-46) and waits for the provider (BR-28).
  Future<Result<Booking>> create(BookingRequest request);

  /// Runs every check [create] runs, in the same order and the same queue, and
  /// writes nothing: no booking, no hold, no notification (research R6). The
  /// summary shows the result; a paid booking is then handed to checkout,
  /// which calls [create]. A guest request is refused with `NotPermitted`.
  Future<Result<BookingQuote>> quote(BookingRequest request);

  /// Fires after each successful write, so open schedules reload.
  Stream<void> get changes;

  Future<Result<Booking>> get(String id);
  Future<List<Booking>> listForUser(String userId, {bool upcoming = false});
  Future<List<Booking>> listForFacility(
    String facilityId, {
    DateTime? from,
    DateTime? to,
  });

  /// Owner only; booking `PENDING_PAYMENT` with a live Hold. If a pending
  /// payment exists its session is returned instead of starting another. The
  /// repository listens to the provider and applies each answer; only the
  /// provider's status confirms (BR-28).
  /// Errors: NotFound, NotPermitted, InvalidTransition, HoldExpired,
  /// PaymentUnavailable.
  Future<Result<PaymentSession>> startPayment(String bookingId, String userId);

  /// Applies the provider's immediate status for the latest pending payment
  /// ("تحديث الحالة", FR-015). Never confirms by itself.
  /// Errors: NotFound, NoPendingPayment.
  Future<Result<BookingCheckoutState>> refreshPayment(String bookingId);

  /// BR-47 "ترك الدفع": `PENDING_PAYMENT` to `EXPIRED` now. Owner only.
  Future<Result<Booking>> leaveCheckout(String bookingId, String userId);

  /// Booking, latest payment and refund: on subscribe and after every write.
  Stream<BookingCheckoutState> watchBooking(String bookingId);

  /// By the owner (before the cutoff) or an admin (always 100% back).
  /// A second call on a cancelled booking returns it unchanged (idempotent).
  Future<Result<Booking>> cancel(
    String id,
    String actorUserId, {
    String? reason,
  });

  /// The same decision [cancel] would make, without writing anything
  /// (research R3). The dialog reads it on open; [cancel] re-checks.
  Future<CancelPreview> previewCancel(String id, String actorUserId);

  Future<Result<Booking>> markAttendance(
    String id,
    AttendanceMethod method,
    String actorUserId,
  );

  /// BR-12 + BR-46: a pending booking whose Hold ran out is extended once to
  /// `holdMaxExpiresAt` when a payment is pending, otherwise expired. Returns
  /// how many were expired.
  Future<int> expireHolds();

  /// Turns confirmed bookings past their end into no-shows. Returns how many.
  Future<int> markNoShows();
}
