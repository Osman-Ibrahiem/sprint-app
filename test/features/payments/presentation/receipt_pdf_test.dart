import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/payments/domain/receipt.dart';
import 'package:sprint/features/payments/presentation/receipt/receipt_document.dart';
import 'package:sprint/features/payments/presentation/receipt/receipt_pdf.dart';

import '../../../helpers/pump_app.dart';

/// The on-device receipt PDF (R9, FR-PAY-03).
void main() {
  CairoTime.ensureInitialized();
  setUpAll(() async {
    await initializeDateFormatting('ar');
    await initializeDateFormatting('en');
  });
  final receipt = Receipt(
    number: 'RC-261118-0001',
    bookingCode: 'SP-1234',
    paidAt: CairoTime.atWallClock(2026, 11, 18, 9),
    facilityName: 'حمام السباحة الأوليمبي',
    unitName: 'حارة 3',
    tier: PriceTier.internal,
    cardLast4: '4242',
    isTest: true,
    amount: 80,
  );

  testWidgets('the bytes are a PDF with Cairo embedded, in both languages',
      (tester) async {
    for (final rtl in [true, false]) {
      final doc = ReceiptDocument.of(ar, SprintFormat(rtl ? 'ar' : 'en'), receipt);
      final bytes = await tester.runAsync(() => buildReceiptPdf(doc, rtl: rtl));
      expect(bytes, isNotNull);
      expect(bytes!.length, greaterThan(2000), reason: 'rtl=$rtl');
      expect(ascii.decode(bytes.sublist(0, 5)), '%PDF-');
      expect(latin1.decode(bytes, allowInvalid: true), contains('Cairo'));
    }
  });
}
