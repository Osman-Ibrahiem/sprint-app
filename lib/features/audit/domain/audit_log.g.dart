// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuditLog _$AuditLogFromJson(Map<String, dynamic> json) => _AuditLog(
  actorId: json['actorId'] as String,
  action: json['action'] as String,
  entity: json['entity'] as String,
  entityId: json['entityId'] as String,
  before: json['before'] as String?,
  after: json['after'] as String?,
  at: DateTime.parse(json['at'] as String),
);

Map<String, dynamic> _$AuditLogToJson(_AuditLog instance) => <String, dynamic>{
  'actorId': instance.actorId,
  'action': instance.action,
  'entity': instance.entity,
  'entityId': instance.entityId,
  'before': instance.before,
  'after': instance.after,
  'at': instance.at.toIso8601String(),
};
