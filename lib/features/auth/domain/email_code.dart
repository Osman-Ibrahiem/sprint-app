import 'package:freezed_annotation/freezed_annotation.dart';

part 'email_code.freezed.dart';
part 'email_code.g.dart';

enum CodePurpose { confirmEmail, resetPassword }

/// A 6-digit code sent by email. At most one live code per (user, purpose);
/// sending replaces it, and a used code is deleted (FR-005).
@freezed
abstract class EmailCode with _$EmailCode {
  const factory EmailCode({
    required String userId,
    required CodePurpose purpose,
    required String code,
    required DateTime expiresAt,
    required DateTime resendAfter,
    @Default(0) int wrongTries,
  }) = _EmailCode;

  factory EmailCode.fromJson(Map<String, dynamic> json) =>
      _$EmailCodeFromJson(json);
}
