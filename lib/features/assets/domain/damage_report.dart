import 'package:freezed_annotation/freezed_annotation.dart';

part 'damage_report.freezed.dart';

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
}
