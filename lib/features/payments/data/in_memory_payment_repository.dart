import 'package:sprint/core/data/change_signal.dart';
import 'package:sprint/features/payments/domain/payment.dart';
import 'package:sprint/features/payments/domain/payment_repository.dart';
import 'package:sprint/features/payments/domain/refund.dart';

class InMemoryPaymentRepository with ChangeSignal implements PaymentRepository {
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
  Future<Payment?> latestPayment(String bookingId) async {
    Payment? latest;
    for (final p in _payments) {
      if (p.bookingId != bookingId) continue;
      if (latest == null || !p.startedAt.isBefore(latest.startedAt)) latest = p;
    }
    return latest;
  }

  @override
  Future<String> nextReceiptNumber(DateTime paidAtCairo) async {
    final day = '${(paidAtCairo.year % 100).toString().padLeft(2, '0')}'
        '${paidAtCairo.month.toString().padLeft(2, '0')}'
        '${paidAtCairo.day.toString().padLeft(2, '0')}';
    final prefix = 'RC-$day-';
    var highest = 0;
    for (final p in _payments) {
      final n = p.receiptNumber;
      if (n != null && n.startsWith(prefix)) {
        final k = int.tryParse(n.substring(prefix.length));
        if (k != null && k > highest) highest = k;
      }
    }
    return '$prefix${(highest + 1).toString().padLeft(4, '0')}';
  }

  @override
  Future<void> savePayment(Payment payment) async {
    _payments.removeWhere((p) => p.id == payment.id);
    _payments.add(payment);
    notifyChanged();
  }

  @override
  Future<void> saveRefund(Refund refund) async {
    _refunds.removeWhere((r) => r.id == refund.id);
    _refunds.add(refund);
    notifyChanged();
  }

  /// Everything, for the demo snapshot.
  List<Payment> get allPayments => List.unmodifiable(_payments);
  List<Refund> get allRefunds => List.unmodifiable(_refunds);
}
