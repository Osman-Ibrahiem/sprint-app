import 'package:sprint/features/auth/domain/auth_limits.dart';
import 'package:sprint/features/auth/domain/email_code.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The neutral template: a plain subject naming the purpose and a body that is
/// just the code. The UI layer replaces it with a localised one through
/// `emailTemplateProvider` (the mailbox calls it at send time, so a language
/// change applies to new emails). Same shape as `EmailTemplate` in
/// `simulated_mailbox.dart`.
({String subject, String body}) defaultEmailTemplate(
  CodePurpose purpose,
  String code,
) => (subject: 'Sprint: ${purpose.name}', body: code);

/// The localised template: subject and body in the language of [l10n], with
/// the code and its life from [AuthLimits]. The mailbox looks for the first
/// six-digit run in the body, so nothing else in it may be one.
({String subject, String body}) localizedEmailTemplate(
  AppLocalizations l10n,
  CodePurpose purpose,
  String code,
) {
  final minutes = AuthLimits.codeLife.inMinutes;
  return switch (purpose) {
    CodePurpose.confirmEmail => (
      subject: l10n.emailConfirmSubject,
      body: l10n.emailConfirmBody(code, minutes),
    ),
    CodePurpose.resetPassword => (
      subject: l10n.emailResetSubject,
      body: l10n.emailResetBody(code, minutes),
    ),
  };
}
