// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Trainer _$TrainerFromJson(Map<String, dynamic> json) => _Trainer(
  id: json['id'] as String,
  userId: json['userId'] as String,
  facilityIds: (json['facilityIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  bio: json['bio'] as String,
  trainerCapacity: (json['trainerCapacity'] as num).toInt(),
);

Map<String, dynamic> _$TrainerToJson(_Trainer instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'facilityIds': instance.facilityIds,
  'bio': instance.bio,
  'trainerCapacity': instance.trainerCapacity,
};
