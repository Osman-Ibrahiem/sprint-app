// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Attendance _$AttendanceFromJson(Map<String, dynamic> json) => _Attendance(
  bookingId: json['bookingId'] as String,
  status: $enumDecode(_$AttendanceStatusEnumMap, json['status']),
  method: $enumDecode(_$AttendanceMethodEnumMap, json['method']),
  markedBy: json['markedBy'] as String,
  markedAt: DateTime.parse(json['markedAt'] as String),
);

Map<String, dynamic> _$AttendanceToJson(_Attendance instance) =>
    <String, dynamic>{
      'bookingId': instance.bookingId,
      'status': _$AttendanceStatusEnumMap[instance.status]!,
      'method': _$AttendanceMethodEnumMap[instance.method]!,
      'markedBy': instance.markedBy,
      'markedAt': instance.markedAt.toIso8601String(),
    };

const _$AttendanceStatusEnumMap = {
  AttendanceStatus.present: 'present',
  AttendanceStatus.noShow: 'noShow',
};

const _$AttendanceMethodEnumMap = {
  AttendanceMethod.qr: 'qr',
  AttendanceMethod.manual: 'manual',
  AttendanceMethod.auto: 'auto',
};
