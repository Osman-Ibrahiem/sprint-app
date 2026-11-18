// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Payment _$PaymentFromJson(Map<String, dynamic> json) => _Payment(
  id: json['id'] as String,
  bookingId: json['bookingId'] as String,
  provider: json['provider'] as String,
  providerRef: json['providerRef'] as String,
  amount: (json['amount'] as num).toInt(),
  status: $enumDecode(_$PaymentStatusEnumMap, json['status']),
  startedAt: DateTime.parse(json['startedAt'] as String),
  paidAt: json['paidAt'] == null
      ? null
      : DateTime.parse(json['paidAt'] as String),
  owningUnitId: json['owningUnitId'] as String,
  cardLast4: json['cardLast4'] as String?,
  receiptNumber: json['receiptNumber'] as String?,
);

Map<String, dynamic> _$PaymentToJson(_Payment instance) => <String, dynamic>{
  'id': instance.id,
  'bookingId': instance.bookingId,
  'provider': instance.provider,
  'providerRef': instance.providerRef,
  'amount': instance.amount,
  'status': _$PaymentStatusEnumMap[instance.status]!,
  'startedAt': instance.startedAt.toIso8601String(),
  'paidAt': instance.paidAt?.toIso8601String(),
  'owningUnitId': instance.owningUnitId,
  'cardLast4': instance.cardLast4,
  'receiptNumber': instance.receiptNumber,
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'pending',
  PaymentStatus.succeeded: 'succeeded',
  PaymentStatus.failed: 'failed',
  PaymentStatus.cancelled: 'cancelled',
};
