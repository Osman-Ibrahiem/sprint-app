import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/adaptive/adaptive_back_button.dart';
import 'package:sprint/core/data/in_memory_data_layer.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/core/widgets/booking_ticket/booking_ticket.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/presentation/checkout/moment_placeholder.dart';
import 'package:sprint/features/booking/presentation/confirmed/booking_confirmed_screen.dart';
import 'package:sprint/features/booking/presentation/providers/checkout_providers.dart';
import 'package:flutter_riverpod/misc.dart' as rp;

import '../../../../helpers/pump_app.dart';
import '../schedule_harness.dart' show currentUri;

/// The confirmation ticket (US-12, BR-19, BR-39).
void main() {
  CairoTime.ensureInitialized();
  final seedNow = CairoTime.atWallClock(2026, 11, 14, 8);

  late InMemoryDataLayer layer;
  late Booking paid;
  late Booking free;

  Future<void> open(
    WidgetTester tester,
    Booking Function() pick, {
    DateTime? now,
    int? leadMinutes,
    Size size = const Size(400, 1600),
  }) async {
    layer = InMemoryDataLayer.create(
      clock: Clock(() => seedNow),
      paymentDelay: Duration.zero,
    );
    paid = layer.bookings.allBookings.firstWhere(
      (b) =>
          b.userId == SeedIds.bookerInternal &&
          b.unitId == SeedIds.pool3 &&
          b.status == BookingStatus.confirmed,
    );
    free = layer.bookings.allBookings.firstWhere(
      (b) =>
          b.userId == SeedIds.bookerInternal &&
          b.unitId == SeedIds.hall1 &&
          b.status == BookingStatus.confirmed,
    );
    final at = now ?? seedNow;
    await pumpSprintApp(
      tester,
      size: size,
      overrides: <rp.Override>[
        dataLayerProvider.overrideWithValue(layer),
        appClockProvider.overrideWithValue(Clock(() => at)),
        if (leadMinutes != null)
          checkoutSettingsProvider.overrideWith(
            (ref, id) async => CheckoutSettings(
              cancellationCutoffHours: 2,
              refundPercent: 50,
              reminderLeadMinutes: leadMinutes,
              isTestProvider: true,
            ),
          ),
      ],
    );
    await containerOf(tester)
        .read(sessionProvider.notifier)
        .actAs(SeedIds.bookerInternal);
    await tester.pumpAndSettle();
    routerOf(tester).go(AppPaths.bookingConfirmed(pick().id));
    await tester.pumpAndSettle();
  }

  testWidgets('a paid booking: moment, title, ticket, paid amount, receipt '
      'row; no way back to payment', (tester) async {
    await open(tester, () => paid);
    expect(find.byType(BookingConfirmedScreen), findsOneWidget);
    expect(find.byType(MomentPlaceholder), findsOneWidget);
    expect(find.text(ar.confirmedTitle), findsWidgets);
    expect(find.byType(BookingTicket), findsOneWidget);
    expect(find.byKey(BookingTicket.qrKey), findsOneWidget);
    expect(find.text(paid.code), findsOneWidget);
    expect(find.text(ar.statusConfirmed), findsWidgets);
    expect(find.text(ar.ticketPaid), findsOneWidget);
    expect(find.text('20 ج.م'), findsWidgets);
    expect(find.byKey(BookingConfirmedScreen.receiptKey), findsOneWidget);
    expect(find.byType(AdaptiveBackButton), findsNothing);
    // The booking is under "حجوزاتي"; payment is not in the stack.
    expect(currentUri(tester).path, AppPaths.bookingConfirmed(paid.id));
  });

  for (final (minutes, expected) in [(180, '3 ساعات'), (60, 'ساعة')]) {
    testWidgets('the reminder line comes from reminderLeadMinutes ($minutes)', (
      tester,
    ) async {
      await open(tester, () => paid, leadMinutes: minutes);
      final text = tester.widget<Text>(
        find.byKey(BookingConfirmedScreen.subtitleKey),
      );
      expect(text.data, ar.confirmedSubtitle(expected));
    });
  }

  testWidgets('the cancellation line before the cutoff names the time', (
    tester,
  ) async {
    await open(tester, () => paid);
    expect(find.textContaining('الإلغاء متاح لحد'), findsOneWidget);
    expect(find.text(ar.ticketCancelUnavailable), findsNothing);
  });

  testWidgets('after the cutoff the line says cancellation is not available', (
    tester,
  ) async {
    await open(
      tester,
      () => paid,
      now: paid.start.subtract(const Duration(hours: 1)),
    );
    expect(find.text(ar.ticketCancelUnavailable), findsOneWidget);
    expect(find.textContaining('الإلغاء متاح لحد'), findsNothing);
  });

  testWidgets('a free booking: the price row says مجاني and there is no '
      'receipt row', (tester) async {
    await open(tester, () => free);
    expect(find.byType(BookingTicket), findsOneWidget);
    expect(find.text(ar.bookingRowPrice), findsWidgets);
    expect(find.text(ar.bookingFree), findsWidgets);
    expect(find.text(ar.ticketPaid), findsNothing);
    expect(find.byKey(BookingConfirmedScreen.receiptKey), findsNothing);
  });

  // Walk 2026-11-18 D1: the ticket showed the stored UTC hour.
  testWidgets('the ticket shows the Cairo wall-clock time, not UTC', (
    tester,
  ) async {
    await open(tester, () => paid);
    String hm(DateTime t) => DateFormat('h:mm', 'en').format(t);
    final cairo = hm(CairoTime.toCairo(paid.start));
    final utc = hm(paid.start.toUtc());
    expect(cairo, isNot(utc));
    expect(find.textContaining(cairo), findsWidgets);
    expect(find.textContaining('$utc –'), findsNothing);
  });

  // Walk 2026-11-18 D4: a free booking can be cancelled up to the cutoff too.
  testWidgets('a free booking before the cutoff names the cancellation time', (
    tester,
  ) async {
    await open(tester, () => free);
    expect(find.textContaining('الإلغاء متاح لحد'), findsOneWidget);
    expect(find.text(ar.ticketCancelUnavailable), findsNothing);
  });

  testWidgets('copying the code says "اتنسخ" on screen', (tester) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async => null,
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await open(tester, () => paid);
    await tester.tap(find.byKey(BookingTicket.codeKey));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text(ar.ticketCopied), findsWidgets);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('"إيصال الدفع" opens the receipt and home goes home', (
    tester,
  ) async {
    await open(tester, () => paid);
    await tester.tap(find.byKey(BookingConfirmedScreen.receiptKey));
    await tester.pumpAndSettle();
    expect(currentUri(tester).path, AppPaths.bookingReceipt(paid.id));
    routerOf(tester).go(AppPaths.bookingConfirmed(paid.id));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(BookingConfirmedScreen.homeKey));
    await tester.pumpAndSettle();
    expect(currentPath(tester), AppPaths.home);
  });
}
