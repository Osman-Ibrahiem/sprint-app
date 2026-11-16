// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Asset _$AssetFromJson(Map<String, dynamic> json) => _Asset(
  id: json['id'] as String,
  facilityId: json['facilityId'] as String,
  name: json['name'] as String,
  code: json['code'] as String,
  quantity: (json['quantity'] as num).toInt(),
  custodianId: json['custodianId'] as String,
  status: $enumDecode(_$AssetStatusEnumMap, json['status']),
);

Map<String, dynamic> _$AssetToJson(_Asset instance) => <String, dynamic>{
  'id': instance.id,
  'facilityId': instance.facilityId,
  'name': instance.name,
  'code': instance.code,
  'quantity': instance.quantity,
  'custodianId': instance.custodianId,
  'status': _$AssetStatusEnumMap[instance.status]!,
};

const _$AssetStatusEnumMap = {
  AssetStatus.ok: 'ok',
  AssetStatus.damaged: 'damaged',
  AssetStatus.underRepair: 'underRepair',
  AssetStatus.lost: 'lost',
  AssetStatus.retired: 'retired',
};
