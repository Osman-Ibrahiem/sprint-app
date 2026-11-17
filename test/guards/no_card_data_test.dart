import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TextField;
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/booking/presentation/checkout/checkout_screen.dart';
import 'package:sprint/features/payments/presentation/fake_gateway_screen.dart';

import '../features/booking/presentation/checkout/checkout_harness.dart';

/// SC-006, FR-009: after a full payment with a test card, nothing but the last
/// four digits exists anywhere the app keeps or prints data. The card used
/// here has values that cannot appear by chance elsewhere.
void main() {
  const number = '4000 0566 5566 5556';
  const expiry = '09/31';
  const cvc = '738';
  const holder = 'حامل بطاقة فريد';

  testWidgets('the snapshot, the payments, the notifications and the logs '
      'hold no card number, expiry, security code or holder name',
      (tester) async {
    final logs = <String>[];
    final oldPrint = debugPrint;
    debugPrint = (message, {wrapWidth}) => logs.add(message ?? '');

    final env = await CheckoutEnv.open(tester);
    await tester.tap(find.byKey(CheckoutScreen.payKey));
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), number);
    await tester.enterText(fields.at(1), expiry);
    await tester.enterText(fields.at(2), cvc);
    await tester.enterText(fields.at(3), holder);
    await tester.pump();
    await tester.ensureVisible(find.byKey(confirmKey));
    await tester.tap(find.byKey(confirmKey));
    await tester.pumpAndSettle();
    await env.advance(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Back to the real printer before anything can fail.
    debugPrint = oldPrint;

    final payment = (await env.layer.payments.latestPayment(env.booking.id))!;
    expect(payment.cardLast4, '5556');

    final haystacks = <String, String>{
      'snapshot': jsonEncode(env.layer.toSnapshot()),
      'payments': jsonEncode(
        [for (final p in env.layer.payments.allPayments) p.toJson()],
      ),
      'notifications': jsonEncode(
        [for (final n in env.layer.notifications.all) n.payload],
      ),
      'logs': logs.join('\n'),
    };
    final digits = number.replaceAll(' ', '');
    for (final entry in haystacks.entries) {
      final text = entry.value;
      expect(text, isNot(contains(digits)), reason: '${entry.key}: number');
      expect(text, isNot(contains(number)), reason: '${entry.key}: number');
      expect(text, isNot(contains('4000 0566')), reason: '${entry.key}: part');
      expect(text, isNot(contains(expiry)), reason: '${entry.key}: expiry');
      expect(text, isNot(contains(expiry.replaceAll('/', ''))),
          reason: '${entry.key}: expiry');
      expect(RegExp('(^|[^0-9])$cvc([^0-9]|\$)').hasMatch(text), isFalse,
          reason: '${entry.key}: security code');
      expect(text, isNot(contains(holder)), reason: '${entry.key}: holder');
    }

    // Payments and notification payloads: no run of twelve digits at all.
    for (final key in ['payments', 'notifications']) {
      expect(RegExp(r'\d{12,}').hasMatch(haystacks[key]!), isFalse, reason: key);
    }
    // The last four digits are the only card data stored.
    expect(haystacks['payments'], contains('5556'));
  });
}
