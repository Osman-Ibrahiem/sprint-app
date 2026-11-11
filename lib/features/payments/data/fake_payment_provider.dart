import 'package:sprint/features/payments/domain/payment.dart';
import 'package:sprint/features/payments/domain/payment_provider.dart';

/// Succeeds after a short delay. A test hook forces the next payment to fail.
/// Stands in for the sandbox gateway in P1.
class FakePaymentProvider implements PaymentProvider {
  FakePaymentProvider({
    this.delay = const Duration(milliseconds: 600),
    this.name = 'FAKE',
  });

  final Duration delay;
  final String name;

  /// When true, the next payment fails once, then this resets.
  bool failNext = false;

  int _n = 0;
  final Set<String> _failing = {};

  @override
  Future<PaymentSession> start(PaymentRequest request) async {
    _n++;
    final id = '$name-pay-$_n';
    if (failNext) {
      _failing.add(id);
      failNext = false;
    }
    return PaymentSession(id: id, bookingId: request.bookingId);
  }

  @override
  Stream<PaymentStatus> watch(PaymentSession session) async* {
    yield PaymentStatus.pending;
    await Future<void>.delayed(delay);
    yield _failing.remove(session.id)
        ? PaymentStatus.failed
        : PaymentStatus.succeeded;
  }

  @override
  Future<RefundResult> refund(Payment payment, int amount) async {
    final ok = amount >= 0 && amount <= payment.amount;
    return RefundResult(
      reference: '$name-refund-${payment.id}',
      amount: amount,
      succeeded: ok,
    );
  }
}
