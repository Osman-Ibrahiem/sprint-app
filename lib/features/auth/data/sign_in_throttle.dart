/// Wrong-password counter for one normalised sign-in identifier, kept whether
/// or not an account exists so the lockout never reveals one (FR-010).
class SignInThrottle {
  SignInThrottle({this.failures = 0, this.lockedUntil});

  int failures;
  DateTime? lockedUntil;

  factory SignInThrottle.fromJson(Map<String, dynamic> json) => SignInThrottle(
    failures: json['failures'] as int? ?? 0,
    lockedUntil: json['lockedUntil'] == null
        ? null
        : DateTime.parse(json['lockedUntil'] as String),
  );

  Map<String, dynamic> toJson() => {
    'failures': failures,
    'lockedUntil': lockedUntil?.toIso8601String(),
  };
}
