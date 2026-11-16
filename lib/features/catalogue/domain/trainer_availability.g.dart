// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_availability.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrainerAvailability _$TrainerAvailabilityFromJson(Map<String, dynamic> json) =>
    _TrainerAvailability(
      trainerId: json['trainerId'] as String,
      unitId: json['unitId'] as String,
      dayOfWeek: (json['dayOfWeek'] as num).toInt(),
      fromMinutes: (json['fromMinutes'] as num).toInt(),
      toMinutes: (json['toMinutes'] as num).toInt(),
    );

Map<String, dynamic> _$TrainerAvailabilityToJson(
  _TrainerAvailability instance,
) => <String, dynamic>{
  'trainerId': instance.trainerId,
  'unitId': instance.unitId,
  'dayOfWeek': instance.dayOfWeek,
  'fromMinutes': instance.fromMinutes,
  'toMinutes': instance.toMinutes,
};
