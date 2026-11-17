import 'package:flutter/widgets.dart' show Text;
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/data/in_memory_data_layer.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/presentation/checkout/awaiting_view.dart';
import 'package:sprint/features/booking/presentation/checkout/checkout_booking_card.dart';
import 'package:sprint/features/booking/presentation/checkout/expired_view.dart';
import 'package:sprint/features/booking/presentation/checkout/processing_view.dart';
import 'package:sprint/features/booking/presentation/confirmed/booking_confirmed_screen.dart';
import 'package:sprint/features/payments/data/fake_gateway_controller.dart';
import 'package:sprint/features/payments/domain/payment.dart';
import 'package:sprint/features/settings/domain/setting_definition.dart';
import 'package:sprint/features/settings/domain/setting_registry.dart';

import '../../../../helpers/pump_app.dart';
import 'checkout_harness.dart';

/// US-10 slow confirmation (BR-28, BR-46): processing, then waiting; the Hold
/// waits for the provider; a late charge is refunded automatically.
void main() {
  Future<void> holds(InMemoryDataLayer layer, {int normal = 1, int max = 2}) async {
    await layer.settings.set(
      SettingKeys.holdMinutes,
      normal,
      const SettingScope.university(),
      actorId: 'admin',
    );
    await layer.settings.set(
      SettingKeys.holdMaxMinutes,
      max,
      const SettingScope.university(),
      actorId: 'admin',
    );
  }

  testWidgets('processing becomes awaiting after 20 seconds; refresh reads the '
      'status; success within the maximum confirms', (tester) async {
    final env = await CheckoutEnv.open(
      tester,
      outcome: const FakeOutcome.delay(Duration(seconds: 30)),
    );
    await env.payOnPage();
    expect(find.byType(ProcessingView), findsOneWidget);
    await env.advance(const Duration(seconds: 18));
    expect(find.byType(ProcessingView), findsOneWidget);
    await env.advance(const Duration(seconds: 2));
    expect(find.byType(AwaitingView), findsOneWidget);
    expect(find.text(ar.awaitingTitle), findsOneWidget);
    expect(find.text(ar.awaitingBody), findsOneWidget);
    expect(find.text(ar.statusPendingPayment), findsWidgets);

    await tester.tap(find.byKey(AwaitingView.refreshKey));
    await tester.pumpAndSettle();
    expect(find.byType(AwaitingView), findsOneWidget, reason: 'still pending');
    expect((await env.reload()).status, BookingStatus.pendingPayment);

    await env.advance(const Duration(seconds: 15));
    await tester.pumpAndSettle();
    expect(find.byType(BookingConfirmedScreen), findsOneWidget);
    expect((await env.reload()).status, BookingStatus.confirmed);
  });

  testWidgets('when the normal Hold is reached the countdown jumps to the '
      'maximum, and the place stays held', (tester) async {
    final env = await CheckoutEnv.open(
      tester,
      outcome: const FakeOutcome.delay(Duration(seconds: 90)),
      arrange: holds,
    );
    await env.payOnPage();
    await env.advance(const Duration(seconds: 25));
    expect(find.byType(AwaitingView), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(CheckoutBookingCard.footerKey)).data,
      ar.processingHeld('0:34'),
    );
    // t = 61 s: the normal minute is over; the maximum (2 minutes) applies.
    await env.advance(const Duration(seconds: 36));
    final b = await env.reload();
    expect(b.status, BookingStatus.pendingPayment);
    expect(b.holdExpiresAt, env.booking.holdMaxExpiresAt);
    expect(
      tester.widget<Text>(find.byKey(CheckoutBookingCard.footerKey)).data,
      ar.processingHeld('0:58'),
    );
    // The provider answers at 90 s, inside the maximum.
    await env.advance(const Duration(seconds: 30));
    await tester.pumpAndSettle();
    expect(find.byType(BookingConfirmedScreen), findsOneWidget);
  });

  testWidgets('past the maximum: expired, then a late success is refunded in '
      'full and said so in the app', (tester) async {
    final env = await CheckoutEnv.open(
      tester,
      outcome: const FakeOutcome.delay(Duration(minutes: 3)),
      arrange: holds,
    );
    await env.payOnPage();
    await env.advance(const Duration(seconds: 125));
    await tester.pumpAndSettle();
    expect(find.byKey(ExpiredView.titleKey), findsOneWidget);
    expect((await env.reload()).status, BookingStatus.expired);

    await env.advance(const Duration(seconds: 60));
    await tester.pumpAndSettle();
    final p = (await env.layer.payments.latestPayment(env.booking.id))!;
    expect(p.status, PaymentStatus.succeeded);
    final refunds = await env.layer.payments.refunds(p.id);
    expect(refunds, hasLength(1));
    expect(refunds.single.amount, p.amount);
    expect((await env.reload()).status, BookingStatus.expired);
    expect(
      env.layer.notifications.all.where((n) =>
          n.type == 'payment.refunded_auto' &&
          n.payload['code'] == env.booking.code),
      hasLength(1),
    );
  });

  testWidgets('"الرجوع للحجوزات" leaves; the outcome still applies in the '
      'background', (tester) async {
    final env = await CheckoutEnv.open(
      tester,
      outcome: const FakeOutcome.delay(Duration(seconds: 40)),
    );
    await env.payOnPage();
    await env.advance(const Duration(seconds: 21));
    expect(find.byType(AwaitingView), findsOneWidget);
    await tester.tap(find.byKey(AwaitingView.bookingsKey));
    await tester.pumpAndSettle();
    expect(currentPath(tester), AppPaths.bookings);

    await env.advance(const Duration(seconds: 30));
    await tester.pumpAndSettle();
    expect((await env.reload()).status, BookingStatus.confirmed);
  });
}
