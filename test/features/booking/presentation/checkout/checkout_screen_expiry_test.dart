import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/l10n/locale_notifier.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/presentation/checkout/checkout_screen.dart';
import 'package:sprint/features/booking/presentation/checkout/expired_view.dart';
import 'package:sprint/features/booking/presentation/checkout/hold_banner.dart';
import 'package:sprint/features/payments/data/fake_gateway_controller.dart';
import 'package:sprint/features/booking/domain/booking_repository.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/features/settings/domain/setting_definition.dart';
import 'package:sprint/features/settings/domain/setting_registry.dart';

import '../../../../helpers/pump_app.dart';
import 'checkout_harness.dart';

/// US-10 / BR-12: the last minute and the end of the Hold (FR-003, FR-004).
void main() {
  testWidgets(
    'below 60 seconds the banner turns urgent and speaks in seconds',
    (tester) async {
      final env = await CheckoutEnv.open(tester);
      await env.advance(const Duration(minutes: 9, seconds: 10));
      expect(find.text(ar.checkoutLastMinuteTitle), findsOneWidget);
      expect(find.text(ar.checkoutLastMinuteBody(50)), findsOneWidget);
      final live = tester.getSemantics(find.byKey(HoldBanner.liveRegionKey));
      expect(live.label, contains(ar.checkoutLastMinuteTitle));
      expect(live.flagsCollection.isLiveRegion, isTrue);
    },
  );

  testWidgets('the Hold running out shows the expired state and frees the '
      'place', (tester) async {
    final env = await CheckoutEnv.open(tester);
    await env.advance(const Duration(minutes: 10, seconds: 1));
    await tester.pumpAndSettle();
    expect(find.byKey(ExpiredView.titleKey), findsOneWidget);
    expect(find.text(ar.holdExpiredBody), findsOneWidget);
    expect(find.text(ar.statusExpired), findsWidgets);
    expect((await env.reload()).status, BookingStatus.expired);
    // Another account can take the place now.
    final other = await env.layer.bookings.quote(
      BookingRequest(
        userId: SeedIds.bookerExternal,
        unitId: env.booking.unitId,
        start: env.booking.start,
        end: env.booking.end,
      ),
    );
    expect(other.isOk, isTrue);
  });

  testWidgets('expired from the failed state and from the cancelled state', (
    tester,
  ) async {
    final env = await CheckoutEnv.open(
      tester,
      outcome: const FakeOutcome.fail(),
    );
    await env.payOnPage();
    expect(find.text(ar.checkoutFailedTitle), findsOneWidget);
    await env.advance(const Duration(minutes: 11));
    await tester.pumpAndSettle();
    expect(find.byKey(ExpiredView.titleKey), findsOneWidget);

    final env2 = await CheckoutEnv.open(tester);
    await tester.tap(find.byKey(CheckoutScreen.payKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('gateway-cancel')));
    await tester.pumpAndSettle();
    expect(find.text(ar.checkoutCancelledTitle), findsOneWidget);
    await env2.advance(const Duration(minutes: 11));
    await tester.pumpAndSettle();
    expect(find.byKey(ExpiredView.titleKey), findsOneWidget);
  });

  testWidgets('"اختيار ميعاد تاني" opens the schedule with no selection and '
      '"الرجوع للرئيسية" goes home', (tester) async {
    final env = await CheckoutEnv.open(tester);
    await env.advance(const Duration(minutes: 11));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ExpiredView.pickAnotherKey));
    await tester.pumpAndSettle();
    expect(
      currentPath(tester),
      AppPaths.facilitySchedule(env.booking.facilityId),
    );
    expect(
      routerOf(tester).routerDelegate.currentConfiguration.uri.query,
      isEmpty,
    );

    routerOf(tester).go(env.checkoutPath);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ExpiredView.homeKey));
    await tester.pumpAndSettle();
    expect(currentPath(tester), AppPaths.home);
  });

  testWidgets('an app resumed after the Hold ended shows expired at once', (
    tester,
  ) async {
    final env = await CheckoutEnv.open(tester);
    // Backgrounded for an hour: one step, no ticks in between.
    await env.advance(const Duration(hours: 1));
    await tester.pumpAndSettle();
    expect(find.byKey(ExpiredView.titleKey), findsOneWidget);
  });

  testWidgets('resize, theme and language keep the same expiry', (
    tester,
  ) async {
    final env = await CheckoutEnv.open(tester);
    await env.advance(const Duration(minutes: 2));
    expect(find.text(ar.checkoutHoldRemaining('8:00')), findsOneWidget);

    tester.view.physicalSize = const Size(1000, 900);
    await tester.pumpAndSettle();
    expect(find.text(ar.checkoutHoldRemaining('8:00')), findsOneWidget);

    await containerOf(tester)
        .read(localeProvider.notifier)
        .set(const Locale('en'));
    await tester.pumpAndSettle();
    expect(find.textContaining('8:00'), findsWidgets);
    expect((await env.reload()).holdExpiresAt, env.booking.holdExpiresAt);
  });

  testWidgets('a one-minute Hold (the settings inspector) runs out within '
      'a minute', (tester) async {
    final env = await CheckoutEnv.open(
      tester,
      arrange: (layer) async {
        await layer.settings.set(
          SettingKeys.holdMinutes,
          1,
          const SettingScope.university(),
          actorId: 'admin',
        );
      },
    );
    expect(find.text(ar.checkoutHoldRemaining('1:00')), findsOneWidget);
    await env.advance(const Duration(seconds: 1));
    expect(find.text(ar.checkoutLastMinuteTitle), findsOneWidget);
    await env.advance(const Duration(seconds: 60));
    await tester.pumpAndSettle();
    expect(find.byKey(ExpiredView.titleKey), findsOneWidget);
    expect(
      (await env.layer.payments.latestPayment(env.booking.id)),
      isNull,
      reason: 'no payment was ever started',
    );
  });
}
