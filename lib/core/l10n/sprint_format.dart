import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The only place that formats prices, times, dates and numbers (FR-015).
///
/// Always uses the plain `ar` / `en` locales, which print Western digits.
/// Never `ar_EG`: it would print Arabic-Indic digits (research R5). Times and
/// dates are shown in Cairo time. Screens never call `intl` directly.
class SprintFormat {
  const SprintFormat(String languageCode)
      : _lang = languageCode == 'en' ? 'en' : 'ar';

  factory SprintFormat.of(BuildContext context) =>
      SprintFormat(Localizations.localeOf(context).languageCode);

  final String _lang;

  AppLocalizations get _l10n => lookupAppLocalizations(Locale(_lang));

  /// 1234.5 -> "1,234.5"
  String number(num value) => NumberFormat.decimalPattern(_lang).format(value);

  /// "120 ج.م" / "EGP 120".
  String price(num amount) => _l10n.priceEgp(number(amount));

  /// 12-hour Cairo time: "5:00 م" / "5:00 PM". [instant] is a UTC instant.
  String time(DateTime instant) =>
      DateFormat('h:mm a', _lang).format(CairoTime.toCairo(instant));

  /// "السبت 14 نوفمبر" / "Sat, 14 Nov", for the Cairo calendar day.
  String date(DateTime instant) {
    final pattern = _lang == 'en' ? 'EEE, d MMM' : 'EEEE d MMMM';
    return DateFormat(pattern, _lang).format(CairoTime.toCairo(instant));
  }
}
