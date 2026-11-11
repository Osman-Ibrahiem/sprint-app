import 'package:sprint/features/payments/domain/payment.dart';

export 'package:sprint/features/payments/domain/payment.dart' show PaymentStatus;

/// Which provider the `paymentProvider` setting names (BR-29). `fake` and
/// `sandbox` are P1; the university platform joins in P2.
enum PaymentProviderKind { fake, sandbox }

class PaymentRequest {
  const PaymentRequest({
    required this.amount,
    required this.bookingId,
    required this.owningUnitId,
  });

  /// Whole Egyptian pounds.
  final int amount;
  final String bookingId;
  final String owningUnitId;
}

class PaymentSession {
  const PaymentSession({required this.id, required this.bookingId});
  final String id;
  final String bookingId;
}

class RefundResult {
  const RefundResult({
    required this.reference,
    required this.amount,
    required this.succeeded,
  });
  final String reference;
  final int amount;
  final bool succeeded;
}

/// The only thing booking code knows about payments. Which gateway answers is
/// a setting, not a code path (BR-29, FR-025). No card data is handled here.
abstract interface class PaymentProvider {
  Future<PaymentSession> start(PaymentRequest request);

  /// `pending`, then `succeeded` or `failed`.
  Stream<PaymentStatus> watch(PaymentSession session);

  Future<RefundResult> refund(Payment payment, int amount);
}
