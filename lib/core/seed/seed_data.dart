import 'package:sprint/core/seed/seed_bookings.dart';
import 'package:sprint/core/seed/seed_misc.dart';
import 'package:sprint/core/seed/seed_units.dart';
import 'package:sprint/core/seed/seed_users.dart';
import 'package:sprint/features/assets/domain/asset.dart';
import 'package:sprint/features/assets/domain/damage_report.dart';
import 'package:sprint/features/attendance/domain/attendance.dart';
import 'package:sprint/features/audit/domain/audit_log.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/catalogue/domain/bookable_unit.dart';
import 'package:sprint/features/catalogue/domain/closure.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/domain/offer.dart';
import 'package:sprint/features/catalogue/domain/operating_hours.dart';
import 'package:sprint/features/catalogue/domain/owning_unit.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/catalogue/domain/trainer.dart';
import 'package:sprint/features/catalogue/domain/trainer_availability.dart';
import 'package:sprint/features/identity/domain/role_assignment.dart';
import 'package:sprint/features/identity/domain/user.dart';
import 'package:sprint/features/identity/domain/verification.dart';
import 'package:sprint/features/notifications/domain/notification.dart';
import 'package:sprint/features/payments/domain/payment.dart';
import 'package:sprint/features/payments/domain/refund.dart';
import 'package:sprint/features/settings/domain/setting_definition.dart';

/// Placeholder data for P1 (FR-021, FR-022), built relative to [now] so there
/// are always past and future bookings. Resets on every start.
class SeedData {
  const SeedData({
    required this.owningUnits,
    required this.facilities,
    required this.units,
    required this.hours,
    required this.closures,
    required this.prices,
    required this.offers,
    required this.trainers,
    required this.trainerAvailability,
    required this.users,
    required this.verifications,
    required this.roleAssignments,
    required this.bookings,
    required this.payments,
    required this.refunds,
    required this.attendance,
    required this.notifications,
    required this.assets,
    required this.damageReports,
    required this.settings,
    required this.auditLog,
  });

  factory SeedData.build(DateTime now) {
    final set = seedBookings(now);
    return SeedData(
      owningUnits: seedOwningUnits,
      facilities: seedFacilities,
      units: seedUnits,
      hours: seedHours(),
      closures: seedClosures(now),
      prices: seedPrices,
      offers: seedOffers(now),
      trainers: seedTrainers,
      trainerAvailability: seedTrainerAvailability,
      users: seedUsers,
      verifications: seedVerifications(now),
      roleAssignments: seedRoleAssignments(),
      bookings: set.bookings,
      payments: set.payments,
      refunds: set.refunds,
      attendance: set.attendance,
      notifications: seedNotifications(now),
      assets: seedAssets,
      damageReports: seedDamageReports,
      settings: seedSettings(),
      auditLog: seedAuditLog(now),
    );
  }

  final List<OwningUnit> owningUnits;
  final List<Facility> facilities;
  final List<BookableUnit> units;
  final List<OperatingHours> hours;
  final List<Closure> closures;
  final List<Price> prices;
  final List<Offer> offers;
  final List<Trainer> trainers;
  final List<TrainerAvailability> trainerAvailability;
  final List<User> users;
  final List<Verification> verifications;
  final List<RoleAssignment> roleAssignments;
  final List<Booking> bookings;
  final List<Payment> payments;
  final List<Refund> refunds;
  final List<Attendance> attendance;
  final List<Notification> notifications;
  final List<Asset> assets;
  final List<DamageReport> damageReports;
  final List<SettingEntry> settings;
  final List<AuditLog> auditLog;
}
