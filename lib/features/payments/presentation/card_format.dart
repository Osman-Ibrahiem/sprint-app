/// Format-only checks for the simulated provider page (R5). Nothing here
/// reaches storage, logs or any repository: the page keeps what is typed in
/// local state and passes on only the last four digits (FR-009).
abstract final class CardFormat {
  /// Western digits only; Arabic-Indic and Persian digits are converted and
  /// everything else dropped.
  static String digits(String text) {
    final out = StringBuffer();
    for (final unit in text.runes) {
      if (unit >= 0x0660 && unit <= 0x0669) {
        out.writeCharCode(0x30 + unit - 0x0660);
      } else if (unit >= 0x06F0 && unit <= 0x06F9) {
        out.writeCharCode(0x30 + unit - 0x06F0);
      } else if (unit >= 0x30 && unit <= 0x39) {
        out.writeCharCode(unit);
      }
    }
    return out.toString();
  }

  /// "4242 4242 4242 4242": groups of four, up to 19 digits.
  static String groupNumber(String text) {
    var d = digits(text);
    if (d.length > 19) d = d.substring(0, 19);
    final out = StringBuffer();
    for (var i = 0; i < d.length; i++) {
      if (i > 0 && i % 4 == 0) out.write(' ');
      out.write(d[i]);
    }
    return out.toString();
  }

  /// "08/28": a slash after the month, four digits at most.
  static String groupExpiry(String text) {
    var d = digits(text);
    if (d.length > 4) d = d.substring(0, 4);
    return d.length <= 2 ? d : '${d.substring(0, 2)}/${d.substring(2)}';
  }

  /// 12 to 19 digits that pass the Luhn check. Accepts the published test
  /// numbers (such as 4242 4242 4242 4242).
  static bool isValidNumber(String text) {
    final d = digits(text);
    if (d.length < 12 || d.length > 19) return false;
    var sum = 0;
    var alternate = false;
    for (var i = d.length - 1; i >= 0; i--) {
      var n = d.codeUnitAt(i) - 0x30;
      if (alternate) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  /// MM/YY with a real month, not before the month of [now].
  static bool isValidExpiry(String text, DateTime now) {
    final d = digits(text);
    if (d.length != 4) return false;
    final month = int.parse(d.substring(0, 2));
    final year = 2000 + int.parse(d.substring(2));
    if (month < 1 || month > 12) return false;
    return year > now.year || (year == now.year && month >= now.month);
  }

  /// 3 or 4 digits.
  static bool isValidCvc(String text) {
    final n = digits(text).length;
    return n == 3 || n == 4;
  }

  static bool isValidName(String text) => text.trim().isNotEmpty;

  /// The last four digits, the only card data that leaves the page.
  static String last4(String text) {
    final d = digits(text);
    return d.length <= 4 ? d : d.substring(d.length - 4);
  }
}
