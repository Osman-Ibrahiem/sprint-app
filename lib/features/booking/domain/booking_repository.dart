import 'package:sprint/core/result/result.dart';
import 'package:sprint/features/attendance/domain/attendance.dart';
import 'package:sprint/features/booking/domain/booking.dart';

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

/// Bookings and their lifecycle. Expected refusals come back as `Err`.
abstract interface class BookingRepository {
  /// Atomic: permission, availability, conflicts, pricing and hold in one step
  /// (BR-11). A free facility confirms at once (BR-19); a paid one waits for
  /// [pay].
  Future<Result<Booking>> create(BookingRequest request);

  Future<Result<Booking>> get(String id);
  Future<List<Booking>> listForUser(String userId, {bool upcoming = false});
  Future<List<Booking>> listForFacility(
    String facilityId, {
    DateTime? from,
    DateTime? to,
  });

  /// Runs the payment through the provider. Only a provider status confirms
  /// (BR-28); a failure expires the booking.
  Future<Result<Booking>> pay(String id);

  /// By the owner (before the cutoff) or an admin (always 100% back).
  Future<Result<Booking>> cancel(
    String id,
    String actorUserId, {
    String? reason,
  });

  Future<Result<Booking>> markAttendance(
    String id,
    AttendanceMethod method,
    String actorUserId,
  );

  /// Expires pending bookings whose hold ran out. Returns how many.
  Future<int> expireHolds();

  /// Turns confirmed bookings past their end into no-shows. Returns how many.
  Future<int> markNoShows();
}
