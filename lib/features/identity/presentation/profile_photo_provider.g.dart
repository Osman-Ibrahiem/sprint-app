// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_photo_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(profilePhotoStore)
final profilePhotoStoreProvider = ProfilePhotoStoreProvider._();

final class ProfilePhotoStoreProvider
    extends
        $FunctionalProvider<
          ProfilePhotoStore,
          ProfilePhotoStore,
          ProfilePhotoStore
        >
    with $Provider<ProfilePhotoStore> {
  ProfilePhotoStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profilePhotoStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profilePhotoStoreHash();

  @$internal
  @override
  $ProviderElement<ProfilePhotoStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProfilePhotoStore create(Ref ref) {
    return profilePhotoStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfilePhotoStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfilePhotoStore>(value),
    );
  }
}

String _$profilePhotoStoreHash() => r'fccc45668f3a3ba780b096699cad9f75c0e8b6af';

/// The stored photo of [userId], or null for the initial.

@ProviderFor(profilePhoto)
final profilePhotoProvider = ProfilePhotoFamily._();

/// The stored photo of [userId], or null for the initial.

final class ProfilePhotoProvider
    extends
        $FunctionalProvider<
          AsyncValue<Uint8List?>,
          Uint8List?,
          FutureOr<Uint8List?>
        >
    with $FutureModifier<Uint8List?>, $FutureProvider<Uint8List?> {
  /// The stored photo of [userId], or null for the initial.
  ProfilePhotoProvider._({
    required ProfilePhotoFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'profilePhotoProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profilePhotoHash();

  @override
  String toString() {
    return r'profilePhotoProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Uint8List?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Uint8List?> create(Ref ref) {
    final argument = this.argument as String;
    return profilePhoto(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfilePhotoProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profilePhotoHash() => r'99e018e30945e60104fd4e9668a8d322b7569d9d';

/// The stored photo of [userId], or null for the initial.

final class ProfilePhotoFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Uint8List?>, String> {
  ProfilePhotoFamily._()
    : super(
        retry: null,
        name: r'profilePhotoProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The stored photo of [userId], or null for the initial.

  ProfilePhotoProvider call(String userId) =>
      ProfilePhotoProvider._(argument: userId, from: this);

  @override
  String toString() => r'profilePhotoProvider';
}
