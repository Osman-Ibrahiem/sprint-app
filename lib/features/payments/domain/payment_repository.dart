import 'package:sprint/features/payments/domain/payment.dart';
import 'package:sprint/features/payments/domain/refund.dart';

abstract interface class PaymentRepository {
  Future<List<Payment>> payments(String bookingId);
  Future<List<Refund>> refunds(String paymentId);

  /// Written by the booking flow after the provider answers.
  Future<void> savePayment(Payment payment);
  Future<void> saveRefund(Refund refund);
}
