import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sprint/features/payments/presentation/receipt/receipt_pdf.dart';

part 'receipt_providers.g.dart';

/// The seam tests override: the system share sheet (file or text) and the
/// clipboard. On the web `shareFile` downloads the file.
abstract class ReceiptSharer {
  Future<void> shareFile(Uint8List bytes, {required String name});
  Future<void> shareText(String text);
  Future<void> copy(String text);
}

class DefaultReceiptSharer implements ReceiptSharer {
  const DefaultReceiptSharer();

  @override
  Future<void> shareFile(Uint8List bytes, {required String name}) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(bytes, mimeType: 'application/pdf', name: name)],
        fileNameOverrides: [name],
      ),
    );
  }

  @override
  Future<void> shareText(String text) async {
    await SharePlus.instance.share(ShareParams(text: text));
  }

  @override
  Future<void> copy(String text) => Clipboard.setData(ClipboardData(text: text));
}

@Riverpod(keepAlive: true)
ReceiptSharer receiptSharer(Ref ref) => const DefaultReceiptSharer();

/// The PDF maker; a test overrides it to make generation fail.
@Riverpod(keepAlive: true)
ReceiptPdfBuilder receiptPdfBuilder(Ref ref) => buildReceiptPdf;
