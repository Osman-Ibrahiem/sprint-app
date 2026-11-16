// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_assignment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RoleAssignment _$RoleAssignmentFromJson(Map<String, dynamic> json) =>
    _RoleAssignment(
      userId: json['userId'] as String,
      role: $enumDecode(_$RoleEnumMap, json['role']),
      scopeType: $enumDecode(_$RoleScopeTypeEnumMap, json['scopeType']),
      scopeId: json['scopeId'] as String?,
    );

Map<String, dynamic> _$RoleAssignmentToJson(_RoleAssignment instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'role': _$RoleEnumMap[instance.role]!,
      'scopeType': _$RoleScopeTypeEnumMap[instance.scopeType]!,
      'scopeId': instance.scopeId,
    };

const _$RoleEnumMap = {
  Role.guest: 'guest',
  Role.booker: 'booker',
  Role.trainer: 'trainer',
  Role.facilityManager: 'facilityManager',
  Role.verifier: 'verifier',
  Role.unitAdmin: 'unitAdmin',
  Role.superAdmin: 'superAdmin',
  Role.viewer: 'viewer',
};

const _$RoleScopeTypeEnumMap = {
  RoleScopeType.university: 'university',
  RoleScopeType.owningUnit: 'owningUnit',
  RoleScopeType.facility: 'facility',
};
