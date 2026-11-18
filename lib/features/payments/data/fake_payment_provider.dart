import 'package:sprint/features/payments/data/fake_gateway_controller.dart';
import 'package:sprint/features/payments/domain/payment.dart';
import 'package:sprint/features/payments/domain/payment_provider.dart';

/// Stands in for the sandbox gateway in P1. A session stays `pending` until
/// the simulated provider page (through [gateway]) confirms or cancels it;
/// then it answers by the demo outcome (R5).
class FakePaymentProvider implements PaymentProvider {
  FakePaymentProvider({
    Duration delay = const Duration(milliseconds: 600),
    this.name = 'FAKE',
    int startAt = 0,
    FakeGatewayController? controller,
  })  : gateway = controller ?? FakeGatewayController(baseDelay: delay),
        _n = startAt;

  final String name;

  /// What the fake page and `/demo` use to drive this provider.
  final FakeGatewayController gateway;

  int _n;

  @override
  Future<PaymentSession> start(PaymentRequest request) async {
    _n++;
    final id = '$name-pay-$_n';
    gateway.register(id, request.bookingId, request.amount);
    return PaymentSession(
      id: id,
      bookingId: request.bookingId,
      checkoutLocation: Uri(path: '/pay/sandbox/$id'),
    );
  }

  @override
  PaymentSession sessionFor(Payment payment) => PaymentSession(
        id: payment.providerRef,
        bookingId: payment.bookingId,
        checkoutLocation: Uri(path: '/pay/sandbox/${payment.providerRef}'),
      );

  @override
  Stream<PaymentUpdate> watch(PaymentSession session) async* {
    yield const PaymentUpdate(PaymentStatus.pending);
    yield await gateway.doneOf(session);
  }

  @override
  Future<PaymentUpdate> status(PaymentSession session) async =>
      gateway.latestOf(session);

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
