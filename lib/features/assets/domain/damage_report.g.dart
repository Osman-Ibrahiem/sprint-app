// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'damage_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DamageReport _$DamageReportFromJson(Map<String, dynamic> json) =>
    _DamageReport(
      id: json['id'] as String,
      assetId: json['assetId'] as String,
      reportedBy: json['reportedBy'] as String,
      description: json['description'] as String,
      photos:
          (json['photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      status: $enumDecode(_$DamageReportStatusEnumMap, json['status']),
      linkedClosureId: json['linkedClosureId'] as String?,
    );

Map<String, dynamic> _$DamageReportToJson(_DamageReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'assetId': instance.assetId,
      'reportedBy': instance.reportedBy,
      'description': instance.description,
      'photos': instance.photos,
      'status': _$DamageReportStatusEnumMap[instance.status]!,
      'linkedClosureId': instance.linkedClosureId,
    };

const _$DamageReportStatusEnumMap = {
  DamageReportStatus.open: 'open',
  DamageReportStatus.inProgress: 'inProgress',
  DamageReportStatus.resolved: 'resolved',
  DamageReportStatus.rejected: 'rejected',
};
