// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'destinations_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Which section has a screen. Override in tests to prove role-specific
/// destinations; features add their own as they arrive.

@ProviderFor(destinationRegistry)
final destinationRegistryProvider = DestinationRegistryProvider._();

/// Which section has a screen. Override in tests to prove role-specific
/// destinations; features add their own as they arrive.

final class DestinationRegistryProvider
    extends
        $FunctionalProvider<
          Map<AppSection, ShellDestination>,
          Map<AppSection, ShellDestination>,
          Map<AppSection, ShellDestination>
        >
    with $Provider<Map<AppSection, ShellDestination>> {
  /// Which section has a screen. Override in tests to prove role-specific
  /// destinations; features add their own as they arrive.
  DestinationRegistryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'destinationRegistryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$destinationRegistryHash();

  @$internal
  @override
  $ProviderElement<Map<AppSection, ShellDestination>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<AppSection, ShellDestination> create(Ref ref) {
    return destinationRegistry(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<AppSection, ShellDestination> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<AppSection, ShellDestination>>(
        value,
      ),
    );
  }
}

String _$destinationRegistryHash() =>
    r'd821bea68ab083ffb30ce26466e17fccc194713c';

/// The shell destinations for the current user's roles (FR-007, FR-031).

@ProviderFor(destinations)
final destinationsProvider = DestinationsProvider._();

/// The shell destinations for the current user's roles (FR-007, FR-031).

final class DestinationsProvider
    extends
        $FunctionalProvider<
          List<ShellDestination>,
          List<ShellDestination>,
          List<ShellDestination>
        >
    with $Provider<List<ShellDestination>> {
  /// The shell destinations for the current user's roles (FR-007, FR-031).
  DestinationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'destinationsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$destinationsHash();

  @$internal
  @override
  $ProviderElement<List<ShellDestination>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<ShellDestination> create(Ref ref) {
    return destinations(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ShellDestination> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ShellDestination>>(value),
    );
  }
}

String _$destinationsHash() => r'6e77d907b2ed0594c13461311a0e9e2561d9d80a';

/// A stable key of the destination paths, so the router is rebuilt only when
/// the set of destinations really changes (guest and booker share the same).

@ProviderFor(destinationPaths)
final destinationPathsProvider = DestinationPathsProvider._();

/// A stable key of the destination paths, so the router is rebuilt only when
/// the set of destinations really changes (guest and booker share the same).

final class DestinationPathsProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// A stable key of the destination paths, so the router is rebuilt only when
  /// the set of destinations really changes (guest and booker share the same).
  DestinationPathsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'destinationPathsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$destinationPathsHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return destinationPaths(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$destinationPathsHash() => r'7e473ca394817c70d8e62af391a5221e53c6eb11';
