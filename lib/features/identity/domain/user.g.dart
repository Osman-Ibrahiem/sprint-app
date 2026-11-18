// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String,
  name: json['name'] as String,
  phone: json['phone'] as String,
  email: json['email'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  nationalId: json['nationalId'] as String?,
  status:
      $enumDecodeNullable(_$UserStatusEnumMap, json['status']) ??
      UserStatus.active,
  avatarId: json['avatarId'] as String?,
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'phone': instance.phone,
  'email': instance.email,
  'createdAt': instance.createdAt.toIso8601String(),
  'nationalId': instance.nationalId,
  'status': _$UserStatusEnumMap[instance.status]!,
  'avatarId': instance.avatarId,
};

const _$UserStatusEnumMap = {
  UserStatus.unconfirmed: 'unconfirmed',
  UserStatus.active: 'active',
  UserStatus.suspended: 'suspended',
};
