// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sheet_row.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SheetRow _$SheetRowFromJson(Map<String, dynamic> json) => _SheetRow(
  nationalId: json['nationalId'] as String,
  code: json['code'] as String,
  type: $enumDecode(_$VerificationTypeEnumMap, json['type']),
  uploadedBy: json['uploadedBy'] as String,
  batchId: json['batchId'] as String,
  owningUnitId: json['owningUnitId'] as String?,
);

Map<String, dynamic> _$SheetRowToJson(_SheetRow instance) => <String, dynamic>{
  'nationalId': instance.nationalId,
  'code': instance.code,
  'type': _$VerificationTypeEnumMap[instance.type]!,
  'uploadedBy': instance.uploadedBy,
  'batchId': instance.batchId,
  'owningUnitId': instance.owningUnitId,
};

const _$VerificationTypeEnumMap = {
  VerificationType.student: 'student',
  VerificationType.staff: 'staff',
  VerificationType.faculty: 'faculty',
};
