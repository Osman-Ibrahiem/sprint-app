// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Verification _$VerificationFromJson(Map<String, dynamic> json) =>
    _Verification(
      userId: json['userId'] as String,
      type: $enumDecode(_$VerificationTypeEnumMap, json['type']),
      status: $enumDecode(_$VerificationStatusEnumMap, json['status']),
      method: $enumDecode(_$VerificationMethodEnumMap, json['method']),
      reason: json['reason'] as String?,
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$VerificationToJson(_Verification instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'type': _$VerificationTypeEnumMap[instance.type]!,
      'status': _$VerificationStatusEnumMap[instance.status]!,
      'method': _$VerificationMethodEnumMap[instance.method]!,
      'reason': instance.reason,
      'expiresAt': instance.expiresAt?.toIso8601String(),
    };

const _$VerificationTypeEnumMap = {
  VerificationType.student: 'student',
  VerificationType.staff: 'staff',
  VerificationType.faculty: 'faculty',
};

const _$VerificationStatusEnumMap = {
  VerificationStatus.pending: 'pending',
  VerificationStatus.approved: 'approved',
  VerificationStatus.rejected: 'rejected',
};

const _$VerificationMethodEnumMap = {
  VerificationMethod.auto: 'auto',
  VerificationMethod.manual: 'manual',
};
