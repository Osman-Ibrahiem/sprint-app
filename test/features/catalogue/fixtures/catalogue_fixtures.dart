import 'package:sprint/core/seed/seed_catalogue_extras.dart';
import 'package:sprint/core/seed/seed_data.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/features/catalogue/domain/closure.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/domain/operating_hours.dart';

/// Catalogue test fixtures. They never edit the shared seed: they copy it and
/// replace one list, so the Foundation's tests keep the data they expect (R6).
SeedData catalogueSeed(
  DateTime now, {
  List<OperatingHours> extraHours = const [],
  List<Closure> extraClosures = const [],
  List<Facility> extraFacilities = const [],
}) {
  final base = SeedData.build(now);
  return SeedData(
    owningUnits: base.owningUnits,
    facilities: [...base.facilities, ...extraFacilities],
    units: base.units,
    hours: [...base.hours, ...extraHours],
    closures: [...base.closures, ...extraClosures],
    prices: base.prices,
    offers: base.offers,
    trainers: base.trainers,
    trainerAvailability: base.trainerAvailability,
    users: base.users,
    verifications: base.verifications,
    roleAssignments: base.roleAssignments,
    bookings: base.bookings,
    payments: base.payments,
    refunds: base.refunds,
    attendance: base.attendance,
    notifications: base.notifications,
    assets: base.assets,
    damageReports: base.damageReports,
    settings: base.settings,
    auditLog: base.auditLog,
  );
}

/// A facility-scope closure covering the whole of today, for the screens that
/// need a "closed today / closed now" state.
Closure closedToday(String facilityId, DateTime now) {
  final today = CairoTime.toCairo(now);
  return Closure(
    id: 'cl-test-closed-now',
    scope: ClosureScope.facility,
    scopeId: facilityId,
    from: CairoTime.atWallClock(today.year, today.month, today.day),
    to: CairoTime.atWallClock(today.year, today.month, today.day + 1),
    reason: 'صيانة',
  );
}

/// The seed plus a lane-6-only evening hours override, so the details page can
/// show a unit that differs from its facility. The live seed keeps facility
/// hours for lane 6 because the Foundation's booking tests book it in the
/// morning (see evidence.md).
SeedData laneSixSeed(DateTime now) => catalogueSeed(
      now,
      extraHours: seedCatalogueExtraHours(),
    );

/// The seed with the tennis facility closed for the whole day.
SeedData closedTodaySeed(DateTime now) => catalogueSeed(
      now,
      extraClosures: [closedToday(SeedIds.tennisFacility, now)],
    );
