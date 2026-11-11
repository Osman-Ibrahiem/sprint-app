// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Local key-value storage, or null when it could not start. `main` overrides
/// this with the real instance; every reader tolerates null and failures
/// (FR-010, research R4). Only theme mode and locale are stored.

@ProviderFor(preferences)
final preferencesProvider = PreferencesProvider._();

/// Local key-value storage, or null when it could not start. `main` overrides
/// this with the real instance; every reader tolerates null and failures
/// (FR-010, research R4). Only theme mode and locale are stored.

final class PreferencesProvider
    extends
        $FunctionalProvider<
          SharedPreferences?,
          SharedPreferences?,
          SharedPreferences?
        >
    with $Provider<SharedPreferences?> {
  /// Local key-value storage, or null when it could not start. `main` overrides
  /// this with the real instance; every reader tolerates null and failures
  /// (FR-010, research R4). Only theme mode and locale are stored.
  PreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$preferencesHash();

  @$internal
  @override
  $ProviderElement<SharedPreferences?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SharedPreferences? create(Ref ref) {
    return preferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedPreferences? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedPreferences?>(value),
    );
  }
}

String _$preferencesHash() => r'0c2945491e1661d22ab0b339a0c6987ef4445a7d';
