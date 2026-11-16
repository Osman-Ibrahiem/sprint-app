// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookable_unit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BookableUnit _$BookableUnitFromJson(Map<String, dynamic> json) =>
    _BookableUnit(
      id: json['id'] as String,
      facilityId: json['facilityId'] as String,
      name: json['name'] as String,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$BookableUnitToJson(_BookableUnit instance) =>
    <String, dynamic>{
      'id': instance.id,
      'facilityId': instance.facilityId,
      'name': instance.name,
      'isActive': instance.isActive,
    };
