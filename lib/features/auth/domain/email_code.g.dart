// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_code.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EmailCode _$EmailCodeFromJson(Map<String, dynamic> json) => _EmailCode(
  userId: json['userId'] as String,
  purpose: $enumDecode(_$CodePurposeEnumMap, json['purpose']),
  code: json['code'] as String,
  expiresAt: DateTime.parse(json['expiresAt'] as String),
  resendAfter: DateTime.parse(json['resendAfter'] as String),
  wrongTries: (json['wrongTries'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$EmailCodeToJson(_EmailCode instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'purpose': _$CodePurposeEnumMap[instance.purpose]!,
      'code': instance.code,
      'expiresAt': instance.expiresAt.toIso8601String(),
      'resendAfter': instance.resendAfter.toIso8601String(),
      'wrongTries': instance.wrongTries,
    };

const _$CodePurposeEnumMap = {
  CodePurpose.confirmEmail: 'confirmEmail',
  CodePurpose.resetPassword: 'resetPassword',
};
