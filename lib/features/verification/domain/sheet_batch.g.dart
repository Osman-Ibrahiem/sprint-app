// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sheet_batch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SheetProblem _$SheetProblemFromJson(Map<String, dynamic> json) =>
    _SheetProblem(
      rowNumber: (json['rowNumber'] as num).toInt(),
      reasonCode: json['reasonCode'] as String,
    );

Map<String, dynamic> _$SheetProblemToJson(_SheetProblem instance) =>
    <String, dynamic>{
      'rowNumber': instance.rowNumber,
      'reasonCode': instance.reasonCode,
    };

_SheetBatch _$SheetBatchFromJson(Map<String, dynamic> json) => _SheetBatch(
  id: json['id'] as String,
  uploadedBy: json['uploadedBy'] as String,
  fileName: json['fileName'] as String,
  uploadedAt: DateTime.parse(json['uploadedAt'] as String),
  owningUnitId: json['owningUnitId'] as String?,
  rowsRead: (json['rowsRead'] as num?)?.toInt() ?? 0,
  rowsAdded: (json['rowsAdded'] as num?)?.toInt() ?? 0,
  duplicates: (json['duplicates'] as num?)?.toInt() ?? 0,
  invalid: (json['invalid'] as num?)?.toInt() ?? 0,
  approved: (json['approved'] as num?)?.toInt() ?? 0,
  problems:
      (json['problems'] as List<dynamic>?)
          ?.map((e) => SheetProblem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$SheetBatchToJson(_SheetBatch instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uploadedBy': instance.uploadedBy,
      'fileName': instance.fileName,
      'uploadedAt': instance.uploadedAt.toIso8601String(),
      'owningUnitId': instance.owningUnitId,
      'rowsRead': instance.rowsRead,
      'rowsAdded': instance.rowsAdded,
      'duplicates': instance.duplicates,
      'invalid': instance.invalid,
      'approved': instance.approved,
      'problems': instance.problems,
    };
