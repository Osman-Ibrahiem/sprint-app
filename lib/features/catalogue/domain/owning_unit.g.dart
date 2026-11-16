// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owning_unit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OwningUnit _$OwningUnitFromJson(Map<String, dynamic> json) => _OwningUnit(
  id: json['id'] as String,
  name: json['name'] as String,
  type: $enumDecode(_$OwningUnitTypeEnumMap, json['type']),
);

Map<String, dynamic> _$OwningUnitToJson(_OwningUnit instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$OwningUnitTypeEnumMap[instance.type]!,
    };

const _$OwningUnitTypeEnumMap = {
  OwningUnitType.faculty: 'faculty',
  OwningUnitType.central: 'central',
};
