import 'dart:ui' as ui;

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' as rp;
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/data/in_memory_data_layer.dart';
import 'package:sprint/core/l10n/locale_notifier.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/theme/theme_mode_notifier.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/booking_repository.dart';
import 'package:sprint/features/booking/presentation/checkout/checkout_screen.dart';
import 'package:sprint/features/payments/data/fake_gateway_controller.dart';
import 'package:sprint/features/payments/presentation/fake_gateway_screen.dart' show confirmKey;

import '../../../../helpers/pump_app.dart';

/// A running checkout: the data layer, a clock the test moves, and the
/// booking on hold. Time only moves through [advance], which also lets the
/// one-second tick of the screen run.
class _Time {
  _Time(this.now);
  DateTime now;
}

class CheckoutEnv {
  CheckoutEnv._(this.tester, this._time, this.layer, this.booking);

  final WidgetTester tester;
  final _Time _time;
  final InMemoryDataLayer layer;
  final Booking booking;

  DateTime get now => _time.now;
  FakeGatewayController get gateway => layer.paymentProvider.gateway;
  String get checkoutPath =>
      AppPaths.bookingCheckoutFor(booking.facilityId, booking.id);

  /// Moves the clock and the test's own time by [d], so the screen's tick,
  /// the repository and the fake provider's timers all run.
  Future<void> advance(Duration d) async {
    _time.now = _time.now.add(d);
    await tester.pump(d);
    await tester.pump();
  }

  /// The provider session of the latest payment.
  Future<String> sessionId() async =>
      (await layer.payments.latestPayment(booking.id))!.providerRef;

  /// Taps the pay button and fills the provider page with a test card and
  /// confirms it (the booker's side of a payment), then lets time pass by
  /// [wait].
  Future<void> payOnPage({Duration wait = const Duration(seconds: 1)}) async {
    await tester.ensureVisible(find.byKey(CheckoutScreen.payKey));
    await tester.tap(find.byKey(CheckoutScreen.payKey));
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '4242 4242 4242 4242');
    await tester.enterText(fields.at(1), '12/30');
    await tester.enterText(fields.at(2), '123');
    await tester.enterText(fields.at(3), 'منى عبد الله');
    await tester.pump();
    await tester.scrollUntilVisible(
      find.byKey(confirmKey),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.byKey(confirmKey));
    await tester.tap(find.byKey(confirmKey));
    await tester.pumpAndSettle();
    await advance(wait);
    await tester.pumpAndSettle();
  }

  Future<Booking> reload() async =>
      (await layer.bookings.get(booking.id) as Ok<Booking>).value;

  /// Opens the checkout of a new paid booking (futsal pitch 2, two days out,
  /// 140 EGP for the internal booker).
  static Future<CheckoutEnv> open(
    WidgetTester tester, {
    Size size = const Size(400, 1600),
    double textScale = 1,
    Locale? locale,
    String user = SeedIds.bookerInternal,
    FakeOutcome outcome = const FakeOutcome.succeed(),
    Future<void> Function(InMemoryDataLayer layer)? arrange,
    List<rp.Override> overrides = const [],
    List<ui.DisplayFeature> features = const [],
    bool dark = false,
  }) async {
    CairoTime.ensureInitialized();
    final time = _Time(CairoTime.atWallClock(2026, 11, 14, 8));
    final clock = Clock(() => time.now);
    final layer = InMemoryDataLayer.create(
      clock: clock,
      paymentDelay: Duration.zero,
      gatewayOutcome: outcome,
    );
    if (arrange != null) await arrange(layer);
    final created = await layer.bookings.create(BookingRequest(
      userId: user,
      unitId: SeedIds.futsal2,
      start: CairoTime.atWallClock(2026, 11, 16, 18),
      end: CairoTime.atWallClock(2026, 11, 16, 19),
    ));
    final booking = (created as Ok<Booking>).value;
    await pumpSprintApp(
      tester,
      size: size,
      textScale: textScale,
      features: features,
      overrides: [
        dataLayerProvider.overrideWithValue(layer),
        appClockProvider.overrideWithValue(clock),
        ...overrides,
      ],
    );
    final env = CheckoutEnv._(tester, time, layer, booking);
    await containerOf(tester).read(sessionProvider.notifier).actAs(user);
    final container = containerOf(tester);
    if (locale != null) {
      await container.read(localeProvider.notifier).set(locale);
    }
    if (dark) {
      await container.read(themeModeProvider.notifier).set(ThemeMode.dark);
    }
    await tester.pumpAndSettle();
    routerOf(tester).go(env.checkoutPath);
    await tester.pumpAndSettle();
    return env;
  }
}
