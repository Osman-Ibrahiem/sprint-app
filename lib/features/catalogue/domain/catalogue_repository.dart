import 'package:sprint/features/catalogue/domain/bookable_unit.dart';
import 'package:sprint/features/catalogue/domain/closure.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/domain/offer.dart';
import 'package:sprint/features/catalogue/domain/operating_hours.dart';
import 'package:sprint/features/catalogue/domain/owning_unit.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/catalogue/domain/trainer.dart';
import 'package:sprint/features/catalogue/domain/trainer_availability.dart';

/// Read side of the catalogue. Unpublished facilities are hidden unless the
/// caller asks as a manager ([includeUnpublished]).
abstract interface class CatalogueRepository {
  Future<List<OwningUnit>> listOwningUnits();
  Future<List<Facility>> listFacilities({
    FacilityType? type,
    String? owningUnitId,
    bool? free,
    bool includeUnpublished = false,
  });
  Future<Facility?> getFacility(String id);
  Future<List<BookableUnit>> listUnits(String facilityId);
  Future<BookableUnit?> getUnit(String id);

  /// Hours of a unit or a facility.
  Future<List<OperatingHours>> hours(String ownerId);
  Future<List<Closure>> closures({String? facilityId, String? unitId});
  Future<List<Price>> prices(String unitId);
  Future<List<Trainer>> trainers(String facilityId);
  Future<List<TrainerAvailability>> trainerAvailability(
    String trainerId, {
    String? unitId,
  });
  Future<List<Offer>> offers({String? facilityId, String? unitId});
}
