import 'package:sprint/features/catalogue/domain/bookable_unit.dart';
import 'package:sprint/features/catalogue/domain/catalogue_repository.dart';
import 'package:sprint/features/catalogue/domain/closure.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/domain/offer.dart';
import 'package:sprint/features/catalogue/domain/operating_hours.dart';
import 'package:sprint/features/catalogue/domain/owning_unit.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/catalogue/domain/trainer.dart';
import 'package:sprint/features/catalogue/domain/trainer_availability.dart';

class InMemoryCatalogueRepository implements CatalogueRepository {
  InMemoryCatalogueRepository({
    required Iterable<OwningUnit> owningUnits,
    required Iterable<Facility> facilities,
    required Iterable<BookableUnit> units,
    required Iterable<OperatingHours> hours,
    required Iterable<Closure> closures,
    required Iterable<Price> prices,
    required Iterable<Offer> offers,
    required Iterable<Trainer> trainers,
    required Iterable<TrainerAvailability> trainerAvailability,
  })  : _owningUnits = [...owningUnits],
        _facilities = [...facilities],
        _units = [...units],
        _hours = [...hours],
        _closures = [...closures],
        _prices = [...prices],
        _offers = [...offers],
        _trainers = [...trainers],
        _availability = [...trainerAvailability];

  final List<OwningUnit> _owningUnits;
  final List<Facility> _facilities;
  final List<BookableUnit> _units;
  final List<OperatingHours> _hours;
  final List<Closure> _closures;
  final List<Price> _prices;
  final List<Offer> _offers;
  final List<Trainer> _trainers;
  final List<TrainerAvailability> _availability;

  @override
  Future<List<OwningUnit>> listOwningUnits() async => List.unmodifiable(_owningUnits);

  @override
  Future<List<Facility>> listFacilities({
    FacilityType? type,
    String? owningUnitId,
    bool? free,
    bool includeUnpublished = false,
  }) async =>
      _facilities
          .where((f) =>
              (includeUnpublished || f.isPublished) &&
              (type == null || f.type == type) &&
              (owningUnitId == null || f.owningUnitId == owningUnitId) &&
              (free == null || f.isFree == free))
          .toList();

  @override
  Future<Facility?> getFacility(String id) async {
    for (final f in _facilities) {
      if (f.id == id) return f;
    }
    return null;
  }

  @override
  Future<List<BookableUnit>> listUnits(String facilityId) async =>
      _units.where((u) => u.facilityId == facilityId).toList();

  @override
  Future<BookableUnit?> getUnit(String id) async {
    for (final u in _units) {
      if (u.id == id) return u;
    }
    return null;
  }

  @override
  Future<List<OperatingHours>> hours(String ownerId) async =>
      _hours.where((h) => h.ownerId == ownerId).toList();

  @override
  Future<List<Closure>> closures({String? facilityId, String? unitId}) async =>
      _closures
          .where((c) =>
              (c.scope == ClosureScope.facility && c.scopeId == facilityId) ||
              (c.scope == ClosureScope.unit && c.scopeId == unitId))
          .toList();

  @override
  Future<List<Price>> prices(String unitId) async =>
      _prices.where((p) => p.unitId == unitId).toList();

  @override
  Future<List<Trainer>> trainers(String facilityId) async =>
      _trainers.where((t) => t.facilityIds.contains(facilityId)).toList();

  @override
  Future<List<TrainerAvailability>> trainerAvailability(
    String trainerId, {
    String? unitId,
  }) async =>
      _availability
          .where((a) =>
              a.trainerId == trainerId && (unitId == null || a.unitId == unitId))
          .toList();

  @override
  Future<List<Offer>> offers({String? facilityId, String? unitId}) async =>
      _offers
          .where((o) => switch (o.scope) {
                OfferScope.university => true,
                OfferScope.facility => o.scopeId == facilityId,
                OfferScope.unit => o.scopeId == unitId,
              })
          .toList();

  /// Seeding hook for tests and the demo; not part of the interface.
  Future<void> upsertPrice(Price price) async {
    _prices.removeWhere((p) => p.unitId == price.unitId && p.tier == price.tier);
    _prices.add(price);
  }
}
