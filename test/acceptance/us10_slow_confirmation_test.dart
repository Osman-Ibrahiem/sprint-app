import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/presentation/checkout/awaiting_view.dart';
import 'package:sprint/features/booking/presentation/checkout/processing_view.dart';
import 'package:sprint/features/booking/presentation/confirmed/booking_confirmed_screen.dart';
import 'package:sprint/features/payments/data/fake_gateway_controller.dart';

import '../features/booking/presentation/checkout/checkout_harness.dart';

/// US-10: a slow provider. Processing, then waiting, then the ticket when the
/// answer arrives (BR-28).
void main() {
  testWidgets('a 30 second confirmation: processing, waiting, ticket',
      (tester) async {
    final env = await CheckoutEnv.open(
      tester,
      outcome: const FakeOutcome.delay(Duration(seconds: 30)),
    );
    await env.payOnPage();
    expect(find.byType(ProcessingView), findsOneWidget);
    await env.advance(const Duration(seconds: 25));
    expect(find.byType(AwaitingView), findsOneWidget);
    await env.advance(const Duration(seconds: 10));
    await tester.pumpAndSettle();
    expect(find.byType(BookingConfirmedScreen), findsOneWidget);
    expect((await env.reload()).status, BookingStatus.confirmed);
  });
}
