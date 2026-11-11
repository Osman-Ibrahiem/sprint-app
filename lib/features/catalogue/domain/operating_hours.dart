import 'package:freezed_annotation/freezed_annotation.dart';

part 'operating_hours.freezed.dart';

/// Weekly hours of a unit or a facility, in Cairo wall-clock minutes from
/// midnight. [dayOfWeek] is 1 (Monday) to 7 (Sunday), as in `DateTime`.
@freezed
abstract class OperatingHours with _$OperatingHours {
  const factory OperatingHours({
    required String ownerId,
    required int dayOfWeek,
    required int openMinutes,
    required int closeMinutes,
  }) = _OperatingHours;
}
