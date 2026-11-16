// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Price _$PriceFromJson(Map<String, dynamic> json) => _Price(
  unitId: json['unitId'] as String,
  tier: $enumDecode(_$PriceTierEnumMap, json['tier']),
  amount: (json['amount'] as num).toInt(),
  currency: json['currency'] as String? ?? 'EGP',
);

Map<String, dynamic> _$PriceToJson(_Price instance) => <String, dynamic>{
  'unitId': instance.unitId,
  'tier': _$PriceTierEnumMap[instance.tier]!,
  'amount': instance.amount,
  'currency': instance.currency,
};

const _$PriceTierEnumMap = {
  PriceTier.internal: 'internal',
  PriceTier.external: 'external',
};
