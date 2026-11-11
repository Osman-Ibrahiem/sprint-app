import 'package:sprint/features/attendance/domain/attendance.dart';

abstract interface class AttendanceRepository {
  Future<Attendance?> forBooking(String bookingId);
  Future<List<Attendance>> list();
  Future<void> save(Attendance attendance);
}
