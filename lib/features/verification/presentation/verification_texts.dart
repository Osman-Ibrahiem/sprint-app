import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/features/identity/domain/verification.dart';
import 'package:sprint/features/verification/data/in_memory_verification_repository.dart'
    show duplicateNationalIdReason;
import 'package:sprint/features/verification/domain/national_id.dart';
import 'package:sprint/features/verification/domain/verification_state.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The words for verification enums. Domain code holds typed reasons; only
/// the presentation layer turns them into text.
String verificationTypeLabel(AppLocalizations l10n, VerificationType t) =>
    switch (t) {
      VerificationType.student => l10n.verifTypeStudent,
      VerificationType.staff => l10n.verifTypeStaff,
      VerificationType.faculty => l10n.verifTypeFaculty,
    };

String verificationStateWord(AppLocalizations l10n, VerificationState s) =>
    switch (s) {
      VerificationState.none => l10n.verifStatusNone,
      VerificationState.underReview => l10n.statusUnderReview,
      VerificationState.approved => l10n.statusVerified,
      VerificationState.rejected => l10n.statusRejected,
      VerificationState.expired => l10n.verifStatusExpired,
    };

String nationalIdMessage(AppLocalizations l10n, NationalIdProblem p) =>
    switch (p) {
      NationalIdProblem.empty => l10n.verifErrNationalIdEmpty,
      NationalIdProblem.notFourteenDigits => l10n.verifErrNationalIdLength,
      NationalIdProblem.invalidCentury => l10n.verifErrNationalIdCentury,
      NationalIdProblem.invalidBirthDate => l10n.verifErrNationalIdBirthDate,
      NationalIdProblem.futureBirthDate => l10n.verifErrNationalIdFuture,
      NationalIdProblem.invalidGovernorate =>
        l10n.verifErrNationalIdGovernorate,
    };

/// The message for a repository `InvalidField(field, reason)` of the request
/// form, or null when the field is not one this form knows.
String? verificationFieldMessage(
  AppLocalizations l10n,
  String field,
  String reason,
) {
  switch (field) {
    case 'nationalId':
      for (final p in NationalIdProblem.values) {
        if (p.name == reason) return nationalIdMessage(l10n, p);
      }
      return l10n.verifErrNationalIdLength;
    case 'code':
      return l10n.verifErrCodeInvalid;
    case 'owningUnitId':
      return l10n.verifErrUnitEmpty;
    case 'photo':
      return l10n.verifErrPhotoEmpty;
  }
  return null;
}

/// A rejection reason as shown to the person: automatic refusals carry a
/// code, a reviewer's reason is their own text (BR-26, BR-27).
String verificationReasonText(AppLocalizations l10n, String reason) =>
    reason == duplicateNationalIdReason ? l10n.verifReasonDuplicate : reason;

/// How long a request has been waiting, in the largest whole unit (FR-031).
String verificationWaitText(
  AppLocalizations l10n,
  SprintFormat format,
  Duration waited,
) {
  if (waited.inDays >= 1) return l10n.verifRevWaitDays(waited.inDays);
  if (waited.inHours >= 1) return l10n.verifRevWaitHours(waited.inHours);
  return l10n.verifRevWaitMinutes(waited.inMinutes < 0 ? 0 : waited.inMinutes);
}
