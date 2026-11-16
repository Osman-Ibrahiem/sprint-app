// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operating_hours.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OperatingHours _$OperatingHoursFromJson(Map<String, dynamic> json) =>
    _OperatingHours(
      ownerId: json['ownerId'] as String,
      dayOfWeek: (json['dayOfWeek'] as num).toInt(),
      openMinutes: (json['openMinutes'] as num).toInt(),
      closeMinutes: (json['closeMinutes'] as num).toInt(),
    );

Map<String, dynamic> _$OperatingHoursToJson(_OperatingHours instance) =>
    <String, dynamic>{
      'ownerId': instance.ownerId,
      'dayOfWeek': instance.dayOfWeek,
      'openMinutes': instance.openMinutes,
      'closeMinutes': instance.closeMinutes,
    };
