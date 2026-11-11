import 'package:clock/clock.dart';
import 'package:sprint/core/seed/seed_data.dart';
import 'package:sprint/features/assets/data/in_memory_asset_repository.dart';
import 'package:sprint/features/attendance/data/in_memory_attendance_repository.dart';
import 'package:sprint/features/audit/data/in_memory_audit_log_repository.dart';
import 'package:sprint/features/booking/data/in_memory_availability_repository.dart';
import 'package:sprint/features/booking/data/in_memory_booking_repository.dart';
import 'package:sprint/features/catalogue/data/in_memory_catalogue_repository.dart';
import 'package:sprint/features/identity/data/in_memory_identity_repository.dart';
import 'package:sprint/features/notifications/data/in_memory_notification_repository.dart';
import 'package:sprint/features/payments/data/fake_payment_provider.dart';
import 'package:sprint/features/payments/data/in_memory_payment_repository.dart';
import 'package:sprint/features/settings/data/in_memory_settings_repository.dart';

/// Every in-memory repository over one seed, wired together. This is the one
/// place that knows the data is in memory; screens read the interfaces through
/// the providers in `data_providers.dart`, so a real backend replaces this
/// class and nothing else (FR-026).
class InMemoryDataLayer {
  InMemoryDataLayer._({
    required this.clock,
    required this.audit,
    required this.settings,
    required this.catalogue,
    required this.identity,
    required this.payments,
    required this.paymentProvider,
    required this.notifications,
    required this.attendance,
    required this.assets,
    required this.bookings,
    required this.availability,
  });

  factory InMemoryDataLayer.create({
    required Clock clock,
    SeedData? seed,
    Duration paymentDelay = const Duration(milliseconds: 600),
  }) {
    final data = seed ?? SeedData.build(clock.now());
    final audit = InMemoryAuditLogRepository(data.auditLog);
    final settings = InMemorySettingsRepository(
      audit: audit,
      seed: data.settings,
      clock: clock,
    );
    final catalogue = InMemoryCatalogueRepository(
      owningUnits: data.owningUnits,
      facilities: data.facilities,
      units: data.units,
      hours: data.hours,
      closures: data.closures,
      prices: data.prices,
      offers: data.offers,
      trainers: data.trainers,
      trainerAvailability: data.trainerAvailability,
    );
    final identity = InMemoryIdentityRepository(
      users: data.users,
      roleAssignments: data.roleAssignments,
      verifications: data.verifications,
    );
    final payments = InMemoryPaymentRepository(
      payments: data.payments,
      refunds: data.refunds,
    );
    final provider = FakePaymentProvider(delay: paymentDelay);
    final notifications = InMemoryNotificationRepository(data.notifications);
    final attendance = InMemoryAttendanceRepository(data.attendance);
    final assets = InMemoryAssetRepository(
      assets: data.assets,
      reports: data.damageReports,
    );
    final bookings = InMemoryBookingRepository(
      seed: data.bookings,
      catalogue: catalogue,
      settings: settings,
      identity: identity,
      payments: payments,
      notifications: notifications,
      attendance: attendance,
      paymentProvider: provider,
      paymentProviderName: provider.name,
      clock: clock,
    );
    settings.guard = bookings.settingChangeGuard;
    final availability = InMemoryAvailabilityRepository(
      catalogue: catalogue,
      settings: settings,
      bookingsForUnit: bookings.bookingsForUnit,
      clock: clock,
    );
    return InMemoryDataLayer._(
      clock: clock,
      audit: audit,
      settings: settings,
      catalogue: catalogue,
      identity: identity,
      payments: payments,
      paymentProvider: provider,
      notifications: notifications,
      attendance: attendance,
      assets: assets,
      bookings: bookings,
      availability: availability,
    );
  }

  final Clock clock;
  final InMemoryAuditLogRepository audit;
  final InMemorySettingsRepository settings;
  final InMemoryCatalogueRepository catalogue;
  final InMemoryIdentityRepository identity;
  final InMemoryPaymentRepository payments;
  final FakePaymentProvider paymentProvider;
  final InMemoryNotificationRepository notifications;
  final InMemoryAttendanceRepository attendance;
  final InMemoryAssetRepository assets;
  final InMemoryBookingRepository bookings;
  final InMemoryAvailabilityRepository availability;
}
