import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/payments/data/in_memory_payment_repository.dart';
import 'package:sprint/features/payments/domain/payment.dart';

Payment _p(String id, String booking, DateTime started,
        {String? receipt, PaymentStatus status = PaymentStatus.pending}) =>
    Payment(
      id: id,
      bookingId: booking,
      provider: 'FAKE',
      providerRef: id,
      amount: 10,
      status: status,
      startedAt: started,
      owningUnitId: 'ou1',
      receiptNumber: receipt,
    );

void main() {
  test('latestPayment is the most recently started attempt', () async {
    final repo = InMemoryPaymentRepository();
    expect(await repo.latestPayment('b1'), isNull);
    await repo.savePayment(_p('a', 'b1', DateTime.utc(2026, 11, 1, 10)));
    await repo.savePayment(_p('b', 'b1', DateTime.utc(2026, 11, 1, 11)));
    await repo.savePayment(_p('c', 'b2', DateTime.utc(2026, 11, 1, 12)));
    expect((await repo.latestPayment('b1'))!.id, 'b');
  });

  test('receipt numbers run per day from 0001 and reset on a new day',
      () async {
    final repo = InMemoryPaymentRepository();
    final d1 = DateTime(2026, 11, 8, 17);
    final d2 = DateTime(2026, 11, 9, 9);
    expect(await repo.nextReceiptNumber(d1), 'RC-261108-0001');
    await repo.savePayment(
        _p('a', 'b1', d1, receipt: 'RC-261108-0001', status: PaymentStatus.succeeded));
    expect(await repo.nextReceiptNumber(d1), 'RC-261108-0002');
    expect(await repo.nextReceiptNumber(d2), 'RC-261109-0001');
    await repo.savePayment(
        _p('b', 'b2', d1, receipt: 'RC-261108-0482', status: PaymentStatus.succeeded));
    expect(await repo.nextReceiptNumber(d1), 'RC-261108-0483');
  });
}
