// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Offer _$OfferFromJson(Map<String, dynamic> json) => _Offer(
  id: json['id'] as String,
  scope: $enumDecode(_$OfferScopeEnumMap, json['scope']),
  scopeId: json['scopeId'] as String?,
  discountPercent: (json['discountPercent'] as num).toInt(),
  days: (json['days'] as List<dynamic>).map((e) => (e as num).toInt()).toSet(),
  fromMinutes: (json['fromMinutes'] as num).toInt(),
  toMinutes: (json['toMinutes'] as num).toInt(),
  tier: $enumDecodeNullable(_$PriceTierEnumMap, json['tier']),
  validFrom: DateTime.parse(json['validFrom'] as String),
  validTo: DateTime.parse(json['validTo'] as String),
);

Map<String, dynamic> _$OfferToJson(_Offer instance) => <String, dynamic>{
  'id': instance.id,
  'scope': _$OfferScopeEnumMap[instance.scope]!,
  'scopeId': instance.scopeId,
  'discountPercent': instance.discountPercent,
  'days': instance.days.toList(),
  'fromMinutes': instance.fromMinutes,
  'toMinutes': instance.toMinutes,
  'tier': _$PriceTierEnumMap[instance.tier],
  'validFrom': instance.validFrom.toIso8601String(),
  'validTo': instance.validTo.toIso8601String(),
};

const _$OfferScopeEnumMap = {
  OfferScope.university: 'university',
  OfferScope.facility: 'facility',
  OfferScope.unit: 'unit',
};

const _$PriceTierEnumMap = {
  PriceTier.internal: 'internal',
  PriceTier.external: 'external',
};
