import 'package:freezed_annotation/freezed_annotation.dart';

part 'sheet_batch.freezed.dart';
part 'sheet_batch.g.dart';

/// A rejected line of an upload: its 1-based row number and a stable reason
/// code (FR-038).
@freezed
abstract class SheetProblem with _$SheetProblem {
  const factory SheetProblem({
    required int rowNumber,
    required String reasonCode,
  }) = _SheetProblem;

  factory SheetProblem.fromJson(Map<String, dynamic> json) =>
      _$SheetProblemFromJson(json);
}

/// One upload and its summary (FR-038). [owningUnitId] is the uploader's scope.
@freezed
abstract class SheetBatch with _$SheetBatch {
  const factory SheetBatch({
    required String id,
    required String uploadedBy,
    required String fileName,
    required DateTime uploadedAt,
    String? owningUnitId,
    @Default(0) int rowsRead,
    @Default(0) int rowsAdded,
    @Default(0) int duplicates,
    @Default(0) int invalid,
    @Default(0) int approved,
    @Default([]) List<SheetProblem> problems,
  }) = _SheetBatch;

  factory SheetBatch.fromJson(Map<String, dynamic> json) =>
      _$SheetBatchFromJson(json);
}
