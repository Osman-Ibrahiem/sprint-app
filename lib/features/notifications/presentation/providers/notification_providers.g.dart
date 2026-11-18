// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The signed-in person's notifications, newest first, reloaded on every
/// write to the repository. Empty for a guest.

@ProviderFor(notificationsList)
final notificationsListProvider = NotificationsListProvider._();

/// The signed-in person's notifications, newest first, reloaded on every
/// write to the repository. Empty for a guest.

final class NotificationsListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Notification>>,
          List<Notification>,
          FutureOr<List<Notification>>
        >
    with
        $FutureModifier<List<Notification>>,
        $FutureProvider<List<Notification>> {
  /// The signed-in person's notifications, newest first, reloaded on every
  /// write to the repository. Empty for a guest.
  NotificationsListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsListHash();

  @$internal
  @override
  $FutureProviderElement<List<Notification>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Notification>> create(Ref ref) {
    return notificationsList(ref);
  }
}

String _$notificationsListHash() => r'3ef5d1394480a490617d1a9ea06e16b3c184b043';

/// Records not read yet; null while loading (the bell shows no badge then).
/// The "cancelled by me" record is written already read, so it never counts.

@ProviderFor(unreadCount)
final unreadCountProvider = UnreadCountProvider._();

/// Records not read yet; null while loading (the bell shows no badge then).
/// The "cancelled by me" record is written already read, so it never counts.

final class UnreadCountProvider extends $FunctionalProvider<int?, int?, int?>
    with $Provider<int?> {
  /// Records not read yet; null while loading (the bell shows no badge then).
  /// The "cancelled by me" record is written already read, so it never counts.
  UnreadCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unreadCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unreadCountHash();

  @$internal
  @override
  $ProviderElement<int?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int? create(Ref ref) {
    return unreadCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }
}

String _$unreadCountHash() => r'd3c39d8fd83a399b7fee2416ff3e4fa31fc294b6';
