// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_permission_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notificationPermissionStore)
final notificationPermissionStoreProvider =
    NotificationPermissionStoreProvider._();

final class NotificationPermissionStoreProvider
    extends
        $FunctionalProvider<
          NotificationPermissionStore,
          NotificationPermissionStore,
          NotificationPermissionStore
        >
    with $Provider<NotificationPermissionStore> {
  NotificationPermissionStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPermissionStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationPermissionStoreHash();

  @$internal
  @override
  $ProviderElement<NotificationPermissionStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationPermissionStore create(Ref ref) {
    return notificationPermissionStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationPermissionStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationPermissionStore>(value),
    );
  }
}

String _$notificationPermissionStoreHash() =>
    r'7e55ac54cba1d230a1d0ea39a62ef3c4ea2b0666';
