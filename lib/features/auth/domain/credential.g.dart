// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credential.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Credential _$CredentialFromJson(Map<String, dynamic> json) => _Credential(
  userId: json['userId'] as String,
  salt: json['salt'] as String,
  hash: json['hash'] as String,
  failedAttempts: (json['failedAttempts'] as num?)?.toInt() ?? 0,
  lockedUntil: json['lockedUntil'] == null
      ? null
      : DateTime.parse(json['lockedUntil'] as String),
);

Map<String, dynamic> _$CredentialToJson(_Credential instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'salt': instance.salt,
      'hash': instance.hash,
      'failedAttempts': instance.failedAttempts,
      'lockedUntil': instance.lockedUntil?.toIso8601String(),
    };
