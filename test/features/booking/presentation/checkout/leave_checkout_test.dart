import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/adaptive/adaptive_back_button.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/presentation/checkout/awaiting_view.dart';
import 'package:sprint/features/booking/presentation/checkout/checkout_screen.dart';
import 'package:sprint/features/booking/presentation/checkout/processing_view.dart';
import 'package:sprint/features/booking/presentation/summary/booking_summary_screen.dart';
import 'package:sprint/features/payments/data/fake_gateway_controller.dart';
import 'package:sprint/features/payments/domain/payment.dart';
import 'package:sprint/features/payments/presentation/fake_gateway_screen.dart';

import '../../../../helpers/pump_app.dart';
import '../schedule_harness.dart' show currentUri;
import 'checkout_harness.dart';

/// BR-47: leaving payment asks first and releases the place; backing out on
/// the provider's page is a cancel, not a failure.
void main() {
  const platforms = TargetPlatformVariant({
    TargetPlatform.iOS,
    TargetPlatform.android,
  });

  testWidgets('the app-bar back and the system back both ask', (tester) async {
    final env = await CheckoutEnv.open(tester);
    await tester.tap(find.byType(AdaptiveBackButton));
    await tester.pumpAndSettle();
    expect(find.text(ar.checkoutLeaveTitle), findsOneWidget);
    expect(find.text(ar.checkoutLeaveBody), findsOneWidget);
    await tester.tap(find.text(ar.checkoutLeaveStay));
    await tester.pumpAndSettle();
    expect(find.text(ar.checkoutLeaveTitle), findsNothing);

    // The system back (gesture, button, browser back): the same dialog.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text(ar.checkoutLeaveTitle), findsOneWidget);
    await tester.tap(find.text(ar.checkoutLeaveStay));
    await tester.pumpAndSettle();
    expect((await env.reload()).status, BookingStatus.pendingPayment);
    expect(find.byType(CheckoutScreen), findsOneWidget);
  }, variant: platforms);

  testWidgets('"ترك الدفع" expires the booking and returns to the same '
      'summary', (tester) async {
    final env = await CheckoutEnv.open(tester);
    await tester.tap(find.byType(AdaptiveBackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text(ar.checkoutLeaveConfirm));
    await tester.pumpAndSettle();

    expect((await env.reload()).status, BookingStatus.expired);
    expect(find.byType(BookingSummaryScreen), findsOneWidget);
    final q = currentUri(tester);
    expect(q.path, '/facilities/${env.booking.facilityId}/schedule/summary');
    expect(q.queryParameters, containsPair('unit', env.booking.unitId));
    expect(q.queryParameters, containsPair('start', '1800'));
    expect(q.queryParameters, containsPair('end', '1900'));
    expect(q.queryParameters, containsPair('day', '2026-11-16'));
  }, variant: platforms);

  testWidgets('leaving also asks from the failed state', (tester) async {
    final env = await CheckoutEnv.open(tester, outcome: const FakeOutcome.fail());
    await env.payOnPage();
    expect(find.text(ar.checkoutFailedTitle), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text(ar.checkoutLeaveTitle), findsOneWidget);
  });

  testWidgets('processing absorbs back with no dialog and no back button',
      (tester) async {
    final env = await CheckoutEnv.open(
      tester,
      outcome: const FakeOutcome.delay(Duration(seconds: 30)),
    );
    await env.payOnPage(wait: const Duration(seconds: 1));
    expect(find.byType(ProcessingView), findsOneWidget);
    expect(find.byType(AdaptiveBackButton), findsNothing);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text(ar.checkoutLeaveTitle), findsNothing);
    expect(find.byType(ProcessingView), findsOneWidget);
    expect((await env.reload()).status, BookingStatus.pendingPayment);
    expect(find.byType(AwaitingView), findsNothing);
    // Let the slow provider answer, so no timer outlives the test.
    await env.advance(const Duration(seconds: 30));
    await tester.pumpAndSettle();
  });

  testWidgets('"إلغاء" on the provider page is a cancel: a banner, the same '
      'countdown, and "الدفع" starts a new payment', (tester) async {
    final env = await CheckoutEnv.open(tester);
    await tester.tap(find.byKey(CheckoutScreen.payKey));
    await tester.pumpAndSettle();
    await env.advance(const Duration(seconds: 30));
    await tester.tap(find.byKey(cancelKey));
    await tester.pumpAndSettle();

    final first = (await env.layer.payments.latestPayment(env.booking.id))!;
    expect(first.status, PaymentStatus.cancelled);
    expect(find.text(ar.checkoutCancelledTitle), findsOneWidget);
    expect(find.text(ar.checkoutCancelledBody), findsOneWidget);
    // Not the failure state.
    expect(find.text(ar.checkoutFailedTitle), findsNothing);
    // The same Hold keeps counting.
    expect(find.text(ar.checkoutHoldRemaining('9:30')), findsOneWidget);
    expect((await env.reload()).holdExpiresAt, env.booking.holdExpiresAt);

    await tester.tap(find.byKey(CheckoutScreen.payKey));
    await tester.pumpAndSettle();
    expect(find.byType(FakeGatewayScreen), findsOneWidget);
    final all = await env.layer.payments.payments(env.booking.id);
    expect(all, hasLength(2));
  });

  testWidgets('the provider page back is the same cancel', (tester) async {
    final env = await CheckoutEnv.open(tester);
    await tester.tap(find.byKey(CheckoutScreen.payKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(AdaptiveBackButton));
    await tester.pumpAndSettle();
    expect(
      (await env.layer.payments.latestPayment(env.booking.id))!.status,
      PaymentStatus.cancelled,
    );
    expect(find.byType(CheckoutScreen), findsOneWidget);
    expect(currentPath(tester), env.checkoutPath);
  });
}
