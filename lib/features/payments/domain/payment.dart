import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment.freezed.dart';
part 'payment.g.dart';

/// What a payment provider reports (BR-28: a booking is confirmed only from
/// this, never from the UI). `cancelled` is the booker backing out on the
/// provider's page (BR-47): not a failure, and the attempt stays recorded.
enum PaymentStatus { pending, succeeded, failed, cancelled }

/// A recorded payment, attributed to the owning unit (BR-33).
@freezed
abstract class Payment with _$Payment {
  const factory Payment({
    required String id,
    required String bookingId,
    required String provider,
    required String providerRef,
    required int amount,
    required PaymentStatus status,
    /// When the provider page was opened.
    required DateTime startedAt,
    DateTime? paidAt,
    required String owningUnitId,

    /// The only card data ever stored (FR-009): four digits, reported by the
    /// provider with `succeeded`.
    String? cardLast4,

    /// `RC-yyMMdd-NNNN`, assigned on `succeeded` (FR-025).
    String? receiptNumber,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
}
