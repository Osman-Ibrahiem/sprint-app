// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simulated_email.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SimulatedEmail _$SimulatedEmailFromJson(Map<String, dynamic> json) =>
    _SimulatedEmail(
      id: json['id'] as String,
      to: json['to'] as String,
      subject: json['subject'] as String,
      body: json['body'] as String,
      purpose: $enumDecode(_$CodePurposeEnumMap, json['purpose']),
      sentAt: DateTime.parse(json['sentAt'] as String),
    );

Map<String, dynamic> _$SimulatedEmailToJson(_SimulatedEmail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'to': instance.to,
      'subject': instance.subject,
      'body': instance.body,
      'purpose': _$CodePurposeEnumMap[instance.purpose]!,
      'sentAt': instance.sentAt.toIso8601String(),
    };

const _$CodePurposeEnumMap = {
  CodePurpose.confirmEmail: 'confirmEmail',
  CodePurpose.resetPassword: 'resetPassword',
};
