// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SessionNotifier)
final sessionProvider = SessionNotifierProvider._();

final class SessionNotifierProvider
    extends $AsyncNotifierProvider<SessionNotifier, Session> {
  SessionNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionNotifierHash();

  @$internal
  @override
  SessionNotifier create() => SessionNotifier();
}

String _$sessionNotifierHash() => r'9d76cb405f3d76a9b4e02e3f666353bffef5d033';

abstract class _$SessionNotifier extends $AsyncNotifier<Session> {
  FutureOr<Session> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Session>, Session>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Session>, Session>,
              AsyncValue<Session>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The session, as a guest until it has loaded.

@ProviderFor(currentSession)
final currentSessionProvider = CurrentSessionProvider._();

/// The session, as a guest until it has loaded.

final class CurrentSessionProvider
    extends $FunctionalProvider<Session, Session, Session>
    with $Provider<Session> {
  /// The session, as a guest until it has loaded.
  CurrentSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentSessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentSessionHash();

  @$internal
  @override
  $ProviderElement<Session> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Session create(Ref ref) {
    return currentSession(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Session value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Session>(value),
    );
  }
}

String _$currentSessionHash() => r'c9b84a91bc67dcce997c37f240888e17fec3d125';
