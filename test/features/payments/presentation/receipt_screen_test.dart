import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' as rp;
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/data/in_memory_data_layer.dart';
import 'package:sprint/core/l10n/ltr_isolate.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/payments/presentation/receipt/receipt_document.dart';
import 'package:sprint/features/payments/presentation/receipt/receipt_providers.dart';
import 'package:sprint/features/payments/presentation/receipt/receipt_screen.dart';
import 'package:sprint/features/payments/domain/receipt.dart';

import '../../../helpers/pump_app.dart';

class _FakeSharer implements ReceiptSharer {
  final files = <String>[];
  final texts = <String>[];
  final copies = <String>[];
  bool textFails = false;

  @override
  Future<void> shareFile(Uint8List bytes, {required String name}) async {
    files.add('$name:${bytes.length}');
  }

  @override
  Future<void> shareText(String text) async {
    if (textFails) throw StateError('no share sheet');
    texts.add(text);
  }

  @override
  Future<void> copy(String text) async => copies.add(text);
}

/// The receipt screen, its PDF and the text share (US-6, FR-PAY-03, FR-025).
void main() {
  CairoTime.ensureInitialized();
  final seedNow = CairoTime.atWallClock(2026, 11, 14, 8);
  late InMemoryDataLayer layer;
  late Booking paid;
  late Booking free;
  late _FakeSharer sharer;

  Future<void> open(
    WidgetTester tester,
    Booking Function() pick, {
    List<rp.Override> extra = const [],
    Size size = const Size(400, 1000),
  }) async {
    layer = InMemoryDataLayer.create(
      clock: Clock(() => seedNow),
      paymentDelay: Duration.zero,
    );
    paid = layer.bookings.allBookings.firstWhere((b) =>
        b.userId == SeedIds.bookerInternal &&
        b.unitId == SeedIds.pool3 &&
        b.status == BookingStatus.confirmed);
    free = layer.bookings.allBookings.firstWhere((b) =>
        b.userId == SeedIds.bookerInternal &&
        b.unitId == SeedIds.hall1 &&
        b.status == BookingStatus.confirmed);
    sharer = _FakeSharer();
    await pumpSprintApp(tester, size: size, overrides: [
      dataLayerProvider.overrideWithValue(layer),
      appClockProvider.overrideWithValue(Clock(() => seedNow)),
      receiptSharerProvider.overrideWithValue(sharer),
      ...extra,
    ]);
    await containerOf(tester)
        .read(sessionProvider.notifier)
        .actAs(SeedIds.bookerInternal);
    await tester.pumpAndSettle();
    routerOf(tester).go(AppPaths.bookingReceipt(pick().id));
    await tester.pumpAndSettle();
  }

  testWidgets('every row, the total, the test tag, and codes left to right',
      (tester) async {
    await open(tester, () => paid);
    final p = (await layer.payments.latestPayment(paid.id))!;
    expect(find.text(ar.receiptTitle), findsWidgets);
    expect(find.byKey(ReceiptScreen.testTagKey), findsOneWidget);
    for (final label in [
      ar.receiptNumber,
      ar.receiptBookingCode,
      ar.receiptDate,
      ar.receiptUnit,
      ar.receiptTier,
      ar.receiptMethod,
      ar.receiptTotalPaid,
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    expect(find.text(p.receiptNumber!), findsOneWidget);
    expect(find.text(paid.code), findsOneWidget);
    expect(find.text(ar.receiptMethodCard('4242')), findsOneWidget);
    expect(find.text('20 ج.م'), findsOneWidget);
    // Walk 2026-11-18 D3: an Arabic price is not isolated left to right, or
    // it reads "ج.م 20".
    expect(
      find.ancestor(of: find.text('20 ج.م'), matching: find.byType(LtrIsolate)),
      findsNothing,
    );
    expect(
      find.ancestor(
        of: find.text(p.receiptNumber!),
        matching: find.byType(LtrIsolate),
      ),
      findsOneWidget,
    );
  });

  testWidgets('a free booking, or one without a succeeded payment, has no '
      'receipt', (tester) async {
    await open(tester, () => free);
    expect(find.byKey(ReceiptScreen.notFoundKey), findsOneWidget);
    expect(find.text(ar.receiptNotFoundTitle), findsOneWidget);
    expect(find.byKey(ReceiptScreen.saveKey), findsNothing);
  });

  testWidgets('"حفظ الإيصال PDF" makes non-empty PDF bytes and shares the file',
      (tester) async {
    await open(tester, () => paid);
    await tester.tap(find.byKey(ReceiptScreen.saveKey));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 600)),
    );
    await tester.pumpAndSettle();
    expect(sharer.files, hasLength(1));
    final p = (await layer.payments.latestPayment(paid.id))!;
    expect(sharer.files.single, startsWith('${p.receiptNumber}.pdf:'));
    final size = int.parse(sharer.files.single.split(':').last);
    expect(size, greaterThan(500));
    expect(sharer.texts, isEmpty);
  });

  testWidgets('a PDF that cannot be made falls back to the text and says so',
      (tester) async {
    await open(tester, () => paid, extra: [
      receiptPdfBuilderProvider.overrideWithValue(
        (doc, {required bool rtl}) async => throw StateError('no pdf'),
      ),
    ]);
    await tester.tap(find.byKey(ReceiptScreen.saveKey));
    await tester.pumpAndSettle();
    expect(sharer.files, isEmpty);
    expect(sharer.texts, hasLength(1));
    expect(find.text(ar.receiptPdfFailed), findsWidgets);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('"مشاركة الإيصال" shares the text; with no share sheet it '
      'copies and says "اتنسخ"', (tester) async {
    await open(tester, () => paid);
    await tester.tap(find.byKey(ReceiptScreen.shareKey));
    await tester.pumpAndSettle();
    expect(sharer.texts, hasLength(1));
    expect(sharer.copies, isEmpty);

    sharer.textFails = true;
    await tester.tap(find.byKey(ReceiptScreen.shareKey));
    await tester.pumpAndSettle();
    expect(sharer.copies, hasLength(1));
    expect(find.text(ar.ticketCopied), findsWidgets);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('the shared text has no more than the last four card digits',
      (tester) async {
    await open(tester, () => paid);
    await tester.tap(find.byKey(ReceiptScreen.shareKey));
    await tester.pumpAndSettle();
    final text = sharer.texts.single;
    expect(RegExp(r'\d{5,}').allMatches(text).where((m) {
      // Receipt numbers (RC-yyMMdd-NNNN) and codes have separators; a bare
      // run of five digits or more would be card data.
      return !text.substring(0, m.start).endsWith('-');
    }), isEmpty);
    expect(text, contains('4242'));
    expect(text, isNot(contains('4242 4242')));
    expect(text, contains(ar.receiptTotalPaid));
  });

  test('the document is built from the receipt, with only four digits', () {
    final r = Receipt(
      number: 'RC-261118-0001',
      bookingCode: 'SP-1234',
      paidAt: seedNow,
      facilityName: 'منشأة',
      unitName: 'وحدة',
      tier: PriceTier.internal,
      cardLast4: '4242',
      isTest: true,
      amount: 80,
    );
    final doc = ReceiptDocument.of(ar, const SprintFormat('ar'), r);
    expect(doc.rows.map((e) => e.$1), contains(ar.receiptMethod));
    expect(doc.toText(), contains('RC-261118-0001'));
    expect(doc.number, 'RC-261118-0001');
  });
}
