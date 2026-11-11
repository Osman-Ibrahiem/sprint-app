import 'package:freezed_annotation/freezed_annotation.dart';

part 'asset.freezed.dart';

/// BR-42.
enum AssetStatus { ok, damaged, underRepair, lost, retired }

@freezed
abstract class Asset with _$Asset {
  const factory Asset({
    required String id,
    required String facilityId,
    required String name,
    required String code,
    required int quantity,
    required String custodianId,
    required AssetStatus status,
  }) = _Asset;
}
