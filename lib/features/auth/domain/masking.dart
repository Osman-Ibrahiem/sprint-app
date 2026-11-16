/// Display masking for contact details (FR-033's spirit for the account
/// card): enough to recognise, not enough to copy.
library;

/// `01000000001` -> `010•••••001`; short values are fully masked.
String maskPhone(String phone) {
  if (phone.length < 7) return '•' * phone.length;
  return '${phone.substring(0, 3)}${'•' * (phone.length - 6)}'
      '${phone.substring(phone.length - 3)}';
}

/// `mona@example.test` -> `m•••@example.test`.
String maskEmail(String email) {
  final at = email.indexOf('@');
  if (at < 1) return '•' * email.length;
  return '${email[0]}•••${email.substring(at)}';
}
