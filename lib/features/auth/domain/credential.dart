import 'package:freezed_annotation/freezed_annotation.dart';

part 'credential.freezed.dart';
part 'credential.g.dart';

/// Password material, kept apart from `User` so a real auth provider replaces
/// it alone. [hash] is never logged or shown (FR-044, research R3).
/// [failedAttempts] and [lockedUntil] are the sign-in throttle (FR-010).
@freezed
abstract class Credential with _$Credential {
  const factory Credential({
    required String userId,
    required String salt,
    required String hash,
    @Default(0) int failedAttempts,
    DateTime? lockedUntil,
  }) = _Credential;

  factory Credential.fromJson(Map<String, dynamic> json) =>
      _$CredentialFromJson(json);
}
