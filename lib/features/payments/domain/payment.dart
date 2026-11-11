import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment.freezed.dart';

/// What a payment provider reports (BR-28: a booking is confirmed only from
/// this, never from the UI).
enum PaymentStatus { pending, succeeded, failed }

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
    DateTime? paidAt,
    required String owningUnitId,
  }) = _Payment;
}
