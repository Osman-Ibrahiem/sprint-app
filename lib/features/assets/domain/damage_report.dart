import 'package:freezed_annotation/freezed_annotation.dart';

part 'damage_report.freezed.dart';
part 'damage_report.g.dart';

/// BR-43.
enum DamageReportStatus { open, inProgress, resolved, rejected }

@freezed
abstract class DamageReport with _$DamageReport {
  const factory DamageReport({
    required String id,
    required String assetId,
    required String reportedBy,
    required String description,
    @Default(<String>[]) List<String> photos,
    required DamageReportStatus status,
    String? linkedClosureId,
  }) = _DamageReport;

  factory DamageReport.fromJson(Map<String, dynamic> json) =>
      _$DamageReportFromJson(json);
}
