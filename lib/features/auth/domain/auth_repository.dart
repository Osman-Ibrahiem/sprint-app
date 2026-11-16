import 'package:sprint/core/result/result.dart';
import 'package:sprint/features/auth/domain/email_code.dart';

/// Sign up made an `unconfirmed` account and sent a `confirmEmail` code.
final class PendingConfirmation {
  const PendingConfirmation({required this.userId, required this.email});
  final String userId;
  final String email;
}

/// The session is set to [userId].
final class SignedIn {
  const SignedIn(this.userId);
  final String userId;
}

/// A code was sent (or looks sent: unknown accounts get this too, FR-021);
/// another can be asked for after [resendAfter].
final class CodeSent {
  const CodeSent(this.resendAfter);
  final DateTime resendAfter;
}

/// A success with nothing to return.
final class Done {
  const Done();
}

/// Accounts, sessions and email codes (contracts/repositories.md). Business
/// refusals come back as `Err` with the failures in `core/result/failure.dart`:
/// `InvalidField`, `EmailTaken`, `PhoneTaken`, `CodeWrong`, `CodeExpired`,
/// `CodeDead`, `NoPendingConfirmation`, `ResendTooSoon`, `BadCredentials`,
/// `LockedOut`, `Suspended`, `NeedsConfirmation`.
abstract interface class AuthRepository {
  /// Fires after each successful write.
  Stream<void> get changes;

  Future<Result<PendingConfirmation>> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
  });

  Future<Result<SignedIn>> confirmEmail({
    required String email,
    required String code,
  });

  Future<Result<CodeSent>> resendCode({
    required String email,
    required CodePurpose purpose,
  });

  /// [identifier] is an email or a phone number.
  Future<Result<SignedIn>> signIn({
    required String identifier,
    required String password,
  });

  Future<Result<Done>> signOut();

  Future<Result<CodeSent>> requestPasswordReset(String identifier);

  Future<Result<SignedIn>> resetPassword({
    required String identifier,
    required String code,
    required String newPassword,
  });

  /// Null for a guest.
  Future<String?> currentUserId();

  /// Demo only: the user switcher (FR-015). Null returns to guest.
  Future<Result<Done>> actAs(String? userId);
}
