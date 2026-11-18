// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Booking _$BookingFromJson(Map<String, dynamic> json) => _Booking(
  id: json['id'] as String,
  code: json['code'] as String,
  userId: json['userId'] as String,
  facilityId: json['facilityId'] as String,
  unitId: json['unitId'] as String,
  trainerId: json['trainerId'] as String?,
  start: DateTime.parse(json['start'] as String),
  end: DateTime.parse(json['end'] as String),
  seats: (json['seats'] as num).toInt(),
  tierAtBooking: $enumDecode(_$PriceTierEnumMap, json['tierAtBooking']),
  priceAtBooking: (json['priceAtBooking'] as num).toInt(),
  status: $enumDecode(_$BookingStatusEnumMap, json['status']),
  qrToken: json['qrToken'] as String,
  holdExpiresAt: json['holdExpiresAt'] == null
      ? null
      : DateTime.parse(json['holdExpiresAt'] as String),
  holdStartedAt: json['holdStartedAt'] == null
      ? null
      : DateTime.parse(json['holdStartedAt'] as String),
  holdMaxExpiresAt: json['holdMaxExpiresAt'] == null
      ? null
      : DateTime.parse(json['holdMaxExpiresAt'] as String),
  holdExtendedAt: json['holdExtendedAt'] == null
      ? null
      : DateTime.parse(json['holdExtendedAt'] as String),
  cancelledBy: $enumDecodeNullable(_$CancelledByEnumMap, json['cancelledBy']),
  cancelReason: json['cancelReason'] as String?,
  cancelledAt: json['cancelledAt'] == null
      ? null
      : DateTime.parse(json['cancelledAt'] as String),
);

Map<String, dynamic> _$BookingToJson(_Booking instance) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'userId': instance.userId,
  'facilityId': instance.facilityId,
  'unitId': instance.unitId,
  'trainerId': instance.trainerId,
  'start': instance.start.toIso8601String(),
  'end': instance.end.toIso8601String(),
  'seats': instance.seats,
  'tierAtBooking': _$PriceTierEnumMap[instance.tierAtBooking]!,
  'priceAtBooking': instance.priceAtBooking,
  'status': _$BookingStatusEnumMap[instance.status]!,
  'qrToken': instance.qrToken,
  'holdExpiresAt': instance.holdExpiresAt?.toIso8601String(),
  'holdStartedAt': instance.holdStartedAt?.toIso8601String(),
  'holdMaxExpiresAt': instance.holdMaxExpiresAt?.toIso8601String(),
  'holdExtendedAt': instance.holdExtendedAt?.toIso8601String(),
  'cancelledBy': _$CancelledByEnumMap[instance.cancelledBy],
  'cancelReason': instance.cancelReason,
  'cancelledAt': instance.cancelledAt?.toIso8601String(),
};

const _$PriceTierEnumMap = {
  PriceTier.internal: 'internal',
  PriceTier.external: 'external',
};

const _$BookingStatusEnumMap = {
  BookingStatus.pendingPayment: 'pendingPayment',
  BookingStatus.confirmed: 'confirmed',
  BookingStatus.expired: 'expired',
  BookingStatus.cancelled: 'cancelled',
  BookingStatus.attended: 'attended',
  BookingStatus.noShow: 'noShow',
};

const _$CancelledByEnumMap = {
  CancelledBy.owner: 'owner',
  CancelledBy.admin: 'admin',
};
