import 'dart:async';

import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:sprint/core/data/demo_snapshot_store.dart';
import 'package:sprint/core/data/snapshot_codec.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/core/seed/seed_data.dart';
import 'package:sprint/features/assets/data/in_memory_asset_repository.dart';
import 'package:sprint/features/attendance/data/in_memory_attendance_repository.dart';
import 'package:sprint/features/audit/data/in_memory_audit_log_repository.dart';
import 'package:sprint/features/booking/data/in_memory_availability_repository.dart';
import 'package:sprint/features/booking/data/in_memory_booking_repository.dart';
import 'package:sprint/features/catalogue/data/in_memory_catalogue_repository.dart';
import 'package:sprint/features/auth/data/email_templates.dart';
import 'package:sprint/features/auth/data/in_memory_auth_repository.dart';
import 'package:sprint/features/auth/data/simulated_mailbox.dart';
import 'package:sprint/features/identity/data/in_memory_identity_repository.dart';
import 'package:sprint/features/notifications/data/in_memory_notification_repository.dart';
import 'package:sprint/features/payments/data/fake_gateway_controller.dart';
import 'package:sprint/features/payments/data/fake_payment_provider.dart';
import 'package:sprint/features/payments/data/in_memory_payment_repository.dart';
import 'package:sprint/features/payments/domain/payment.dart';
import 'package:sprint/features/settings/data/in_memory_settings_repository.dart';
import 'package:sprint/features/verification/data/in_memory_verification_repository.dart';

/// Every in-memory repository over one seed, wired together. This is the one
/// place that knows the data is in memory; screens read the interfaces through
/// the providers in `data_providers.dart`, so a real backend replaces this
/// class and nothing else (FR-026).
class InMemoryDataLayer {
  InMemoryDataLayer._({
    required this.clock,
    required this.seededAt,
    required this.audit,
    required this.settings,
    required this.catalogue,
    required this.identity,
    required this.auth,
    required this.mailbox,
    required this.photos,
    required this.verification,
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

    /// Offers are priced in only when on (decisions.md 2026-11-17); the
    /// offers feature turns it on.
    bool applyOffers = false,
    DateTime? seededAt,

    /// What the fake provider does when the page confirms (demo setting).
    FakeOutcome gatewayOutcome = const FakeOutcome.succeed(),
    String? currentUserId,
    Map<String, Object?>? authState,
    List<Object?>? mailboxEmails,
    EmailTemplate emailTemplate = defaultEmailTemplate,
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
    );
    final mailbox = SimulatedMailbox(
      template: emailTemplate,
      emails: mailboxEmails == null
          ? const []
          : SimulatedMailbox.emailsFromJson(mailboxEmails),
    );
    final auth = authState == null
        ? InMemoryAuthRepository(
            identity: identity,
            mailbox: mailbox,
            clock: clock,
            credentials: data.credentials,
            currentUserId: currentUserId,
          )
        : InMemoryAuthRepository.fromJson(
            {
              ...authState,
              'credentials': [for (final c in data.credentials) c.toJson()],
              'currentUserId': currentUserId,
            },
            identity: identity,
            mailbox: mailbox,
            clock: clock,
          );
    final photos = ForwardingPhotoStore();

    final payments = InMemoryPaymentRepository(
      payments: data.payments,
      refunds: data.refunds,
    );
    final provider = FakePaymentProvider(
      delay: paymentDelay,
      startAt: _highestSession(data.payments),
      controller: FakeGatewayController(
        baseDelay: paymentDelay,
        outcome: gatewayOutcome,
      ),
    );
    final notifications = InMemoryNotificationRepository(data.notifications);
    final verification = InMemoryVerificationRepository(
      verifications: data.verifications,
      identity: identity,
      settings: settings,
      audit: audit,
      notifications: notifications,
      snapshotStore: photos,
      sheetRows: data.sheetRows,
      batches: data.sheetBatches,
      owningUnits: data.owningUnits,
      clock: clock,
    );
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
      verification: verification,
      payments: payments,
      notifications: notifications,
      attendance: attendance,
      paymentProvider: provider,
      paymentProviderName: provider.name,
      clock: clock,
      applyOffers: applyOffers,
    );
    settings.guard = bookings.settingChangeGuard;
    // A payment still pending in a restored snapshot is watched again (FR-024).
    unawaited(bookings.resumePendingPayments());
    final availability = InMemoryAvailabilityRepository(
      catalogue: catalogue,
      settings: settings,
      bookingsForUnit: bookings.bookingsForUnit,
      clock: clock,
    );
    return InMemoryDataLayer._(
      clock: clock,
      seededAt: (seededAt ?? clock.now()).toUtc(),
      audit: audit,
      settings: settings,
      catalogue: catalogue,
      identity: identity,
      auth: auth,
      mailbox: mailbox,
      photos: photos,
      verification: verification,
      payments: payments,
      paymentProvider: provider,
      notifications: notifications,
      attendance: attendance,
      assets: assets,
      bookings: bookings,
      availability: availability,
    );
  }

  /// Rebuilds the layer from a saved [snapshot]. A missing, unparsable or
  /// other-`schemaVersion` snapshot starts from the seed instead (research R1).
  factory InMemoryDataLayer.fromSnapshot({
    required Clock clock,
    Map<String, Object?>? snapshot,
    Duration paymentDelay = const Duration(milliseconds: 600),
    EmailTemplate emailTemplate = defaultEmailTemplate,
  }) {
    if (snapshot != null) {
      try {
        if (snapshot['schemaVersion'] == schemaVersion) {
          final data = Map<String, Object?>.from(snapshot['data']! as Map);
          final session = data['session'] as Map?;
          return InMemoryDataLayer.create(
            clock: clock,
            seed: SnapshotCodec.decode(data),
            paymentDelay: paymentDelay,
            gatewayOutcome: data['gateway'] == null
                ? const FakeOutcome.succeed()
                : FakeOutcome.fromJson(
                    Map<String, Object?>.from(data['gateway']! as Map),
                  ),
            seededAt: DateTime.parse(snapshot['seededAt']! as String),
            currentUserId: session?['currentUserId'] as String?,
            authState: Map<String, Object?>.from(data['auth']! as Map),
            mailboxEmails: data['mailbox']! as List<Object?>,
            emailTemplate: emailTemplate,
          );
        }
      } on Object {
        // Corrupt snapshot: fall through to the seed.
      }
    }
    return InMemoryDataLayer.create(
      clock: clock,
      paymentDelay: paymentDelay,
      emailTemplate: emailTemplate,
    );
  }

  /// The only snapshot format this build reads.
  static const schemaVersion = 2;

  static int _highestSession(Iterable<Payment> payments) {
    var n = 0;
    for (final p in payments) {
      final m = RegExp(r'-pay-(\d+)$').firstMatch(p.providerRef);
      final k = m == null ? null : int.parse(m.group(1)!);
      if (k != null && k > n) n = k;
    }
    return n;
  }

  final Clock clock;

  /// When the seed this data grew from was built (UTC).
  final DateTime seededAt;
  final InMemoryAuditLogRepository audit;
  final InMemorySettingsRepository settings;
  final InMemoryCatalogueRepository catalogue;
  final InMemoryIdentityRepository identity;
  final InMemoryAuthRepository auth;

  /// The simulated mailbox auth sends code emails to (FR-023).
  final SimulatedMailbox mailbox;
  final ForwardingPhotoStore photos;
  final InMemoryVerificationRepository verification;
  final InMemoryPaymentRepository payments;
  final FakePaymentProvider paymentProvider;
  final InMemoryNotificationRepository notifications;
  final InMemoryAttendanceRepository attendance;
  final InMemoryAssetRepository assets;
  final InMemoryBookingRepository bookings;
  final InMemoryAvailabilityRepository availability;

  // ---------------------------------------------------------------- snapshot

  /// Every repository's lists by name, for [DemoSnapshotStore] (research R1).
  Map<String, Object?> toSnapshot() {
    final data = SeedData(
      owningUnits: catalogue.allOwningUnits,
      facilities: catalogue.allFacilities,
      units: catalogue.allUnits,
      hours: catalogue.allHours,
      closures: catalogue.allClosures,
      prices: catalogue.allPrices,
      offers: catalogue.allOffers,
      trainers: catalogue.allTrainers,
      trainerAvailability: catalogue.allTrainerAvailability,
      users: identity.allUsers,
      verifications: verification.allVerifications,
      roleAssignments: identity.allAssignments,
      bookings: bookings.allBookings,
      payments: payments.allPayments,
      refunds: payments.allRefunds,
      attendance: attendance.all,
      notifications: notifications.all,
      assets: assets.allAssets,
      damageReports: assets.allReports,
      settings: settings.entries,
      auditLog: audit.all,
      credentials: auth.allCredentials,
      sheetRows: verification.allSheetRows,
      sheetBatches: verification.allBatches,
    );
    return {
      'schemaVersion': schemaVersion,
      'seededAt': seededAt.toIso8601String(),
      'savedAt': clock.now().toUtc().toIso8601String(),
      'data': {
        ...SnapshotCodec.encode(data),
        'session': {'currentUserId': auth.signedInUserId},
        'auth': {
          for (final e in auth.toJson().entries)
            if (e.key != 'credentials' && e.key != 'currentUserId')
              e.key: e.value,
        },
        'mailbox': mailbox.toJson(),
        'gateway': paymentProvider.gateway.outcome.toJson(),
      },
    };
  }

  DemoSnapshotStore? _store;
  final List<StreamSubscription<void>> _subscriptions = [];
  Timer? _saveTimer;

  /// How long writes must pause before the snapshot is saved. Encoding runs
  /// on the UI isolate and covers every repository, so a burst of writes
  /// (typing a wrong code, a sheet upload) saves once, not once per write.
  static const Duration saveDebounce = Duration(milliseconds: 300);

  /// Saves the snapshot [saveDebounce] after the last of any repository's
  /// `changes`. Saving runs off the frame: it is scheduled on a timer, never
  /// inside the write that caused it.
  void attachStore(DemoSnapshotStore store) {
    detachStore();
    _store = store;
    photos.target = store;
    for (final changes in [
      audit.changes,
      settings.changes,
      catalogue.changes,
      identity.changes,
      auth.changes,
      mailbox.changes,
      verification.changes,
      payments.changes,
      notifications.changes,
      attendance.changes,
      assets.changes,
      bookings.changes,
    ]) {
      _subscriptions.add(changes.listen((_) => _scheduleSave()));
    }
  }

  void detachStore() {
    for (final s in _subscriptions) {
      unawaited(s.cancel());
    }
    _subscriptions.clear();
    _saveTimer?.cancel();
    _saveTimer = null;
    _store = null;
    photos.target = null;
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(saveDebounce, () {
      _saveTimer = null;
      final store = _store;
      if (store != null) unawaited(store.save(toSnapshot()));
    });
  }

  /// Stops saving and clears the saved snapshot and photos; theme and language
  /// stay. The caller then builds a fresh layer from the seed ("إرجاع الداتا
  /// التجريبية").
  Future<void> reset() async {
    final store = _store;
    detachStore();
    await store?.clear();
  }
}

/// Photos for the verification repository, forwarded to whichever snapshot
/// store is attached (the repository is built before the store is attached).
/// Without a store they live in memory.
class ForwardingPhotoStore implements DemoSnapshotStore {
  DemoSnapshotStore? target;
  final Map<String, Uint8List> _memory = {};

  /// Photos the seed points at (the placeholder ID card). `main` loads them
  /// from the bundled asset; tests leave it empty or pass bytes. Used only
  /// when no saved photo exists under the id, so nothing is written to storage.
  Map<String, Uint8List> seedPhotos = const {};

  @override
  Future<Map<String, Object?>?> load() async => null;

  @override
  Future<void> save(Map<String, Object?> snapshot) async {}

  @override
  Future<Uint8List?> loadPhoto(String id) async =>
      await target?.loadPhoto(id) ?? _memory[id] ?? seedPhotos[id];

  @override
  Future<Result<void>> savePhoto(String id, Uint8List bytes) async {
    final t = target;
    if (t != null) return t.savePhoto(id, bytes);
    _memory[id] = bytes;
    return const Ok(null);
  }

  @override
  Future<void> clear() async => _memory.clear();
}
