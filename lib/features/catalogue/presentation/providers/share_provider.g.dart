// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(shareAction)
final shareActionProvider = ShareActionProvider._();

final class ShareActionProvider
    extends $FunctionalProvider<ShareAction, ShareAction, ShareAction>
    with $Provider<ShareAction> {
  ShareActionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shareActionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shareActionHash();

  @$internal
  @override
  $ProviderElement<ShareAction> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ShareAction create(Ref ref) {
    return shareAction(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShareAction value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShareAction>(value),
    );
  }
}

String _$shareActionHash() => r'7af2e004b221db2d38cba56fa1552501b53b2078';
