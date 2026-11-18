import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/presentation/checkout/checkout_layout.dart';
import 'package:sprint/features/booking/presentation/checkout/checkout_policy_card.dart';
import 'package:sprint/features/booking/presentation/checkout/checkout_screen.dart';
import 'package:sprint/features/booking/presentation/checkout/checkout_summary_card.dart';
import 'package:sprint/features/booking/presentation/checkout/hold_banner.dart';
import 'package:sprint/features/booking/presentation/checkout/payment_method_card.dart';
import 'package:sprint/features/booking/presentation/providers/checkout_providers.dart';
import 'package:sprint/features/payments/domain/payment.dart';
import 'package:sprint/features/payments/presentation/fake_gateway_screen.dart';

import '../../../../helpers/pump_app.dart';
import '../schedule_harness.dart' show currentUri;
import 'checkout_harness.dart';

/// US-10 checkout while the Hold runs (FR-003, FR-005, FR-024).
void main() {
  testWidgets('the sections come in order: banner, summary, policy, method, '
      'and one primary action with the amount', (tester) async {
    final env = await CheckoutEnv.open(tester);
    expect(find.byType(CheckoutScreen), findsOneWidget);

    final banner = tester.getTopLeft(find.byType(HoldBanner)).dy;
    final rows = tester.getTopLeft(find.text(ar.checkoutRowTotal)).dy;
    final policy = tester.getTopLeft(find.byKey(CheckoutPolicyCard.bodyKey)).dy;
    final method = tester.getTopLeft(find.byType(PaymentMethodCard)).dy;
    expect(banner, lessThan(rows));
    expect(rows, lessThan(policy));
    expect(policy, lessThan(method));

    expect(find.byKey(CheckoutSummaryCard.totalKey), findsOneWidget);
    expect(find.text(ar.checkoutHoldTitle), findsOneWidget);
    expect(find.text(ar.checkoutHoldRemaining('10:00')), findsOneWidget);
    final primaries = tester
        .widgetList<SprintButton>(find.byType(SprintButton))
        .where((b) => b.variant == SprintButtonVariant.primary);
    expect(primaries, hasLength(1));
    expect(primaries.single.label, ar.checkoutPay('140 ج.م'));
    expect((await env.reload()).status, BookingStatus.pendingPayment);
  });

  testWidgets('the policy text comes from the cutoff and refund settings', (
    tester,
  ) async {
    await CheckoutEnv.open(tester);
    final text = tester.widget<Text>(find.byKey(CheckoutPolicyCard.bodyKey));
    expect(text.data, contains('50%').or(contains('100%')));
    expect(text.data, contains('ساعت'));
  });

  testWidgets('the countdown comes from holdExpiresAt and keeps running', (
    tester,
  ) async {
    final env = await CheckoutEnv.open(tester);
    await env.advance(const Duration(seconds: 90));
    expect(find.text(ar.checkoutHoldRemaining('8:30')), findsOneWidget);
    await env.advance(const Duration(minutes: 8));
    expect(find.text(ar.checkoutLastMinuteTitle), findsOneWidget);
  });

  testWidgets('the test-mode tag shows for the fake provider and not for a '
      'real one', (tester) async {
    await CheckoutEnv.open(tester);
    expect(find.byKey(PaymentMethodCard.testTagKey), findsOneWidget);
    expect(find.text(ar.checkoutSandboxTag), findsOneWidget);
  });

  testWidgets('no test tag when the provider is not a test one', (
    tester,
  ) async {
    late CheckoutEnv env;
    env = await CheckoutEnv.open(
      tester,
      overrides: [
        checkoutSettingsProvider.overrideWith(
          (ref, id) async => const CheckoutSettings(
            cancellationCutoffHours: 2,
            refundPercent: 50,
            reminderLeadMinutes: 180,
            isTestProvider: false,
          ),
        ),
      ],
    );
    expect(env.booking.id, isNotEmpty);
    expect(find.byKey(PaymentMethodCard.testTagKey), findsNothing);
  });

  testWidgets('compact: the action sits in a fixed bar; from 600 two columns', (
    tester,
  ) async {
    await CheckoutEnv.open(tester);
    expect(find.byKey(CheckoutLayout.barKey), findsOneWidget);

    await CheckoutEnv.open(tester, size: const Size(1000, 1000));
    expect(find.byKey(CheckoutLayout.barKey), findsNothing);
    expect(find.byKey(CheckoutLayout.paymentColumnKey), findsOneWidget);
    expect(find.byKey(CheckoutLayout.summaryColumnKey), findsOneWidget);
  });

  testWidgets('"الدفع" starts one payment and opens the provider page', (
    tester,
  ) async {
    final env = await CheckoutEnv.open(tester);
    await tester.tap(find.byKey(CheckoutScreen.payKey));
    await tester.pumpAndSettle();

    expect(find.byType(FakeGatewayScreen), findsOneWidget);
    final p = (await env.layer.payments.latestPayment(env.booking.id))!;
    expect(p.status, PaymentStatus.pending);
    expect(currentUri(tester).path, AppPaths.fakeGateway(p.providerRef));
  });
}

extension on Matcher {
  Matcher or(Matcher other) => anyOf(this, other);
}
