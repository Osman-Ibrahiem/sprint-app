// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facility.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Facility _$FacilityFromJson(Map<String, dynamic> json) => _Facility(
  id: json['id'] as String,
  owningUnitId: json['owningUnitId'] as String,
  name: json['name'] as String,
  type: $enumDecode(_$FacilityTypeEnumMap, json['type']),
  description: json['description'] as String,
  photos:
      (json['photos'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  location: json['location'] as String,
  isFree: json['isFree'] as bool,
  requiresTrainer: json['requiresTrainer'] as bool,
  isPublished: json['isPublished'] as bool? ?? true,
);

Map<String, dynamic> _$FacilityToJson(_Facility instance) => <String, dynamic>{
  'id': instance.id,
  'owningUnitId': instance.owningUnitId,
  'name': instance.name,
  'type': _$FacilityTypeEnumMap[instance.type]!,
  'description': instance.description,
  'photos': instance.photos,
  'location': instance.location,
  'isFree': instance.isFree,
  'requiresTrainer': instance.requiresTrainer,
  'isPublished': instance.isPublished,
};

const _$FacilityTypeEnumMap = {
  FacilityType.swimming: 'swimming',
  FacilityType.football: 'football',
  FacilityType.gym: 'gym',
  FacilityType.tennis: 'tennis',
  FacilityType.hall: 'hall',
  FacilityType.training: 'training',
};
