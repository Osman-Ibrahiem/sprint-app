import 'package:sprint/features/identity/domain/verification.dart';

/// What the person sees about their verification (FR-029, BR-24 – BR-26):
/// the stored status plus the derived `expired` (BR-25).
enum VerificationState { none, underReview, approved, rejected, expired }

/// What the person can do next from [VerificationState] (FR-029, FR-030).
enum VerificationNextAction { request, wait, renew, requestAgain, none }

/// The state of the person's latest request [v] at [now]; `none` when they
/// never sent one.
VerificationState verificationStateOf(Verification? v, DateTime now) {
  if (v == null) return VerificationState.none;
  return switch (v.status) {
    VerificationStatus.pending => VerificationState.underReview,
    VerificationStatus.rejected => VerificationState.rejected,
    VerificationStatus.approved =>
      v.isExpiredAt(now)
          ? VerificationState.expired
          : VerificationState.approved,
  };
}

extension VerificationStateNext on VerificationState {
  VerificationNextAction get nextAction => switch (this) {
    VerificationState.none => VerificationNextAction.request,
    VerificationState.underReview => VerificationNextAction.wait,
    VerificationState.approved => VerificationNextAction.none,
    VerificationState.rejected => VerificationNextAction.requestAgain,
    VerificationState.expired => VerificationNextAction.renew,
  };
}
