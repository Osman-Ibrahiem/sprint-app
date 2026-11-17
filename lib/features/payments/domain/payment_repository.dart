import 'package:sprint/features/payments/domain/payment.dart';
import 'package:sprint/features/payments/domain/refund.dart';

abstract interface class PaymentRepository {
  Future<List<Payment>> payments(String bookingId);
  Future<List<Refund>> refunds(String paymentId);

  /// The most recent attempt for a booking, or null.
  Future<Payment?> latestPayment(String bookingId);

  /// `RC-` + `yyMMdd` + `-` + a 4-digit sequence per day starting at 0001
  /// (FR-025). [paidAtCairo] is the payment time in Cairo.
  Future<String> nextReceiptNumber(DateTime paidAtCairo);

  /// Written by the booking flow after the provider answers.
  Future<void> savePayment(Payment payment);
  Future<void> saveRefund(Refund refund);
}
