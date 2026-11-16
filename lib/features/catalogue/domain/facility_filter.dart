import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';

part 'facility_filter.freezed.dart';

/// The facility list's filters. A null field means "all"; the fields combine
/// with AND and map one to one onto
/// `CatalogueRepository.listFacilities(type:, owningUnitId:, free:)`
/// (FR-008, FR-009).
@freezed
abstract class FacilityFilter with _$FacilityFilter {
  const FacilityFilter._();

  const factory FacilityFilter({
    FacilityType? type,
    String? owningUnitId,
    bool? free,
  }) = _FacilityFilter;

  /// Any field is set.
  bool get isActive => type != null || owningUnitId != null || free != null;

  /// How many fields are set; drives the "clear all" action.
  int get activeCount =>
      (type != null ? 1 : 0) +
      (owningUnitId != null ? 1 : 0) +
      (free != null ? 1 : 0);
}
