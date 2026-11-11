import 'package:freezed_annotation/freezed_annotation.dart';

part 'attendance.freezed.dart';

enum AttendanceStatus { present, noShow }

/// How attendance was recorded. Manual entries are flagged (BR-34).
enum AttendanceMethod { qr, manual, auto }

@freezed
abstract class Attendance with _$Attendance {
  const factory Attendance({
    required String bookingId,
    required AttendanceStatus status,
    required AttendanceMethod method,
    required String markedBy,
    required DateTime markedAt,
  }) = _Attendance;
}
