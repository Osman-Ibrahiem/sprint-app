import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/data/in_memory_data_layer.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/booking_repository.dart';
import 'package:sprint/features/booking/domain/checkout_view.dart';
import 'package:sprint/features/booking/domain/unit_settings.dart';
import 'package:sprint/features/booking/presentation/providers/checkout_providers.dart';
import 'package:sprint/features/payments/data/fake_gateway_controller.dart';
import 'package:sprint/features/payments/domain/payment_provider.dart';

/// The checkout providers (contracts/repositories.md, "Riverpod providers").
void main() {
  CairoTime.ensureInitialized();
  var now = CairoTime.atWallClock(2026, 11, 14, 8);
  late InMemoryDataLayer layer;
  late ProviderContainer c;

  Future<void> settle([int ms = 60]) =>
      Future<void>.delayed(Duration(milliseconds: ms));

  setUp(() async {
    now = CairoTime.atWallClock(2026, 11, 14, 8);
    layer = InMemoryDataLayer.create(
      clock: Clock(() => now),
      paymentDelay: Duration.zero,
    );
    c = ProviderContainer(overrides: [
      dataLayerProvider.overrideWithValue(layer),
      appClockProvider.overrideWithValue(Clock(() => now)),
    ]);
    addTearDown(c.dispose);
    await c.read(sessionProvider.notifier).actAs(SeedIds.bookerInternal);
  });

  Future<Booking> create() async {
    final r = await layer.bookings.create(BookingRequest(
      userId: SeedIds.bookerInternal,
      unitId: SeedIds.futsal2,
      start: CairoTime.atWallClock(2026, 11, 16, 18),
      end: CairoTime.atWallClock(2026, 11, 16, 19),
    ));
    return (r as Ok<Booking>).value;
  }

  /// Keeps an auto-dispose provider alive for the test.
  void hold<T>(ProviderListenable<T> p) => c.listen<T>(p, (_, _) {});

  test('access: owner allowed, someone else and an unknown id refused',
      () async {
    final b = await create();
    expect(await c.read(checkoutAccessProvider(b.id).future),
        CheckoutAccess.allowed);
    expect(await c.read(checkoutAccessProvider('nope').future),
        CheckoutAccess.notFound);
    await c.read(sessionProvider.notifier).actAs(SeedIds.bookerExternal);
    expect(await c.read(checkoutAccessProvider(b.id).future),
        CheckoutAccess.notOwner);
  });

  test('the view follows the booking and its payment', () async {
    final b = await create();
    hold(checkoutViewProvider(b.id));
    await settle(20);
    expect(c.read(checkoutViewProvider(b.id)), CheckoutView.holding);

    final s = (await layer.bookings.startPayment(b.id, b.userId) as Ok<PaymentSession>).value;
    await settle(20);
    expect(c.read(checkoutViewProvider(b.id)), CheckoutView.processing);

    layer.paymentProvider.gateway.confirm(s.id, cardLast4: '4242');
    await settle();
    expect(c.read(checkoutViewProvider(b.id)), CheckoutView.confirmed);
  });

  test('processing turns into awaiting after the wait, counted from the '
      'later of the start and the return', () async {
    final b = await create();
    hold(checkoutViewProvider(b.id));
    await layer.bookings.startPayment(b.id, b.userId);
    await settle(20);
    now = now.add(CheckoutTimings.processingWait);
    c.invalidate(checkoutTickProvider);
    await settle(20);
    expect(c.read(checkoutViewProvider(b.id)), CheckoutView.awaiting);
    // Back from the provider page now: processing again.
    c.read(checkoutReturnedAtProvider(b.id).notifier).mark(now);
    expect(c.read(checkoutViewProvider(b.id)), CheckoutView.processing);
  });

  test('the countdown comes from holdExpiresAt and the clock, and at zero '
      'the repository applies the Hold rule', () async {
    final b = await create();
    hold(holdCountdownProvider(b.id));
    await settle(20);
    expect(c.read(holdCountdownProvider(b.id)), const Duration(minutes: 10));
    now = now.add(const Duration(minutes: 4));
    c.invalidate(checkoutTickProvider);
    await settle(20);
    expect(c.read(holdCountdownProvider(b.id)), const Duration(minutes: 6));

    now = now.add(const Duration(minutes: 6));
    c.invalidate(checkoutTickProvider);
    await settle(20);
    // Zero, or null once the repository has already expired the booking.
    expect(c.read(holdCountdownProvider(b.id)), anyOf(Duration.zero, isNull));
    await settle(80);
    expect(((await layer.bookings.get(b.id)) as Ok<Booking>).value.status,
        BookingStatus.expired);
  });

  test('settings: cutoff, refund percent, lead and the test-mode flag come '
      'from the settings', () async {
    final b = await create();
    final s = await c.read(checkoutSettingsProvider(b.id).future);
    final cfg = await UnitSettings.resolve(layer.settings,
        unitId: b.unitId, facilityId: b.facilityId);
    expect(s.cancellationCutoffHours, cfg.cancellationCutoffHours);
    expect(s.refundPercent, cfg.refundPercent);
    expect(s.reminderLeadMinutes, 180);
    expect(s.isTestProvider, isTrue);
  });

  test('summary: the booking shows as the summary rows expect', () async {
    final b = await create();
    final v = (await c.read(checkoutSummaryProvider(b.id).future))!;
    expect(v.amount, 140);
    expect(v.facilityName, isNotEmpty);
    expect(v.unitName, isNotEmpty);
    expect(v.quote.cancellationCutoffHours,
        (await c.read(checkoutSettingsProvider(b.id).future)).cancellationCutoffHours);
  });

  test('receipt: for any booking of the person with a succeeded payment, '
      'with a refund line after cancelling', () async {
    final b = await create();
    expect(await c.read(receiptProvider(b.id).future), isNull);
    final s = (await layer.bookings.startPayment(b.id, b.userId) as Ok<PaymentSession>).value;
    layer.paymentProvider.gateway.confirm(s.id, cardLast4: '4242');
    await settle();
    final r = (await c.read(receiptProvider(b.id).future))!;
    expect(r.cardLast4, '4242');
    expect(r.amount, 140);
    expect(r.refundAmount, isNull);
    expect(r.number, startsWith('RC-'));

    // The booking is cancelled and some of the money comes back; the receipt
    // now also records the refund (research R10).
    final preview = await layer.bookings.previewCancel(b.id, b.userId);
    expect(preview.refundAmount, greaterThan(0));
    expect(await layer.bookings.cancel(b.id, b.userId), isA<Ok<Booking>>());
    c.invalidate(receiptProvider(b.id));
    final cancelled = (await c.read(receiptProvider(b.id).future))!;
    expect(cancelled.refundAmount, preview.refundAmount);

    // A free booking has none.
    final free = layer.bookings.allBookings.firstWhere((x) =>
        x.userId == SeedIds.bookerInternal &&
        x.unitId == SeedIds.hall1 &&
        x.status == BookingStatus.confirmed);
    expect(await c.read(receiptProvider(free.id).future), isNull);
  });

  test('housekeeping: keeps Holds honest off the checkout screen', () async {
    layer.paymentProvider.gateway.outcome =
        const FakeOutcome.delay(Duration(minutes: 5));
    final b = await create();
    expect(c.read(holdHousekeepingProvider), isTrue);
    await settle(20);
    // The Hold runs out with nothing pending: the next timer expires it. Move
    // the clock past it and ask the way the timer does.
    now = now.add(const Duration(minutes: 11));
    await layer.bookings.expireHolds();
    expect(((await layer.bookings.get(b.id)) as Ok<Booking>).value.status,
        BookingStatus.expired);
  });

  test('housekeeping is idle for a guest', () async {
    await c.read(sessionProvider.notifier).actAs(null);
    expect(c.read(holdHousekeepingProvider), isFalse);
  });
}
