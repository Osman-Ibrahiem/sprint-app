import 'package:sprint/features/payments/domain/payment.dart';
import 'package:sprint/features/payments/domain/payment_repository.dart';
import 'package:sprint/features/payments/domain/refund.dart';

class InMemoryPaymentRepository implements PaymentRepository {
  InMemoryPaymentRepository({
    Iterable<Payment> payments = const [],
    Iterable<Refund> refunds = const [],
  })  : _payments = [...payments],
        _refunds = [...refunds];

  final List<Payment> _payments;
  final List<Refund> _refunds;

  @override
  Future<List<Payment>> payments(String bookingId) async =>
      _payments.where((p) => p.bookingId == bookingId).toList();

  @override
  Future<List<Refund>> refunds(String paymentId) async =>
      _refunds.where((r) => r.paymentId == paymentId).toList();

  @override
  Future<void> savePayment(Payment payment) async {
    _payments.removeWhere((p) => p.id == payment.id);
    _payments.add(payment);
  }

  @override
  Future<void> saveRefund(Refund refund) async {
    _refunds.removeWhere((r) => r.id == refund.id);
    _refunds.add(refund);
  }
}
