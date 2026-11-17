import 'dart:ui' as ui;

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' as rp;
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/data/in_memory_data_layer.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/booking_repository.dart';
import 'package:sprint/features/payments/data/fake_gateway_controller.dart';

import '../../../../helpers/pump_app.dart';

/// A running checkout: the data layer, a clock the test moves, and the
/// booking on hold. Time only moves through [advance], which also lets the
/// one-second tick of the screen run.
class CheckoutEnv {
  CheckoutEnv._(this.tester, this._now, this.layer, this.booking);

  final WidgetTester tester;
  DateTime _now;
  final InMemoryDataLayer layer;
  final Booking booking;

  DateTime get now => _now;
  FakeGatewayController get gateway => layer.paymentProvider.gateway;
  String get checkoutPath =>
      AppPaths.bookingCheckoutFor(booking.facilityId, booking.id);

  /// Moves the clock by [d] and lets the screen's tick and the repository run.
  Future<void> advance(Duration d) async {
    _now = _now.add(d);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
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
    var now = CairoTime.atWallClock(2026, 11, 14, 8);
    late CheckoutEnv env;
    final clock = Clock(() => now);
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
        appClockProvider.overrideWithValue(Clock(() => env._now)),
        ...overrides,
      ],
    );
    env = CheckoutEnv._(tester, now, layer, booking);
    await containerOf(tester).read(sessionProvider.notifier).actAs(user);
    await tester.pumpAndSettle();
    routerOf(tester).go(env.checkoutPath);
    await tester.pumpAndSettle();
    return env;
  }
}
