import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sprint/features/identity/domain/verification.dart';

part 'sheet_row.freezed.dart';
part 'sheet_row.g.dart';

/// One accepted line of an uploaded sheet: a person the university already
/// confirmed (BR-23). Unique by (nationalId, code, type, owningUnitId);
/// [owningUnitId] is the uploader's unit, null for university scope (FR-032).
@freezed
abstract class SheetRow with _$SheetRow {
  const factory SheetRow({
    required String nationalId,
    required String code,
    required VerificationType type,
    required String uploadedBy,
    required String batchId,
    String? owningUnitId,
  }) = _SheetRow;

  factory SheetRow.fromJson(Map<String, dynamic> json) =>
      _$SheetRowFromJson(json);
}
