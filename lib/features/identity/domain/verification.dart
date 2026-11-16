import 'package:freezed_annotation/freezed_annotation.dart';

part 'verification.freezed.dart';
part 'verification.g.dart';

enum VerificationType { student, staff, faculty }

enum VerificationStatus { pending, approved, rejected }

enum VerificationMethod { auto, manual }

/// A request to be priced as internal (BR-22 – BR-26). A rejection carries a
/// reason shown to the user (BR-26).
@freezed
abstract class Verification with _$Verification {
  const Verification._();

  const factory Verification({
    required String id,
    required String userId,
    required VerificationType type,
    required String nationalId,

    /// University or staff code: 1 to 20 digits or letters.
    required String code,
    required String owningUnitId,
    required VerificationStatus status,
    required VerificationMethod method,
    required DateTime submittedAt,
    String? photoId,
    String? reviewerId,

    /// Required (at least 10 characters) when rejected (BR-26).
    String? reason,
    DateTime? decidedAt,
    DateTime? expiresAt,
  }) = _Verification;

  factory Verification.fromJson(Map<String, dynamic> json) =>
      _$VerificationFromJson(json);

  /// Approved and past its expiry: the derived `expired` state (BR-25).
  bool isExpiredAt(DateTime now) =>
      status == VerificationStatus.approved &&
      expiresAt != null &&
      !now.isBefore(expiresAt!);

  /// Approved and not past its expiry (BR-25).
  bool isActiveAt(DateTime now) =>
      status == VerificationStatus.approved &&
      expiresAt != null &&
      now.isBefore(expiresAt!);
}

