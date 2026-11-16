// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Verification _$VerificationFromJson(Map<String, dynamic> json) =>
    _Verification(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: $enumDecode(_$VerificationTypeEnumMap, json['type']),
      nationalId: json['nationalId'] as String,
      code: json['code'] as String,
      owningUnitId: json['owningUnitId'] as String,
      status: $enumDecode(_$VerificationStatusEnumMap, json['status']),
      method: $enumDecode(_$VerificationMethodEnumMap, json['method']),
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      photoId: json['photoId'] as String?,
      reviewerId: json['reviewerId'] as String?,
      reason: json['reason'] as String?,
      decidedAt: json['decidedAt'] == null
          ? null
          : DateTime.parse(json['decidedAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$VerificationToJson(_Verification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': _$VerificationTypeEnumMap[instance.type]!,
      'nationalId': instance.nationalId,
      'code': instance.code,
      'owningUnitId': instance.owningUnitId,
      'status': _$VerificationStatusEnumMap[instance.status]!,
      'method': _$VerificationMethodEnumMap[instance.method]!,
      'submittedAt': instance.submittedAt.toIso8601String(),
      'photoId': instance.photoId,
      'reviewerId': instance.reviewerId,
      'reason': instance.reason,
      'decidedAt': instance.decidedAt?.toIso8601String(),
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
