import 'package:sprint/features/auth/domain/validators.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The words for each validation reason (FR-002). Reasons are typed in the
/// domain; only the presentation layer turns them into text.
String nameMessage(AppLocalizations l10n, NameProblem p) => switch (p) {
  NameProblem.empty => l10n.validationNameEmpty,
  NameProblem.tooShort => l10n.validationNameTooShort,
  NameProblem.tooLong => l10n.validationNameTooLong,
  NameProblem.needsTwoWords => l10n.validationNameNeedsTwoWords,
  NameProblem.invalidCharacters => l10n.validationNameInvalidCharacters,
};

String phoneMessage(AppLocalizations l10n, PhoneProblem p) => switch (p) {
  PhoneProblem.empty => l10n.validationPhoneEmpty,
  PhoneProblem.invalid => l10n.validationPhoneInvalid,
};

String emailMessage(AppLocalizations l10n, EmailProblem p) => switch (p) {
  EmailProblem.empty => l10n.validationEmailEmpty,
  EmailProblem.invalid => l10n.validationEmailInvalid,
};

String passwordMessage(AppLocalizations l10n, PasswordProblem p) => switch (p) {
  PasswordProblem.empty => l10n.validationPasswordEmpty,
  PasswordProblem.tooShort => l10n.validationPasswordTooShort,
  PasswordProblem.needsLetter => l10n.validationPasswordNeedsLetter,
  PasswordProblem.needsDigit => l10n.validationPasswordNeedsDigit,
};

/// The message for a repository `InvalidField(field, reason)`, or null when
/// the field or reason is not one this form knows.
String? invalidFieldMessage(
  AppLocalizations l10n,
  String field,
  String reason,
) {
  T? byName<T extends Enum>(List<T> values) {
    for (final v in values) {
      if (v.name == reason) return v;
    }
    return null;
  }

  return switch (field) {
    'name' => switch (byName(NameProblem.values)) {
      final NameProblem p => nameMessage(l10n, p),
      _ => null,
    },
    'phone' => switch (byName(PhoneProblem.values)) {
      final PhoneProblem p => phoneMessage(l10n, p),
      _ => null,
    },
    'email' => switch (byName(EmailProblem.values)) {
      final EmailProblem p => emailMessage(l10n, p),
      _ => null,
    },
    'password' => switch (byName(PasswordProblem.values)) {
      final PasswordProblem p => passwordMessage(l10n, p),
      _ => null,
    },
    _ => null,
  };
}
