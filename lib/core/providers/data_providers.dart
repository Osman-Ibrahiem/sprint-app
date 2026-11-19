import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprint/core/data/demo_snapshot_store.dart';
import 'package:sprint/core/data/in_memory_data_layer.dart';
import 'package:sprint/core/data/in_memory_snapshot_store.dart';
import 'package:sprint/core/l10n/locale_notifier.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/features/assets/domain/asset_repository.dart';
import 'package:sprint/features/attendance/domain/attendance_repository.dart';
import 'package:sprint/features/audit/domain/audit_log_repository.dart';
import 'package:sprint/features/auth/data/email_templates.dart';
import 'package:sprint/features/auth/data/simulated_mailbox.dart';
import 'package:sprint/features/auth/domain/auth_repository.dart';
import 'package:sprint/features/auth/domain/email_outbox.dart';
import 'package:sprint/features/booking/domain/availability_repository.dart';
import 'package:sprint/features/booking/domain/booking_repository.dart';
import 'package:sprint/features/catalogue/data/recent_searches_store.dart';
import 'package:sprint/features/catalogue/domain/catalogue_repository.dart';
import 'package:sprint/features/demo/demo_flags.dart';
import 'package:sprint/features/identity/domain/identity_repository.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';
import 'package:sprint/features/notifications/data/notification_permission_store.dart';
import 'package:sprint/features/notifications/domain/notification_repository.dart';
import 'package:sprint/features/payments/data/fake_gateway_controller.dart';
import 'package:sprint/features/payments/domain/payment_provider.dart';
import 'package:sprint/features/payments/domain/payment_repository.dart';
import 'package:sprint/features/settings/domain/settings_repository.dart';
import 'package:sprint/features/verification/domain/verification_repository.dart';

part 'data_providers.g.dart';

// The single place to swap the in-memory layer for a real backend (FR-026).
// Screens only ever read the interfaces below.

/// Where the demo data is saved. `main` overrides it with the preferences
/// store; tests get an in-memory one (research R1).
@Riverpod(keepAlive: true)
DemoSnapshotStore snapshotStore(Ref ref) => InMemorySnapshotStore();

/// The snapshot read from the store before the app starts, or null for a
/// fresh seed. `main` overrides it; resetting the demo data clears it.
@Riverpod(keepAlive: true)
class InitialSnapshot extends _$InitialSnapshot {
  @override
  Map<String, Object?>? build() => null;

  void clear() => state = null;
}

/// Photos the seed verification requests point at, by id. `main` loads the
/// bundled placeholder ID card; tests get none unless they override it.
@Riverpod(keepAlive: true)
Map<String, Uint8List> seedPhotos(Ref ref) => const {};

/// How code emails are worded: the localised template, in the app's language
/// at the moment the email is sent (no `BuildContext` needed). Override it to
/// change the wording; the data layer calls it at send time, so changing it
/// needs no rebuild of the layer.
@Riverpod(keepAlive: true)
EmailTemplate emailTemplate(Ref ref) =>
    (purpose, code) => localizedEmailTemplate(
      lookupAppLocalizations(ref.read(localeProvider)),
      purpose,
      code,
    );

/// Loads the layer from the snapshot (or the seed) and saves it again once per
/// event-loop turn after any write.
@Riverpod(keepAlive: true)
InMemoryDataLayer dataLayer(Ref ref) {
  final layer =
      InMemoryDataLayer.fromSnapshot(
          clock: ref.watch(appClockProvider),
          snapshot: ref.watch(initialSnapshotProvider),
          emailTemplate: (purpose, code) =>
              ref.read(emailTemplateProvider)(purpose, code),
        )
        ..attachStore(ref.watch(snapshotStoreProvider))
        ..photos.seedPhotos = ref.watch(seedPhotosProvider);
  ref.onDispose(layer.detachStore);
  return layer;
}

/// "إرجاع الداتا التجريبية": clears the saved snapshot and photos (theme and
/// language stay) and rebuilds every repository from the seed.
@Riverpod(keepAlive: true)
Future<void> Function() resetDemoData(Ref ref) => () async {
  await Future.wait([
    ref.read(recentSearchesStoreProvider).clear(),
    ref.read(notificationPermissionStoreProvider).clear(),
  ]);
  await ref.read(dataLayerProvider).reset();
  ref.read(initialSnapshotProvider.notifier).clear();
  ref.invalidate(dataLayerProvider);
};

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
AuthRepository authRepository(Ref ref) => ref.watch(dataLayerProvider).auth;

/// Where code emails go (FR-023). P1 keeps them in the simulated mailbox.
@Riverpod(keepAlive: true)
EmailOutbox emailOutbox(Ref ref) => ref.watch(dataLayerProvider).mailbox;

/// The mailbox the demo screens read codes from; null when demo tools are
/// hidden (`HIDE_DEMO_TOOLS`), so a real build never exposes codes.
@Riverpod(keepAlive: true)
SimulatedMailbox? simulatedMailbox(Ref ref) =>
    demoToolsEnabled ? ref.watch(dataLayerProvider).mailbox : null;

@Riverpod(keepAlive: true)
VerificationRepository verificationRepository(Ref ref) =>
    ref.watch(dataLayerProvider).verification;

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

/// The fake provider's remote control: the simulated provider page and the
/// `/demo` payment section drive the fake through it. Nothing else may read
/// it (BR-28, FR-009); booking code never sees it.
@Riverpod(keepAlive: true)
FakeGatewayController fakeGateway(Ref ref) =>
    ref.watch(dataLayerProvider).paymentProvider.gateway;

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
