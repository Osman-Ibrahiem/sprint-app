// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(receiptSharer)
final receiptSharerProvider = ReceiptSharerProvider._();

final class ReceiptSharerProvider
    extends $FunctionalProvider<ReceiptSharer, ReceiptSharer, ReceiptSharer>
    with $Provider<ReceiptSharer> {
  ReceiptSharerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'receiptSharerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$receiptSharerHash();

  @$internal
  @override
  $ProviderElement<ReceiptSharer> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReceiptSharer create(Ref ref) {
    return receiptSharer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReceiptSharer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReceiptSharer>(value),
    );
  }
}

String _$receiptSharerHash() => r'84ac61acc287d717fe9e4a6b7ec18042bc5f8da5';

/// The PDF maker; a test overrides it to make generation fail.

@ProviderFor(receiptPdfBuilder)
final receiptPdfBuilderProvider = ReceiptPdfBuilderProvider._();

/// The PDF maker; a test overrides it to make generation fail.

final class ReceiptPdfBuilderProvider
    extends
        $FunctionalProvider<
          ReceiptPdfBuilder,
          ReceiptPdfBuilder,
          ReceiptPdfBuilder
        >
    with $Provider<ReceiptPdfBuilder> {
  /// The PDF maker; a test overrides it to make generation fail.
  ReceiptPdfBuilderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'receiptPdfBuilderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$receiptPdfBuilderHash();

  @$internal
  @override
  $ProviderElement<ReceiptPdfBuilder> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReceiptPdfBuilder create(Ref ref) {
    return receiptPdfBuilder(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReceiptPdfBuilder value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReceiptPdfBuilder>(value),
    );
  }
}

String _$receiptPdfBuilderHash() => r'7c41144de137d5c34bd7bf3d468888e5def35113';
