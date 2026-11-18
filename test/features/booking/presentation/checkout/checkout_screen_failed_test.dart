import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/presentation/checkout/checkout_policy_card.dart';
import 'package:sprint/features/booking/presentation/checkout/checkout_screen.dart';
import 'package:sprint/features/booking/presentation/checkout/expired_view.dart';
import 'package:sprint/features/booking/presentation/checkout/hold_banner.dart';
import 'package:sprint/features/booking/presentation/checkout/moment_placeholder.dart';
import 'package:sprint/features/booking/presentation/checkout/payment_method_card.dart';
import 'package:sprint/features/booking/presentation/confirmed/booking_confirmed_screen.dart';
import 'package:sprint/features/payments/data/fake_gateway_controller.dart';
import 'package:sprint/features/payments/domain/payment.dart';
import 'package:sprint/features/settings/domain/setting_definition.dart';
import 'package:sprint/features/settings/domain/setting_registry.dart';

import '../../../../helpers/pump_app.dart';
import 'checkout_harness.dart';

/// US-10: a failed payment returns to the same checkout with the Hold still
/// running, and the booker can try again (FR-011).
void main() {
  Future<CheckoutEnv> failedCheckout(WidgetTester tester) async {
    final env = await CheckoutEnv.open(
      tester,
      outcome: const FakeOutcome.fail(),
    );
    await env.payOnPage();
    return env;
  }

  testWidgets('the failure state: words, summary title, same Hold, same '
      'checkout', (tester) async {
    final env = await failedCheckout(tester);
    expect(find.text(ar.checkoutFailedTitle), findsOneWidget);
    expect(find.text(ar.checkoutFailedBody), findsOneWidget);
    // The title of the screen is "ملخص الحجز".
    expect(find.text(ar.bookingSummaryTitle), findsWidgets);
    expect(find.byType(HoldBanner), findsOneWidget);
    expect(find.byKey(CheckoutPolicyCard.bodyKey), findsOneWidget);
    expect(find.byType(PaymentMethodCard), findsOneWidget);
    expect(
      tester
          .widgetList<SprintButton>(find.byType(SprintButton))
          .where((b) => b.variant == SprintButtonVariant.primary)
          .single
          .label,
      ar.checkoutRetry('140 ج.م'),
    );
    final b = await env.reload();
    expect(b.status, BookingStatus.pendingPayment);
    expect(b.holdExpiresAt, env.booking.holdExpiresAt);
    expect(
      (await env.layer.payments.latestPayment(env.booking.id))!.status,
      PaymentStatus.failed,
    );
  });

  testWidgets('the failure title is a live region, announced once', (
    tester,
  ) async {
    await failedCheckout(tester);
    final node = tester.getSemantics(find.byKey(MomentPlaceholder.titleKey));
    expect(node.label, ar.checkoutFailedTitle);
    expect(node.flagsCollection.isLiveRegion, isTrue);
    expect(find.byType(MomentPlaceholder), findsOneWidget);
  });

  testWidgets('retry: a second payment, then the ticket', (tester) async {
    final env = await failedCheckout(tester);
    env.gateway.outcome = const FakeOutcome.succeed();
    await env.payOnPage();
    expect(find.byType(BookingConfirmedScreen), findsOneWidget);
    final all = await env.layer.payments.payments(env.booking.id);
    expect(all, hasLength(2));
    expect(all.map((p) => p.status).toSet(), {
      PaymentStatus.failed,
      PaymentStatus.succeeded,
    });
  });

  testWidgets('the Hold keeps running on the failure state and turns into '
      'the expired state', (tester) async {
    final env = await failedCheckout(tester);
    await env.advance(const Duration(minutes: 5));
    expect(
      find.text(ar.checkoutHoldRemaining('4:59')).evaluate().isNotEmpty ||
          find.textContaining('4:').evaluate().isNotEmpty,
      isTrue,
    );
    await env.advance(const Duration(minutes: 6));
    expect(find.byKey(ExpiredView.titleKey), findsOneWidget);
    expect((await env.reload()).status, BookingStatus.expired);
  });

  testWidgets('a failure that arrives after an extended Hold ran past its '
      'normal time shows the expired state, not the failure state', (
    tester,
  ) async {
    final env = await CheckoutEnv.open(
      tester,
      arrange: (layer) async {
        await layer.settings.set(
          SettingKeys.holdMinutes,
          1,
          const SettingScope.university(),
          actorId: 'admin',
        );
        await layer.settings.set(
          SettingKeys.holdMaxMinutes,
          5,
          const SettingScope.university(),
          actorId: 'admin',
        );
      },
    );
    // A payment is started and the page is left open and unanswered.
    await tester.tap(find.byKey(CheckoutScreen.payKey));
    await tester.pumpAndSettle();
    final id = await env.sessionId();
    routerOf(tester).pop();
    await tester.pumpAndSettle();

    await env.advance(const Duration(seconds: 61)); // extended to the maximum
    expect((await env.reload()).status, BookingStatus.pendingPayment);
    env.gateway.outcome = const FakeOutcome.fail();
    env.gateway.confirm(id, cardLast4: '4242');
    await env.advance(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect((await env.reload()).status, BookingStatus.expired);
    expect(find.byKey(ExpiredView.titleKey), findsOneWidget);
    expect(find.text(ar.checkoutFailedTitle), findsNothing);
  });
}
