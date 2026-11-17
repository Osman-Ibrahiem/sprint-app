import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/app/shell/placeholders/no_access_screen.dart';
import 'package:sprint/core/data/in_memory_data_layer.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/booking_repository.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';
import 'package:sprint/features/booking/presentation/checkout/checkout_screen.dart';
import 'package:sprint/features/booking/presentation/confirmed/booking_confirmed_screen.dart';
import 'package:sprint/features/payments/domain/payment.dart';
import 'package:sprint/features/payments/presentation/receipt/receipt_screen.dart';

import '../../helpers/pump_app.dart';

/// Routes of feature 006 (contracts/routes.md).
void main() {
  CairoTime.ensureInitialized();
  final now = CairoTime.atWallClock(2026, 11, 14, 8);
  final pool = SeedIds.poolFacility;
  final selection = ScheduleSelection(
    day: DateTime(2026, 11, 19),
    unitId: SeedIds.pool2,
    startMinutes: 18 * 60,
    endMinutes: 19 * 60,
  );

  late InMemoryDataLayer layer;
  late Booking booking;

  Future<void> open(WidgetTester tester, {String? signInAs}) async {
    layer = InMemoryDataLayer.create(
      clock: Clock(() => now),
      paymentDelay: Duration.zero,
    );
    final created = await layer.bookings.create(BookingRequest(
      userId: SeedIds.bookerInternal,
      unitId: SeedIds.futsal2,
      start: CairoTime.atWallClock(2026, 11, 16, 18),
      end: CairoTime.atWallClock(2026, 11, 16, 19),
    ));
    booking = (created as Ok<Booking>).value;
    await pumpSprintApp(tester, overrides: [
      dataLayerProvider.overrideWithValue(layer),
      appClockProvider.overrideWithValue(Clock(() => now)),
    ]);
    if (signInAs != null) {
      await containerOf(tester).read(sessionProvider.notifier).actAs(signInAs);
      await tester.pumpAndSettle();
    }
  }

  Uri uri(WidgetTester tester) =>
      routerOf(tester).routerDelegate.currentConfiguration.uri;

  testWidgets('paths are built, never typed by hand', (tester) async {
    expect(AppPaths.bookingCheckoutFor(pool, 'bk-1'),
        '/facilities/$pool/schedule/checkout/bk-1');
    expect(AppPaths.fakeGateway('FAKE-pay-1'), '/pay/sandbox/FAKE-pay-1');
    expect(AppPaths.bookingConfirmed('bk-1'), '/bookings/bk-1/confirmed');
    expect(AppPaths.bookingReceipt('bk-1'), '/bookings/bk-1/receipt');
  });

  testWidgets('the owner reaches checkout, the ticket and the receipt', (
    tester,
  ) async {
    await open(tester, signInAs: SeedIds.bookerInternal);

    routerOf(tester)
        .go(AppPaths.bookingCheckoutFor(booking.facilityId, booking.id));
    await tester.pumpAndSettle();
    expect(find.byType(CheckoutScreen), findsOneWidget);

    // A confirmed booking of the same person (seed): its ticket and receipt.
    final paid = layer.bookings.allBookings.firstWhere((b) =>
        b.userId == SeedIds.bookerInternal &&
        b.unitId == SeedIds.pool3 &&
        b.status == BookingStatus.confirmed);
    routerOf(tester).go(AppPaths.bookingConfirmed(paid.id));
    await tester.pumpAndSettle();
    expect(find.byType(BookingConfirmedScreen), findsOneWidget);
    expect(currentPath(tester), AppPaths.bookingConfirmed(paid.id));

    routerOf(tester).go(AppPaths.bookingReceipt(paid.id));
    await tester.pumpAndSettle();
    expect(find.byType(ReceiptScreen), findsOneWidget);
  });

  testWidgets('the ticket route of a booking still on hold goes to its '
      'checkout', (tester) async {
    await open(tester, signInAs: SeedIds.bookerInternal);
    routerOf(tester).go(AppPaths.bookingConfirmed(booking.id));
    await tester.pumpAndSettle();
    expect(currentPath(tester),
        AppPaths.bookingCheckoutFor(booking.facilityId, booking.id));
  });

  testWidgets('the old checkout address redirects to the summary, keeping '
      'the selection', (tester) async {
    await open(tester, signInAs: SeedIds.bookerInternal);
    routerOf(tester).go(AppPaths.bookingCheckout(pool, selection));
    await tester.pumpAndSettle();
    final u = uri(tester);
    expect(u.path, '/facilities/$pool/schedule/summary');
    expect(u.queryParameters, selection.toQuery());
  });

  testWidgets('the old done address redirects to the ticket', (tester) async {
    await open(tester, signInAs: SeedIds.bookerInternal);
    final paid = layer.bookings.allBookings.firstWhere((b) =>
        b.userId == SeedIds.bookerInternal &&
        b.unitId == SeedIds.pool3 &&
        b.status == BookingStatus.confirmed);
    routerOf(tester).go(AppPaths.bookingDone(pool, paid.id));
    await tester.pumpAndSettle();
    expect(currentPath(tester), AppPaths.bookingConfirmed(paid.id));
  });

  for (final path in [
    '/facilities/f-pool/schedule/checkout/bk-1',
    '/bookings/bk-1/confirmed',
    '/bookings/bk-1/receipt',
    '/pay/sandbox/FAKE-pay-1',
  ]) {
    testWidgets('a guest opening $path is sent to sign in and back', (
      tester,
    ) async {
      await open(tester);
      routerOf(tester).go(path);
      await tester.pumpAndSettle();
      final u = uri(tester);
      expect(u.path, AppPaths.signIn);
      expect(u.queryParameters['from'], path);
    });
  }

  testWidgets("another person's booking shows NoAccessScreen", (tester) async {
    await open(tester, signInAs: SeedIds.bookerExternal);
    for (final path in [
      AppPaths.bookingCheckoutFor(booking.facilityId, booking.id),
      AppPaths.bookingConfirmed(booking.id),
      AppPaths.bookingReceipt(booking.id),
    ]) {
      routerOf(tester).go(path);
      await tester.pumpAndSettle();
      expect(find.byType(NoAccessScreen), findsOneWidget, reason: path);
      expect(currentPath(tester), Uri.parse(path).path);
    }
  });

  testWidgets('an unknown provider session goes home and starts no payment', (
    tester,
  ) async {
    await open(tester, signInAs: SeedIds.bookerInternal);
    routerOf(tester).go(AppPaths.fakeGateway('FAKE-pay-404'));
    await tester.pumpAndSettle();
    expect(currentPath(tester), AppPaths.home);
    expect(await layer.payments.payments(booking.id), isEmpty);
  });

  testWidgets("a session the fake forgot goes to its booking's checkout", (
    tester,
  ) async {
    await open(tester, signInAs: SeedIds.bookerInternal);
    // A payment row from before a restart: the fake no longer knows it.
    await layer.payments.savePayment(Payment(
      id: 'pay-FAKE-pay-77',
      bookingId: booking.id,
      provider: 'FAKE',
      providerRef: 'FAKE-pay-77',
      amount: booking.priceAtBooking,
      status: PaymentStatus.pending,
      startedAt: now,
      owningUnitId: SeedIds.ouCentral,
    ));
    routerOf(tester).go(AppPaths.fakeGateway('FAKE-pay-77'));
    await tester.pumpAndSettle();
    expect(currentPath(tester),
        AppPaths.bookingCheckoutFor(booking.facilityId, booking.id));
    expect(await layer.payments.payments(booking.id), hasLength(1));
  });
}
