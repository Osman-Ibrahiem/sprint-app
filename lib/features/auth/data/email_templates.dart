import 'package:sprint/features/auth/domain/email_code.dart';

/// The neutral template: a plain subject naming the purpose and a body that is
/// just the code. The UI layer replaces it with a localised one through
/// `emailTemplateProvider` (the mailbox calls it at send time, so a language
/// change applies to new emails). Same shape as `EmailTemplate` in
/// `simulated_mailbox.dart`.
({String subject, String body}) defaultEmailTemplate(
  CodePurpose purpose,
  String code,
) => (subject: 'Sprint: ${purpose.name}', body: code);
