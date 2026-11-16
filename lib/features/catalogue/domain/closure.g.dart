// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'closure.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Closure _$ClosureFromJson(Map<String, dynamic> json) => _Closure(
  id: json['id'] as String,
  scope: $enumDecode(_$ClosureScopeEnumMap, json['scope']),
  scopeId: json['scopeId'] as String,
  from: DateTime.parse(json['from'] as String),
  to: DateTime.parse(json['to'] as String),
  reason: json['reason'] as String,
);

Map<String, dynamic> _$ClosureToJson(_Closure instance) => <String, dynamic>{
  'id': instance.id,
  'scope': _$ClosureScopeEnumMap[instance.scope]!,
  'scopeId': instance.scopeId,
  'from': instance.from.toIso8601String(),
  'to': instance.to.toIso8601String(),
  'reason': instance.reason,
};

const _$ClosureScopeEnumMap = {
  ClosureScope.facility: 'facility',
  ClosureScope.unit: 'unit',
};
