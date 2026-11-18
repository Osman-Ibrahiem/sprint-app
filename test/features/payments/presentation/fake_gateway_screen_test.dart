import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/l10n/ltr_isolate.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/presentation/checkout/checkout_screen.dart';
import 'package:sprint/features/booking/presentation/checkout/hold_banner.dart';
import 'package:sprint/features/booking/presentation/confirmed/booking_confirmed_screen.dart';
import 'package:sprint/features/payments/domain/payment.dart';
import 'package:sprint/features/payments/presentation/fake_gateway_screen.dart';

import '../../../features/booking/presentation/checkout/checkout_harness.dart';
import '../../../helpers/pump_app.dart';

/// The simulated provider page (R5, FR-009).
void main() {
  Future<CheckoutEnv> openPage(WidgetTester tester) async {
    final env = await CheckoutEnv.open(tester);
    await tester.tap(find.byKey(CheckoutScreen.payKey));
    await tester.pumpAndSettle();
    return env;
  }

  Future<void> fill(
    WidgetTester tester, {
    String number = '4242 4242 4242 4242',
    String expiry = '12/30',
    String cvc = '123',
    String name = 'منى عبد الله',
  }) async {
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), number);
    await tester.enterText(fields.at(1), expiry);
    await tester.enterText(fields.at(2), cvc);
    await tester.enterText(fields.at(3), name);
    await tester.pump();
  }

  testWidgets('shows the amount, the merchant, the Hold and four fields',
      (tester) async {
    await openPage(tester);
    expect(find.byType(FakeGatewayScreen), findsOneWidget);
    expect(find.text(ar.gatewayTitle), findsOneWidget);
    expect(find.byKey(amountKey), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(amountKey)).data,
      '140 ج.م',
    );
    // Walk 2026-11-18 D3: the price reads right to left, not isolated LTR.
    expect(
      find.ancestor(of: find.byKey(amountKey), matching: find.byType(LtrIsolate)),
      findsNothing,
    );
    expect(find.text(ar.gatewayMerchant('ملعب كرة القدم الخماسي')),
        findsOneWidget);
    expect(find.byType(HoldBanner), findsOneWidget);
    expect(find.text(ar.gatewayHoldBody('10:00')), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(4));
    expect(find.byKey(testTagKey), findsOneWidget);
    expect(find.text(ar.gatewayNotice), findsOneWidget);
    expect(find.text(ar.gatewayConfirm('140 ج.م')), findsOneWidget);
  });

  testWidgets('card digits are left to right with a numeric keyboard',
      (tester) async {
    await openPage(tester);
    final fields = tester.widgetList<TextField>(find.byType(TextField)).toList();
    for (final f in fields.take(3)) {
      expect(f.textDirection, TextDirection.ltr);
      expect(f.keyboardType, TextInputType.number);
    }
  });

  testWidgets('an empty confirm says what is wrong, in words and an icon',
      (tester) async {
    final env = await openPage(tester);
    await tester.ensureVisible(find.byKey(confirmKey));
    await tester.tap(find.byKey(confirmKey));
    await tester.pumpAndSettle();
    expect(find.text(ar.gatewayErrCardNumber), findsOneWidget);
    expect(find.text(ar.gatewayErrExpiry), findsOneWidget);
    expect(find.text(ar.gatewayErrCvc), findsOneWidget);
    expect(find.text(ar.gatewayErrName), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsWidgets);
    // Still on the page, nothing sent to the provider.
    expect(find.byType(FakeGatewayScreen), findsOneWidget);
    expect(
      (await env.layer.payments.latestPayment(env.booking.id))!.status,
      PaymentStatus.pending,
    );
  });

  testWidgets('a number that fails the Luhn check is refused', (tester) async {
    await openPage(tester);
    await fill(tester, number: '4242 4242 4242 4241');
    await tester.ensureVisible(find.byKey(confirmKey));
    await tester.tap(find.byKey(confirmKey));
    await tester.pumpAndSettle();
    expect(find.text(ar.gatewayErrCardNumber), findsOneWidget);
    expect(find.text(ar.gatewayErrExpiry), findsNothing);
    expect(find.byType(FakeGatewayScreen), findsOneWidget);
  });

  testWidgets('the number is grouped as it is typed', (tester) async {
    await openPage(tester);
    await tester.enterText(find.byType(TextField).at(0), '4242424242424242');
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField).at(0)).controller!.text,
      '4242 4242 4242 4242',
    );
    await tester.enterText(find.byType(TextField).at(1), '1230');
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField).at(1)).controller!.text,
      '12/30',
    );
  });

  testWidgets('confirm sends only the last four digits and the booking is '
      'confirmed by the provider', (tester) async {
    final env = await openPage(tester);
    await fill(tester);
    await tester.ensureVisible(find.byKey(confirmKey));
    await tester.tap(find.byKey(confirmKey));
    await tester.pumpAndSettle();

    final p = (await env.layer.payments.latestPayment(env.booking.id))!;
    expect(p.status, PaymentStatus.succeeded);
    expect(p.cardLast4, '4242');
    expect(p.toJson().toString(), isNot(contains('4242 4242')));
    expect((await env.reload()).status, BookingStatus.confirmed);
    expect(find.byType(BookingConfirmedScreen), findsOneWidget);
    expect(currentPath(tester), AppPaths.bookingConfirmed(env.booking.id));
  });
}
