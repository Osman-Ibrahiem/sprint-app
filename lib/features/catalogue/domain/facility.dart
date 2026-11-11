import 'package:freezed_annotation/freezed_annotation.dart';

part 'facility.freezed.dart';

enum FacilityType { swimming, football, gym, tennis, hall, training }

/// `isFree` and `requiresTrainer` define the three booking paths (BR-08,
/// BR-09, BR-10). A free facility has no prices.
@freezed
abstract class Facility with _$Facility {
  const factory Facility({
    required String id,
    required String owningUnitId,
    required String name,
    required FacilityType type,
    required String description,
    @Default(<String>[]) List<String> photos,
    required String location,
    required bool isFree,
    required bool requiresTrainer,
    @Default(true) bool isPublished,
  }) = _Facility;
}
