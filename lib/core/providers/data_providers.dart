import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprint/core/data/in_memory_data_layer.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/features/assets/domain/asset_repository.dart';
import 'package:sprint/features/attendance/domain/attendance_repository.dart';
import 'package:sprint/features/audit/domain/audit_log_repository.dart';
import 'package:sprint/features/booking/domain/availability_repository.dart';
import 'package:sprint/features/booking/domain/booking_repository.dart';
import 'package:sprint/features/catalogue/domain/catalogue_repository.dart';
import 'package:sprint/features/identity/domain/identity_repository.dart';
import 'package:sprint/features/notifications/domain/notification_repository.dart';
import 'package:sprint/features/payments/domain/payment_provider.dart';
import 'package:sprint/features/payments/domain/payment_repository.dart';
import 'package:sprint/features/settings/domain/settings_repository.dart';

part 'data_providers.g.dart';

// The single place to swap the in-memory layer for a real backend (FR-026).
// Screens only ever read the interfaces below.

@Riverpod(keepAlive: true)
InMemoryDataLayer dataLayer(Ref ref) =>
    InMemoryDataLayer.create(clock: ref.watch(appClockProvider));

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) =>
    ref.watch(dataLayerProvider).settings;

@Riverpod(keepAlive: true)
CatalogueRepository catalogueRepository(Ref ref) =>
    ref.watch(dataLayerProvider).catalogue;

@Riverpod(keepAlive: true)
IdentityRepository identityRepository(Ref ref) =>
    ref.watch(dataLayerProvider).identity;

@Riverpod(keepAlive: true)
BookingRepository bookingRepository(Ref ref) =>
    ref.watch(dataLayerProvider).bookings;

@Riverpod(keepAlive: true)
AvailabilityRepository availabilityRepository(Ref ref) =>
    ref.watch(dataLayerProvider).availability;

@Riverpod(keepAlive: true)
PaymentRepository paymentRepository(Ref ref) =>
    ref.watch(dataLayerProvider).payments;

/// The `paymentProvider` setting picks the gateway (BR-29). `fake` and
/// `sandbox` both resolve to the fake in P1; booking code only sees the
/// interface.
@Riverpod(keepAlive: true)
PaymentProvider paymentProvider(Ref ref) =>
    ref.watch(dataLayerProvider).paymentProvider;

@Riverpod(keepAlive: true)
NotificationRepository notificationRepository(Ref ref) =>
    ref.watch(dataLayerProvider).notifications;

@Riverpod(keepAlive: true)
AttendanceRepository attendanceRepository(Ref ref) =>
    ref.watch(dataLayerProvider).attendance;

@Riverpod(keepAlive: true)
AssetRepository assetRepository(Ref ref) => ref.watch(dataLayerProvider).assets;

@Riverpod(keepAlive: true)
AuditLogRepository auditLogRepository(Ref ref) =>
    ref.watch(dataLayerProvider).audit;
