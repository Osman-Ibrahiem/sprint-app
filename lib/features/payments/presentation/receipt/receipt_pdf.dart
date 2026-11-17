import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:sprint/features/payments/presentation/receipt/receipt_document.dart';

/// Makes the receipt's PDF. Injected through a provider so a test can make it
/// fail and see the text fallback.
typedef ReceiptPdfBuilder =
    Future<Uint8List> Function(ReceiptDocument document, {required bool rtl});

/// The PDF, made on the device with the bundled Cairo (Arabic shaping and
/// digits), the same rows as the screen (R9). No network, no plugin.
Future<Uint8List> buildReceiptPdf(
  ReceiptDocument document, {
  required bool rtl,
}) async {
  final regular = pw.Font.ttf(
    await rootBundle.load('assets/fonts/Cairo-Regular.ttf'),
  );
  final bold = pw.Font.ttf(
    await rootBundle.load('assets/fonts/Cairo-Bold.ttf'),
  );
  final direction = rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr;
  final pdf = pw.Document(
    title: document.title,
    theme: pw.ThemeData.withFont(base: regular, bold: bold),
  );

  pw.Widget cell(String text, {bool strong = false, bool ltr = false}) =>
      pw.Text(
        text,
        textDirection: ltr ? pw.TextDirection.ltr : direction,
        style: pw.TextStyle(font: strong ? bold : regular, fontSize: 12),
      );

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a5,
      textDirection: direction,
      margin: const pw.EdgeInsets.all(32),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Text(
            document.title,
            textDirection: direction,
            style: pw.TextStyle(font: bold, fontSize: 20),
          ),
          if (document.isTest) ...[
            pw.SizedBox(height: 6),
            cell(document.testTag),
          ],
          pw.SizedBox(height: 16),
          for (final (label, value) in document.rows)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [cell(label), cell(value, ltr: false)],
              ),
            ),
          pw.Divider(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              cell(document.totalLabel, strong: true),
              cell(document.total, strong: true),
            ],
          ),
        ],
      ),
    ),
  );
  return pdf.save();
}
