import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sprint/features/catalogue/domain/price.dart';

part 'verification.freezed.dart';

enum VerificationType { student, staff, faculty }

enum VerificationStatus { pending, approved, rejected }

enum VerificationMethod { auto, manual }

/// A request to be priced as internal (BR-22 – BR-26). A rejection carries a
/// reason shown to the user (BR-26).
@freezed
abstract class Verification with _$Verification {
  const Verification._();

  const factory Verification({
    required String userId,
    required VerificationType type,
    required VerificationStatus status,
    required VerificationMethod method,
    String? reason,
    DateTime? expiresAt,
  }) = _Verification;

  /// Approved and not past its expiry (BR-25).
  bool isActiveAt(DateTime now) =>
      status == VerificationStatus.approved &&
      expiresAt != null &&
      now.isBefore(expiresAt!);
}

/// The tier of a user at [now]: internal only with an active verification,
/// otherwise external (BR-21, BR-24, BR-25).
PriceTier tierAt(Verification? verification, DateTime now) =>
    verification != null && verification.isActiveAt(now)
        ? PriceTier.internal
        : PriceTier.external;
