/// Pure input normalising and validation (research R5, FR-002).
/// Every validator returns a typed reason, never a string; the UI maps
/// reasons to l10n text.
library;

/// Result of a validation: a [Valid] value or an [Invalid] reason.
sealed class Validation<T, R extends Enum> {
  const Validation();

  bool get isValid => this is Valid<T, R>;

  /// The value when valid, otherwise null.
  T? get valueOrNull => switch (this) {
    Valid<T, R>(:final value) => value,
    Invalid<T, R>() => null,
  };

  /// The reason when invalid, otherwise null.
  R? get reasonOrNull => switch (this) {
    Valid<T, R>() => null,
    Invalid<T, R>(:final reason) => reason,
  };
}

final class Valid<T, R extends Enum> extends Validation<T, R> {
  const Valid(this.value);
  final T value;

  @override
  bool operator ==(Object other) =>
      other is Valid<T, R> && other.value == value;

  @override
  int get hashCode => Object.hash(Valid, value);
}

final class Invalid<T, R extends Enum> extends Validation<T, R> {
  const Invalid(this.reason);
  final R reason;

  @override
  bool operator ==(Object other) =>
      other is Invalid<T, R> && other.reason == reason;

  @override
  int get hashCode => Object.hash(Invalid, reason);
}

enum PhoneProblem { empty, invalid }

enum EmailProblem { empty, invalid }

enum NameProblem { empty, tooShort, tooLong, needsTwoWords, invalidCharacters }

enum PasswordProblem { empty, tooShort, needsLetter, needsDigit }

enum IdentifierKind { email, phone }

/// Name length limits (characters, after trimming).
const int nameMinLength = 2;
const int nameMaxLength = 60;

/// Minimum password length.
const int passwordMinLength = 8;

/// Converts Arabic-Indic (٠–٩) and Persian (۰–۹) digits to Western digits
/// and removes spaces and dashes.
String normalizeDigits(String input) {
  final out = StringBuffer();
  for (final unit in input.runes) {
    if (unit >= 0x0660 && unit <= 0x0669) {
      out.writeCharCode(0x30 + unit - 0x0660);
    } else if (unit >= 0x06F0 && unit <= 0x06F9) {
      out.writeCharCode(0x30 + unit - 0x06F0);
    } else if (unit == 0x20 ||
        unit == 0xA0 ||
        unit == 0x09 ||
        unit == 0x2D ||
        unit == 0x2010 ||
        unit == 0x2011 ||
        unit == 0x2012 ||
        unit == 0x2013 ||
        unit == 0x2014 ||
        unit == 0x2212 ||
        unit == 0x200E ||
        unit == 0x200F) {
      continue;
    } else {
      out.writeCharCode(unit);
    }
  }
  return out.toString();
}

final RegExp _localPhone = RegExp(r'^01[0125]\d{8}$');
final RegExp _phoneNoZero = RegExp(r'^1[0125]\d{8}$');

/// Normalises an Egyptian mobile number to `01xxxxxxxxx`.
Validation<String, PhoneProblem> normalizePhone(String input) {
  var digits = normalizeDigits(input);
  if (digits.isEmpty) return const Invalid(PhoneProblem.empty);
  if (digits.startsWith('+20')) {
    digits = digits.substring(3);
  } else if (digits.startsWith('0020')) {
    digits = digits.substring(4);
  } else if (digits.startsWith('20') && digits.length == 12) {
    digits = digits.substring(2);
  }
  if (_phoneNoZero.hasMatch(digits)) {
    digits = '0$digits';
  }
  if (!_localPhone.hasMatch(digits)) return const Invalid(PhoneProblem.invalid);
  return Valid(digits);
}

final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s.]+(\.[^@\s.]+)+$');

/// Trims and lower-cases an email; checks one `@`, a dot in the domain, no
/// spaces.
Validation<String, EmailProblem> normalizeEmail(String input) {
  final email = input.trim().toLowerCase();
  if (email.isEmpty) return const Invalid(EmailProblem.empty);
  if (!_emailPattern.hasMatch(email)) {
    return const Invalid(EmailProblem.invalid);
  }
  return Valid(email);
}

final RegExp _nameChars = RegExp("^[ء-يً-ْٰ-ۓa-zA-Z '’\\s]+\$");

/// Name: 2 to 60 characters after trimming, at least two words, letters
/// (Arabic or Latin), spaces and the apostrophe only. Returns the trimmed
/// name with single spaces.
Validation<String, NameProblem> validateName(String input) {
  final name = input.trim();
  if (name.isEmpty) return const Invalid(NameProblem.empty);
  final length = name.runes.length;
  if (length < nameMinLength) return const Invalid(NameProblem.tooShort);
  if (length > nameMaxLength) return const Invalid(NameProblem.tooLong);
  if (!_nameChars.hasMatch(name)) {
    return const Invalid(NameProblem.invalidCharacters);
  }
  final words = name.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  if (words.length < 2) return const Invalid(NameProblem.needsTwoWords);
  return Valid(words.join(' '));
}

final RegExp _letter = RegExp(r'\p{L}', unicode: true);
final RegExp _digit = RegExp(r'[0-9]');

/// Password: at least 8 characters with a letter and a digit. Returned
/// unchanged (passwords are never trimmed or normalised).
Validation<String, PasswordProblem> validatePassword(String input) {
  if (input.isEmpty) return const Invalid(PasswordProblem.empty);
  if (input.runes.length < passwordMinLength) {
    return const Invalid(PasswordProblem.tooShort);
  }
  if (!_letter.hasMatch(input)) {
    return const Invalid(PasswordProblem.needsLetter);
  }
  if (!_digit.hasMatch(input)) return const Invalid(PasswordProblem.needsDigit);
  return Valid(input);
}

/// Contains `@` means email, otherwise a mobile number.
IdentifierKind identifierKind(String input) =>
    input.contains('@') ? IdentifierKind.email : IdentifierKind.phone;

/// The normalised form of a sign-in identifier (email or phone), or null
/// when it is neither. Used as the key for lockout counters.
String normalizeIdentifier(String input) {
  switch (identifierKind(input)) {
    case IdentifierKind.email:
      return input.trim().toLowerCase();
    case IdentifierKind.phone:
      return normalizePhone(input).valueOrNull ?? normalizeDigits(input);
  }
}
