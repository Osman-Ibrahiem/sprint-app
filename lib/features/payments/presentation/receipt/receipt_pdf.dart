import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:sprint/core/tokens/sprint_extras.dart';
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
        style: pw.TextStyle(font: strong ? bold : regular, fontSize: SprintExtras.receiptPdfBodySize),
      );

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a5,
      textDirection: direction,
      margin: pw.EdgeInsets.all(SprintExtras.receiptPdfMargin),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Text(
            document.title,
            textDirection: direction,
            style: pw.TextStyle(font: bold, fontSize: SprintExtras.receiptPdfTitleSize),
          ),
          if (document.isTest) ...[
            pw.SizedBox(height: SprintExtras.receiptPdfTagGap),
            cell(document.testTag),
          ],
          pw.SizedBox(height: SprintExtras.receiptPdfSectionGap),
          for (final (label, value) in document.rows)
            pw.Padding(
              padding: pw.EdgeInsets.only(bottom: SprintExtras.receiptPdfRowGap),
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
          if (document.refund != null) ...[
            pw.SizedBox(height: SprintExtras.receiptPdfRowGap),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                cell(document.refundLabel!),
                cell(document.refund!, ltr: false),
              ],
            ),
          ],
        ],
      ),
    ),
  );
  return pdf.save();
}
