import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/widgets/booking_ticket/booking_ticket.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/presentation/checkout/checkout_screen.dart';
import 'package:sprint/features/booking/presentation/confirmed/booking_confirmed_screen.dart';

import '../features/booking/presentation/checkout/checkout_harness.dart';
import '../features/booking/presentation/schedule_harness.dart' show currentUri;
import '../helpers/pump_app.dart';

/// US-12: after the provider confirms, the booker sees the ticket (code, QR,
/// status), when they can still cancel, the reminder lead, and the receipt.
void main() {
  testWidgets('a successful payment ends on the ticket with its receipt entry',
      (tester) async {
    final env = await CheckoutEnv.open(tester);
    await tester.tap(find.byKey(CheckoutScreen.payKey));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '4242424242424242');
    await tester.enterText(fields.at(1), '1230');
    await tester.enterText(fields.at(2), '123');
    await tester.enterText(fields.at(3), 'منى');
    await tester.pump();
    await tester.ensureVisible(find.text(ar.gatewayConfirm('140 ج.م')));
    await tester.tap(find.text(ar.gatewayConfirm('140 ج.م')));
    await tester.pumpAndSettle();
    await env.advance(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.byType(BookingConfirmedScreen), findsOneWidget);
    expect(find.text(ar.confirmedTitle), findsWidgets);
    expect(find.text(env.booking.code), findsOneWidget);
    expect(find.byKey(BookingTicket.qrKey), findsOneWidget);
    expect(find.text(ar.statusConfirmed), findsWidgets);
    expect(find.text(ar.ticketPaid), findsOneWidget);
    expect(find.textContaining('الإلغاء متاح لحد'), findsOneWidget);
    expect(find.text(ar.confirmedSubtitle('3 ساعات')), findsOneWidget);
    expect((await env.reload()).status, BookingStatus.confirmed);

    await tester.tap(find.byKey(BookingConfirmedScreen.receiptKey));
    await tester.pumpAndSettle();
    expect(currentUri(tester).path, AppPaths.bookingReceipt(env.booking.id));
  });
}
