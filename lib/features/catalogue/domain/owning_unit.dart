import 'package:freezed_annotation/freezed_annotation.dart';

part 'owning_unit.freezed.dart';
part 'owning_unit.g.dart';

enum OwningUnitType { faculty, central }

/// A faculty or a central administration that owns facilities (BR-01).
@freezed
abstract class OwningUnit with _$OwningUnit {
  const factory OwningUnit({
    required String id,
    required String name,
    required OwningUnitType type,
  }) = _OwningUnit;

  factory OwningUnit.fromJson(Map<String, dynamic> json) =>
      _$OwningUnitFromJson(json);
}
