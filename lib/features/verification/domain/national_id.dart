/// Egyptian national ID checks (research R5). No checksum: the check
/// digit's algorithm is not published.
library;

import 'package:sprint/features/auth/domain/validators.dart';

enum NationalIdProblem {
  empty,
  notFourteenDigits,
  invalidCentury,
  invalidBirthDate,
  futureBirthDate,
  invalidGovernorate,
}

const int nationalIdLength = 14;

bool _validGovernorate(int code) =>
    (code >= 1 && code <= 4) ||
    (code >= 11 && code <= 19) ||
    (code >= 21 && code <= 29) ||
    (code >= 31 && code <= 35) ||
    code == 88;

/// Normalises digits then checks: 14 digits; first digit 2 (1900s) or 3
/// (2000s); digits 2-7 a real date not in the future; digits 8-9 a
/// governorate code. [now] is injectable for tests.
Validation<String, NationalIdProblem> validateNationalId(
  String input, {
  DateTime? now,
}) {
  final id = normalizeDigits(input);
  if (id.isEmpty) return const Invalid(NationalIdProblem.empty);
  if (!RegExp(r'^\d{14}$').hasMatch(id)) {
    return const Invalid(NationalIdProblem.notFourteenDigits);
  }
  final century = switch (id[0]) {
    '2' => 1900,
    '3' => 2000,
    _ => null,
  };
  if (century == null) return const Invalid(NationalIdProblem.invalidCentury);
  final year = century + int.parse(id.substring(1, 3));
  final month = int.parse(id.substring(3, 5));
  final day = int.parse(id.substring(5, 7));
  final birth = DateTime.utc(year, month, day);
  if (birth.year != year || birth.month != month || birth.day != day) {
    return const Invalid(NationalIdProblem.invalidBirthDate);
  }
  final today = now ?? DateTime.now();
  if (birth.isAfter(DateTime.utc(today.year, today.month, today.day))) {
    return const Invalid(NationalIdProblem.futureBirthDate);
  }
  if (!_validGovernorate(int.parse(id.substring(7, 9)))) {
    return const Invalid(NationalIdProblem.invalidGovernorate);
  }
  return Valid(id);
}

/// Shows the last 4 digits only; the rest are `*`. Wrap in an LTR isolate
/// in the UI.
String maskNationalId(String input) {
  final id = normalizeDigits(input);
  if (id.length <= 4) return '*' * id.length;
  return '${'*' * (id.length - 4)}${id.substring(id.length - 4)}';
}
