import 'package:clock/clock.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/features/booking/domain/availability_repository.dart';
import 'package:sprint/features/booking/domain/availability_service.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/slot.dart';
import 'package:sprint/features/booking/domain/unit_settings.dart';
import 'package:sprint/features/catalogue/domain/catalogue_repository.dart';
import 'package:sprint/features/settings/domain/settings_repository.dart';

class InMemoryAvailabilityRepository implements AvailabilityRepository {
  InMemoryAvailabilityRepository({
    required this.catalogue,
    required this.settings,
    required this.bookingsForUnit,
    required this.clock,
    this.service = const AvailabilityService(),
  });

  final CatalogueRepository catalogue;
  final SettingsRepository settings;
  final Future<List<Booking>> Function(String unitId) bookingsForUnit;
  final Clock clock;
  final AvailabilityService service;

  @override
  Future<List<Slot>> slots(
    String unitId,
    DateTime from,
    DateTime to, {
    String? trainerId,
  }) async {
    final unit = await catalogue.getUnit(unitId);
    if (unit == null) return const [];
    final facility = await catalogue.getFacility(unit.facilityId);
    if (facility == null || !facility.isPublished) return const [];

    final trainers = await catalogue.trainers(facility.id);
    final trainer = trainerId == null
        ? null
        : trainers.where((t) => t.id == trainerId).firstOrNull;
    // A trainer facility needs its trainer chosen first (BR-09).
    if (facility.requiresTrainer && trainer == null) return const [];

    final f = CairoTime.toCairo(from);
    final t = CairoTime.toCairo(to);
    return service.slots(
      facility: facility,
      unit: unit,
      hours: [
        ...await catalogue.hours(unit.id),
        ...await catalogue.hours(facility.id),
      ],
      closures: await catalogue.closures(facilityId: facility.id, unitId: unit.id),
      bookings: await bookingsForUnit(unit.id),
      settings: await UnitSettings.resolve(
        settings,
        unitId: unit.id,
        facilityId: facility.id,
      ),
      now: clock.now(),
      fromDay: DateTime(f.year, f.month, f.day),
      toDay: DateTime(t.year, t.month, t.day),
      trainer: trainer,
      trainerAvailability: trainer == null
          ? const []
          : await catalogue.trainerAvailability(trainer.id, unitId: unit.id),
    );
  }
}
