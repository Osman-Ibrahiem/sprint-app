import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/presentation/confirmed/booking_confirmed_screen.dart';
import 'package:sprint/features/payments/data/fake_gateway_controller.dart';
import 'package:sprint/features/payments/domain/payment.dart';

import '../features/booking/presentation/checkout/checkout_harness.dart';
import '../helpers/pump_app.dart';

/// US-10: the payment fails, the place stays held, the booker tries again and
/// succeeds; both attempts are recorded (BR-33, BR-47).
void main() {
  testWidgets('failure, retry, confirmed: two payment rows', (tester) async {
    final env = await CheckoutEnv.open(tester, outcome: const FakeOutcome.fail());
    await env.payOnPage();
    expect(find.text(ar.checkoutFailedTitle), findsOneWidget);
    expect((await env.reload()).status, BookingStatus.pendingPayment);

    env.gateway.outcome = const FakeOutcome.succeed();
    await env.payOnPage();
    expect(find.byType(BookingConfirmedScreen), findsOneWidget);

    final all = await env.layer.payments.payments(env.booking.id);
    expect(all.map((p) => p.status).toSet(),
        {PaymentStatus.failed, PaymentStatus.succeeded});
    expect(all, hasLength(2));
  });
}
