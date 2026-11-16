// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refund.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Refund _$RefundFromJson(Map<String, dynamic> json) => _Refund(
  id: json['id'] as String,
  paymentId: json['paymentId'] as String,
  amount: (json['amount'] as num).toInt(),
  reason: json['reason'] as String,
  status: $enumDecode(_$RefundStatusEnumMap, json['status']),
);

Map<String, dynamic> _$RefundToJson(_Refund instance) => <String, dynamic>{
  'id': instance.id,
  'paymentId': instance.paymentId,
  'amount': instance.amount,
  'reason': instance.reason,
  'status': _$RefundStatusEnumMap[instance.status]!,
};

const _$RefundStatusEnumMap = {
  RefundStatus.succeeded: 'succeeded',
  RefundStatus.failed: 'failed',
};
