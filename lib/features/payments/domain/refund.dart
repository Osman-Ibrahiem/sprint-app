import 'package:freezed_annotation/freezed_annotation.dart';

part 'refund.freezed.dart';

enum RefundStatus { succeeded, failed }

/// A refund of at most the paid amount (BR-31, BR-33).
@freezed
abstract class Refund with _$Refund {
  const factory Refund({
    required String id,
    required String paymentId,
    required int amount,
    required String reason,
    required RefundStatus status,
  }) = _Refund;
}
