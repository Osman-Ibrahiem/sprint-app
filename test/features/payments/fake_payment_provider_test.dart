import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/payments/data/fake_payment_provider.dart';
import 'package:sprint/features/payments/domain/payment.dart';
import 'package:sprint/features/payments/domain/payment_provider.dart';

/// A second implementation, to prove callers cannot tell providers apart.
class _OtherProvider implements PaymentProvider {
  @override
  Future<PaymentSession> start(PaymentRequest request) async =>
      PaymentSession(id: 'x-1', bookingId: request.bookingId);

  @override
  Stream<PaymentStatus> watch(PaymentSession session) =>
      Stream.fromIterable([PaymentStatus.pending, PaymentStatus.succeeded]);

  @override
  Future<RefundResult> refund(Payment payment, int amount) async =>
      RefundResult(reference: 'r-x', amount: amount, succeeded: true);
}

/// Caller code: it only knows the interface.
Future<List<PaymentStatus>> pay(PaymentProvider p, {int amount = 120}) async {
  final session = await p.start(
    PaymentRequest(amount: amount, bookingId: 'b1', owningUnitId: 'ou1'),
  );
  return p.watch(session).toList();
}

void main() {
  const payment = Payment(
    id: 'p1',
    bookingId: 'b1',
    provider: 'FAKE',
    providerRef: 'ref',
    amount: 120,
    status: PaymentStatus.succeeded,
    owningUnitId: 'ou1',
  );

  test('success: pending then succeeded', () async {
    final p = FakePaymentProvider(delay: Duration.zero);
    expect(await pay(p), [PaymentStatus.pending, PaymentStatus.succeeded]);
  });

  test('forced failure: pending then failed, then back to success', () async {
    final p = FakePaymentProvider(delay: Duration.zero)..failNext = true;
    expect(await pay(p), [PaymentStatus.pending, PaymentStatus.failed]);
    // The hook is one-shot.
    expect(await pay(p), [PaymentStatus.pending, PaymentStatus.succeeded]);
  });

  test('a session belongs to its booking', () async {
    final p = FakePaymentProvider(delay: Duration.zero);
    final s = await p.start(
      const PaymentRequest(amount: 50, bookingId: 'bk-9', owningUnitId: 'ou1'),
    );
    expect(s.bookingId, 'bk-9');
    expect(s.id, isNotEmpty);
  });

  test('refund returns a successful result for the amount', () async {
    final p = FakePaymentProvider(delay: Duration.zero);
    final r = await p.refund(payment, 60);
    expect(r.succeeded, isTrue);
    expect(r.amount, 60);
    expect(r.reference, isNotEmpty);
  });

  test('a refund above the paid amount is refused', () async {
    final p = FakePaymentProvider(delay: Duration.zero);
    final r = await p.refund(payment, 121);
    expect(r.succeeded, isFalse);
  });

  test('the caller cannot tell which provider answered (FR-025)', () async {
    final a = await pay(FakePaymentProvider(delay: Duration.zero));
    final b = await pay(_OtherProvider());
    expect(a, b);

    final sa = await FakePaymentProvider(delay: Duration.zero).start(
      const PaymentRequest(amount: 1, bookingId: 'b', owningUnitId: 'o'),
    );
    final sb = await _OtherProvider().start(
      const PaymentRequest(amount: 1, bookingId: 'b', owningUnitId: 'o'),
    );
    expect(sa.runtimeType, sb.runtimeType);
  });

  test('the delay is honoured before the final status', () async {
    final p = FakePaymentProvider(delay: const Duration(milliseconds: 30));
    final sw = Stopwatch()..start();
    await pay(p);
    expect(sw.elapsedMilliseconds, greaterThanOrEqualTo(25));
  });
}
