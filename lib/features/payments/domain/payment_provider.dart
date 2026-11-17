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
  const PaymentSession({
    required this.id,
    required this.bookingId,
    required this.checkoutLocation,
  });
  final String id;
  final String bookingId;

  /// Where the booker is sent to pay: the in-app `/pay/sandbox/<id>` for the
  /// fake provider, the gateway's page for a real one.
  final Uri checkoutLocation;
}

/// What a provider reports for a payment. [cardLast4] comes only with
/// `succeeded`; no other card data crosses this interface (FR-009).
class PaymentUpdate {
  const PaymentUpdate(this.status, {this.cardLast4});
  final PaymentStatus status;
  final String? cardLast4;

  @override
  bool operator ==(Object other) =>
      other is PaymentUpdate &&
      other.status == status &&
      other.cardLast4 == cardLast4;

  @override
  int get hashCode => Object.hash(status, cardLast4);

  @override
  String toString() => 'PaymentUpdate($status, $cardLast4)';
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
  /// Opens a payment for [request]. The booker is sent to
  /// `session.checkoutLocation`.
  Future<PaymentSession> start(PaymentRequest request);

  /// `pending`, then exactly one of `succeeded`, `failed` or `cancelled`.
  Stream<PaymentUpdate> watch(PaymentSession session);

  /// Rebuilds the session of a stored [payment], so a payment still pending
  /// after a restart can be watched again (FR-024).
  PaymentSession sessionFor(Payment payment);

  /// An immediate read ("تحديث الحالة"). Never changes the payment.
  Future<PaymentUpdate> status(PaymentSession session);

  Future<RefundResult> refund(Payment payment, int amount);
}
