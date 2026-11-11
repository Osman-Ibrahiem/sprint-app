import 'package:freezed_annotation/freezed_annotation.dart';

part 'bookable_unit.freezed.dart';

/// A lane, pitch or hall. Its booking mode, capacity and max participants are
/// unit-scope settings, never fields here (constitution III).
@freezed
abstract class BookableUnit with _$BookableUnit {
  const factory BookableUnit({
    required String id,
    required String facilityId,
    required String name,
    @Default(true) bool isActive,
  }) = _BookableUnit;
}
