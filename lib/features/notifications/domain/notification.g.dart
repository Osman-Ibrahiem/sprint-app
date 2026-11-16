// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Notification _$NotificationFromJson(Map<String, dynamic> json) =>
    _Notification(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      channel:
          $enumDecodeNullable(_$NotificationChannelEnumMap, json['channel']) ??
          NotificationChannel.push,
      payload:
          (json['payload'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const <String, String>{},
      sentAt: DateTime.parse(json['sentAt'] as String),
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
    );

Map<String, dynamic> _$NotificationToJson(_Notification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': instance.type,
      'channel': _$NotificationChannelEnumMap[instance.channel]!,
      'payload': instance.payload,
      'sentAt': instance.sentAt.toIso8601String(),
      'readAt': instance.readAt?.toIso8601String(),
    };

const _$NotificationChannelEnumMap = {NotificationChannel.push: 'push'};
