// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Where the demo data is saved. `main` overrides it with the preferences
/// store; tests get an in-memory one (research R1).

@ProviderFor(snapshotStore)
final snapshotStoreProvider = SnapshotStoreProvider._();

/// Where the demo data is saved. `main` overrides it with the preferences
/// store; tests get an in-memory one (research R1).

final class SnapshotStoreProvider
    extends
        $FunctionalProvider<
          DemoSnapshotStore,
          DemoSnapshotStore,
          DemoSnapshotStore
        >
    with $Provider<DemoSnapshotStore> {
  /// Where the demo data is saved. `main` overrides it with the preferences
  /// store; tests get an in-memory one (research R1).
  SnapshotStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'snapshotStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$snapshotStoreHash();

  @$internal
  @override
  $ProviderElement<DemoSnapshotStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DemoSnapshotStore create(Ref ref) {
    return snapshotStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DemoSnapshotStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DemoSnapshotStore>(value),
    );
  }
}

String _$snapshotStoreHash() => r'7210480c45db6b006b2056ef34590734c2fdb66a';

/// The snapshot read from the store before the app starts, or null for a
/// fresh seed. `main` overrides it; resetting the demo data clears it.

@ProviderFor(InitialSnapshot)
final initialSnapshotProvider = InitialSnapshotProvider._();

/// The snapshot read from the store before the app starts, or null for a
/// fresh seed. `main` overrides it; resetting the demo data clears it.
final class InitialSnapshotProvider
    extends $NotifierProvider<InitialSnapshot, Map<String, Object?>?> {
  /// The snapshot read from the store before the app starts, or null for a
  /// fresh seed. `main` overrides it; resetting the demo data clears it.
  InitialSnapshotProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'initialSnapshotProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$initialSnapshotHash();

  @$internal
  @override
  InitialSnapshot create() => InitialSnapshot();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, Object?>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, Object?>?>(value),
    );
  }
}

String _$initialSnapshotHash() => r'c779c36e6d9461074c8c734d9057d9bf35084f69';

/// The snapshot read from the store before the app starts, or null for a
/// fresh seed. `main` overrides it; resetting the demo data clears it.

abstract class _$InitialSnapshot extends $Notifier<Map<String, Object?>?> {
  Map<String, Object?>? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Map<String, Object?>?, Map<String, Object?>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, Object?>?, Map<String, Object?>?>,
              Map<String, Object?>?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// How code emails are worded: the localised template, in the app's language
/// at the moment the email is sent (no `BuildContext` needed). Override it to
/// change the wording; the data layer calls it at send time, so changing it
/// needs no rebuild of the layer.

@ProviderFor(emailTemplate)
final emailTemplateProvider = EmailTemplateProvider._();

/// How code emails are worded: the localised template, in the app's language
/// at the moment the email is sent (no `BuildContext` needed). Override it to
/// change the wording; the data layer calls it at send time, so changing it
/// needs no rebuild of the layer.

final class EmailTemplateProvider
    extends $FunctionalProvider<EmailTemplate, EmailTemplate, EmailTemplate>
    with $Provider<EmailTemplate> {
  /// How code emails are worded: the localised template, in the app's language
  /// at the moment the email is sent (no `BuildContext` needed). Override it to
  /// change the wording; the data layer calls it at send time, so changing it
  /// needs no rebuild of the layer.
  EmailTemplateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'emailTemplateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$emailTemplateHash();

  @$internal
  @override
  $ProviderElement<EmailTemplate> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EmailTemplate create(Ref ref) {
    return emailTemplate(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EmailTemplate value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EmailTemplate>(value),
    );
  }
}

String _$emailTemplateHash() => r'b5cd9ca14e0521f4e202cdf22add67b93913535c';

/// Loads the layer from the snapshot (or the seed) and saves it again once per
/// event-loop turn after any write.

@ProviderFor(dataLayer)
final dataLayerProvider = DataLayerProvider._();

/// Loads the layer from the snapshot (or the seed) and saves it again once per
/// event-loop turn after any write.

final class DataLayerProvider
    extends
        $FunctionalProvider<
          InMemoryDataLayer,
          InMemoryDataLayer,
          InMemoryDataLayer
        >
    with $Provider<InMemoryDataLayer> {
  /// Loads the layer from the snapshot (or the seed) and saves it again once per
  /// event-loop turn after any write.
  DataLayerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dataLayerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dataLayerHash();

  @$internal
  @override
  $ProviderElement<InMemoryDataLayer> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InMemoryDataLayer create(Ref ref) {
    return dataLayer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InMemoryDataLayer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InMemoryDataLayer>(value),
    );
  }
}

String _$dataLayerHash() => r'955245d4a6ed63baa23c1f980524b0c24fc543ce';

/// "إرجاع الداتا التجريبية": clears the saved snapshot and photos (theme and
/// language stay) and rebuilds every repository from the seed.

@ProviderFor(resetDemoData)
final resetDemoDataProvider = ResetDemoDataProvider._();

/// "إرجاع الداتا التجريبية": clears the saved snapshot and photos (theme and
/// language stay) and rebuilds every repository from the seed.

final class ResetDemoDataProvider
    extends
        $FunctionalProvider<
          Future<void> Function(),
          Future<void> Function(),
          Future<void> Function()
        >
    with $Provider<Future<void> Function()> {
  /// "إرجاع الداتا التجريبية": clears the saved snapshot and photos (theme and
  /// language stay) and rebuilds every repository from the seed.
  ResetDemoDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'resetDemoDataProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$resetDemoDataHash();

  @$internal
  @override
  $ProviderElement<Future<void> Function()> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Future<void> Function() create(Ref ref) {
    return resetDemoData(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Future<void> Function() value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Future<void> Function()>(value),
    );
  }
}

String _$resetDemoDataHash() => r'fee7cf15fbe3877a9d8a9eb00df0ce3b934085fa';

@ProviderFor(settingsRepository)
final settingsRepositoryProvider = SettingsRepositoryProvider._();

final class SettingsRepositoryProvider
    extends
        $FunctionalProvider<
          SettingsRepository,
          SettingsRepository,
          SettingsRepository
        >
    with $Provider<SettingsRepository> {
  SettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SettingsRepository create(Ref ref) {
    return settingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsRepository>(value),
    );
  }
}

String _$settingsRepositoryHash() =>
    r'f9c80bd3da0683064ba0722e657659513afe2227';

@ProviderFor(catalogueRepository)
final catalogueRepositoryProvider = CatalogueRepositoryProvider._();

final class CatalogueRepositoryProvider
    extends
        $FunctionalProvider<
          CatalogueRepository,
          CatalogueRepository,
          CatalogueRepository
        >
    with $Provider<CatalogueRepository> {
  CatalogueRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catalogueRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catalogueRepositoryHash();

  @$internal
  @override
  $ProviderElement<CatalogueRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CatalogueRepository create(Ref ref) {
    return catalogueRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CatalogueRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CatalogueRepository>(value),
    );
  }
}

String _$catalogueRepositoryHash() =>
    r'11621d63bc51e76c8525504d51634825304fa0ba';

@ProviderFor(identityRepository)
final identityRepositoryProvider = IdentityRepositoryProvider._();

final class IdentityRepositoryProvider
    extends
        $FunctionalProvider<
          IdentityRepository,
          IdentityRepository,
          IdentityRepository
        >
    with $Provider<IdentityRepository> {
  IdentityRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'identityRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$identityRepositoryHash();

  @$internal
  @override
  $ProviderElement<IdentityRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IdentityRepository create(Ref ref) {
    return identityRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IdentityRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IdentityRepository>(value),
    );
  }
}

String _$identityRepositoryHash() =>
    r'c0f2f633796cc6b6389b546ce7b5cc5c30c57cae';

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'ed41290a1232dbc1d005d1ffafe31aee60e06950';

/// Where code emails go (FR-023). P1 keeps them in the simulated mailbox.

@ProviderFor(emailOutbox)
final emailOutboxProvider = EmailOutboxProvider._();

/// Where code emails go (FR-023). P1 keeps them in the simulated mailbox.

final class EmailOutboxProvider
    extends $FunctionalProvider<EmailOutbox, EmailOutbox, EmailOutbox>
    with $Provider<EmailOutbox> {
  /// Where code emails go (FR-023). P1 keeps them in the simulated mailbox.
  EmailOutboxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'emailOutboxProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$emailOutboxHash();

  @$internal
  @override
  $ProviderElement<EmailOutbox> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EmailOutbox create(Ref ref) {
    return emailOutbox(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EmailOutbox value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EmailOutbox>(value),
    );
  }
}

String _$emailOutboxHash() => r'd2ec51597a6eeb18b5d34e894dff05c74df1826a';

/// The mailbox the demo screens read codes from; null when demo tools are
/// hidden (`HIDE_DEMO_TOOLS`), so a real build never exposes codes.

@ProviderFor(simulatedMailbox)
final simulatedMailboxProvider = SimulatedMailboxProvider._();

/// The mailbox the demo screens read codes from; null when demo tools are
/// hidden (`HIDE_DEMO_TOOLS`), so a real build never exposes codes.

final class SimulatedMailboxProvider
    extends
        $FunctionalProvider<
          SimulatedMailbox?,
          SimulatedMailbox?,
          SimulatedMailbox?
        >
    with $Provider<SimulatedMailbox?> {
  /// The mailbox the demo screens read codes from; null when demo tools are
  /// hidden (`HIDE_DEMO_TOOLS`), so a real build never exposes codes.
  SimulatedMailboxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'simulatedMailboxProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$simulatedMailboxHash();

  @$internal
  @override
  $ProviderElement<SimulatedMailbox?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SimulatedMailbox? create(Ref ref) {
    return simulatedMailbox(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SimulatedMailbox? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SimulatedMailbox?>(value),
    );
  }
}

String _$simulatedMailboxHash() => r'0a9e2a269a472217ae999eaab9d4806d46da9f51';

@ProviderFor(verificationRepository)
final verificationRepositoryProvider = VerificationRepositoryProvider._();

final class VerificationRepositoryProvider
    extends
        $FunctionalProvider<
          VerificationRepository,
          VerificationRepository,
          VerificationRepository
        >
    with $Provider<VerificationRepository> {
  VerificationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'verificationRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$verificationRepositoryHash();

  @$internal
  @override
  $ProviderElement<VerificationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VerificationRepository create(Ref ref) {
    return verificationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VerificationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VerificationRepository>(value),
    );
  }
}

String _$verificationRepositoryHash() =>
    r'378575ff0cbc7a6acc9408d7777a8e3299ac7408';

@ProviderFor(bookingRepository)
final bookingRepositoryProvider = BookingRepositoryProvider._();

final class BookingRepositoryProvider
    extends
        $FunctionalProvider<
          BookingRepository,
          BookingRepository,
          BookingRepository
        >
    with $Provider<BookingRepository> {
  BookingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookingRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookingRepositoryHash();

  @$internal
  @override
  $ProviderElement<BookingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BookingRepository create(Ref ref) {
    return bookingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BookingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BookingRepository>(value),
    );
  }
}

String _$bookingRepositoryHash() => r'be462e1e5d31d9e74e4d80bcc903f2eb106db4fa';

@ProviderFor(availabilityRepository)
final availabilityRepositoryProvider = AvailabilityRepositoryProvider._();

final class AvailabilityRepositoryProvider
    extends
        $FunctionalProvider<
          AvailabilityRepository,
          AvailabilityRepository,
          AvailabilityRepository
        >
    with $Provider<AvailabilityRepository> {
  AvailabilityRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'availabilityRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$availabilityRepositoryHash();

  @$internal
  @override
  $ProviderElement<AvailabilityRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AvailabilityRepository create(Ref ref) {
    return availabilityRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AvailabilityRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AvailabilityRepository>(value),
    );
  }
}

String _$availabilityRepositoryHash() =>
    r'519b99cd51b5fce935ae5c565e31b7904531cbcb';

@ProviderFor(paymentRepository)
final paymentRepositoryProvider = PaymentRepositoryProvider._();

final class PaymentRepositoryProvider
    extends
        $FunctionalProvider<
          PaymentRepository,
          PaymentRepository,
          PaymentRepository
        >
    with $Provider<PaymentRepository> {
  PaymentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentRepositoryHash();

  @$internal
  @override
  $ProviderElement<PaymentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PaymentRepository create(Ref ref) {
    return paymentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaymentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaymentRepository>(value),
    );
  }
}

String _$paymentRepositoryHash() => r'e929ff32a2afc0ff54a14d5d3a6cb94a2f580d3f';

/// The `paymentProvider` setting picks the gateway (BR-29). `fake` and
/// `sandbox` both resolve to the fake in P1; booking code only sees the
/// interface.

@ProviderFor(paymentProvider)
final paymentProviderProvider = PaymentProviderProvider._();

/// The `paymentProvider` setting picks the gateway (BR-29). `fake` and
/// `sandbox` both resolve to the fake in P1; booking code only sees the
/// interface.

final class PaymentProviderProvider
    extends
        $FunctionalProvider<PaymentProvider, PaymentProvider, PaymentProvider>
    with $Provider<PaymentProvider> {
  /// The `paymentProvider` setting picks the gateway (BR-29). `fake` and
  /// `sandbox` both resolve to the fake in P1; booking code only sees the
  /// interface.
  PaymentProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentProviderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentProviderHash();

  @$internal
  @override
  $ProviderElement<PaymentProvider> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PaymentProvider create(Ref ref) {
    return paymentProvider(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaymentProvider value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaymentProvider>(value),
    );
  }
}

String _$paymentProviderHash() => r'e1e38267a3a48c214c7ffa4663d6234d63e8472b';

@ProviderFor(notificationRepository)
final notificationRepositoryProvider = NotificationRepositoryProvider._();

final class NotificationRepositoryProvider
    extends
        $FunctionalProvider<
          NotificationRepository,
          NotificationRepository,
          NotificationRepository
        >
    with $Provider<NotificationRepository> {
  NotificationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationRepositoryHash();

  @$internal
  @override
  $ProviderElement<NotificationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationRepository create(Ref ref) {
    return notificationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationRepository>(value),
    );
  }
}

String _$notificationRepositoryHash() =>
    r'0baa3814758001b1033496426bafd7f040a502b9';

@ProviderFor(attendanceRepository)
final attendanceRepositoryProvider = AttendanceRepositoryProvider._();

final class AttendanceRepositoryProvider
    extends
        $FunctionalProvider<
          AttendanceRepository,
          AttendanceRepository,
          AttendanceRepository
        >
    with $Provider<AttendanceRepository> {
  AttendanceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attendanceRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attendanceRepositoryHash();

  @$internal
  @override
  $ProviderElement<AttendanceRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AttendanceRepository create(Ref ref) {
    return attendanceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AttendanceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AttendanceRepository>(value),
    );
  }
}

String _$attendanceRepositoryHash() =>
    r'22e4332f5c4f31dd298333f826757d0804ab0b8d';

@ProviderFor(assetRepository)
final assetRepositoryProvider = AssetRepositoryProvider._();

final class AssetRepositoryProvider
    extends
        $FunctionalProvider<AssetRepository, AssetRepository, AssetRepository>
    with $Provider<AssetRepository> {
  AssetRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assetRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assetRepositoryHash();

  @$internal
  @override
  $ProviderElement<AssetRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AssetRepository create(Ref ref) {
    return assetRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AssetRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AssetRepository>(value),
    );
  }
}

String _$assetRepositoryHash() => r'ebb6ce4d1ad8062e6bd956403016b06845916297';

@ProviderFor(auditLogRepository)
final auditLogRepositoryProvider = AuditLogRepositoryProvider._();

final class AuditLogRepositoryProvider
    extends
        $FunctionalProvider<
          AuditLogRepository,
          AuditLogRepository,
          AuditLogRepository
        >
    with $Provider<AuditLogRepository> {
  AuditLogRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'auditLogRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$auditLogRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuditLogRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AuditLogRepository create(Ref ref) {
    return auditLogRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuditLogRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuditLogRepository>(value),
    );
  }
}

String _$auditLogRepositoryHash() =>
    r'a6345514b7880df1f5ca74959a55e2c30679d485';
