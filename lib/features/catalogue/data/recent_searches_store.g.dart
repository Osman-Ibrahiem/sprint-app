// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_searches_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(recentSearchesStore)
final recentSearchesStoreProvider = RecentSearchesStoreProvider._();

final class RecentSearchesStoreProvider
    extends
        $FunctionalProvider<
          RecentSearchesStore,
          RecentSearchesStore,
          RecentSearchesStore
        >
    with $Provider<RecentSearchesStore> {
  RecentSearchesStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentSearchesStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentSearchesStoreHash();

  @$internal
  @override
  $ProviderElement<RecentSearchesStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecentSearchesStore create(Ref ref) {
    return recentSearchesStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecentSearchesStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecentSearchesStore>(value),
    );
  }
}

String _$recentSearchesStoreHash() =>
    r'44ca19a47518907d0017f938f3cde43d1d558d37';
