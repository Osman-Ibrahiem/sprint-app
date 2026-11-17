import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/payments/domain/payment.dart';
import 'package:sprint/features/payments/domain/receipt.dart';

import '../../../helpers/domain_builders.dart';

void main() {
  final start = cairo(2026, 11, 20, 17);
  final b = booking(start: start, tier: PriceTier.internal, price: 80);
  final f = facility();
  final u = unit();
  final paidAt = cairo(2026, 11, 18, 9);

  Payment payment({
    PaymentStatus status = PaymentStatus.succeeded,
    String? receipt = 'RC-261118-0001',
    String? last4 = '4242',
    DateTime? at,
  }) =>
      Payment(
        id: 'pay-1',
        bookingId: b.id,
        provider: 'FAKE',
        providerRef: 'FAKE-pay-1',
        amount: 80,
        status: status,
        startedAt: paidAt,
        paidAt: at ?? paidAt,
        owningUnitId: 'ou1',
        cardLast4: last4,
        receiptNumber: receipt,
      );

  test('builds every field from a succeeded payment', () {
    final r = Receipt.fromPayment(payment(), b, f, u)!;
    expect(r.number, 'RC-261118-0001');
    expect(r.bookingCode, b.code);
    expect(r.paidAt, paidAt);
    expect(r.facilityName, f.name);
    expect(r.unitName, u.name);
    expect(r.tier, PriceTier.internal);
    expect(r.amount, 80);
    expect(r.isTest, isTrue);
    expect(r.cardLast4, matches(RegExp(r'^\d{4}$')));
  });

  test('no receipt unless the payment succeeded with a number', () {
    expect(Receipt.fromPayment(payment(status: PaymentStatus.failed), b, f, u),
        isNull);
    expect(Receipt.fromPayment(payment(receipt: null), b, f, u), isNull);
  });

  test('card digits other than exactly four are refused', () {
    expect(Receipt.fromPayment(payment(last4: '4242424242424242'), b, f, u),
        isNull);
    expect(Receipt.fromPayment(payment(last4: '42'), b, f, u), isNull);
  });
}
