/// The only definitions of the auth limits (FR-005, FR-010, clarify Q4).
abstract final class AuthLimits {
  /// Digits in a confirmation or reset code.
  static const int codeLength = 6;

  /// How long a code stays valid.
  static const Duration codeLife = Duration(minutes: 15);

  /// Wrong tries allowed on one code.
  static const int maxCodeTries = 5;

  /// Wait before a new code can be sent.
  static const Duration resendWait = Duration(seconds: 60);

  /// Wrong passwords in a row before the lockout.
  static const int maxPasswordFailures = 5;

  /// How long sign in waits after [maxPasswordFailures].
  static const Duration lockoutDuration = Duration(minutes: 5);
}
