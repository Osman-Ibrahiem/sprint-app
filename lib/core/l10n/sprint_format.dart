import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The only place that formats prices, times, dates and numbers (FR-015).
///
/// Always uses the plain `ar` / `en` locales and then maps any Arabic-Indic
/// digit to 0-9: under the app's own localisation delegates the `ar` date
/// symbols print Arabic-Indic digits, against the Western-digits rule
/// (research R5). Times and dates are shown in Cairo time. Screens never call
/// `intl` directly.
class SprintFormat {
  const SprintFormat(String languageCode)
    : _lang = languageCode == 'en' ? 'en' : 'ar';

  factory SprintFormat.of(BuildContext context) =>
      SprintFormat(Localizations.localeOf(context).languageCode);

  final String _lang;

  /// Once the Material localizations have loaded, intl's plain `ar` can print
  /// Arabic-Indic digits; the product rule is Western digits in both languages.
  static String _western(String text) =>
      text.replaceAllMapped(RegExp('[٠-٩۰-۹]'), (m) {
        final unit = m[0]!.codeUnitAt(0);
        return String.fromCharCode(
          unit >= 0x06F0 ? unit - 0x06F0 + 0x30 : unit - 0x0660 + 0x30,
        );
      });

  AppLocalizations get _l10n => lookupAppLocalizations(Locale(_lang));

  /// 1234.5 -> "1,234.5"
  String number(num value) =>
      _western(NumberFormat.decimalPattern(_lang).format(value));

  /// "120 ج.م" / "EGP 120".
  String price(num amount) => _l10n.priceEgp(number(amount));

  /// 12-hour Cairo time: "5:00 م" / "5:00 PM". [instant] is a UTC instant.
  String time(DateTime instant) =>
      _western(DateFormat('h:mm a', _lang).format(CairoTime.toCairo(instant)));

  /// "السبت 14 نوفمبر" / "Sat, 14 Nov", for the Cairo calendar day.
  String date(DateTime instant) {
    final pattern = _lang == 'en' ? 'EEE, d MMM' : 'EEEE d MMMM';
    return _western(
      DateFormat(pattern, _lang).format(CairoTime.toCairo(instant)),
    );
  }

  /// "31 أغسطس 2027" / "31 Aug 2027", for the Cairo calendar day.
  String dateWithYear(DateTime instant) {
    final pattern = _lang == 'en' ? 'd MMM y' : 'd MMMM y';
    return _western(
      DateFormat(pattern, _lang).format(CairoTime.toCairo(instant)),
    );
  }

  /// A Cairo-local time, without the conversion [time] applies. Screens that
  /// already hold Cairo wall-clock times use the methods below.
  String _localTime(DateTime t) =>
      _western(DateFormat('h:mm a', _lang).format(t));

  /// The short form of a Cairo-local time ("5:00 م").
  String localTime(DateTime t) => _localTime(t);

  /// "5:00 – 6:00 م" when both ends share the period, otherwise
  /// "11:00 ص – 1:00 م" / "11:00 AM – 1:00 PM".
  String timeRange(DateTime start, DateTime end) {
    final a = _localTime(start);
    final b = _localTime(end);
    final aPeriod = a.split(' ').last;
    final bPeriod = b.split(' ').last;
    if (aPeriod == bPeriod) {
      return '${a.substring(0, a.length - aPeriod.length - 1)} – $b';
    }
    return '$a – $b';
  }

  /// "التلات 10 نوفمبر · 5:00 – 6:00 م" / "Tue 10 Nov · 5:00 – 6:00 PM".
  String dateTimeLine(DateTime start, DateTime end) {
    final pattern = _lang == 'en' ? 'd MMM' : 'd MMMM';
    final day = _western(DateFormat(pattern, _lang).format(start));
    return '${dayName(start, short: true)} $day · ${timeRange(start, end)}';
  }

  /// The week day's name in the current language. [short] gives the form the
  /// day strip and the ticket line use.
  String dayName(DateTime day, {bool short = false}) {
    final l10n = _l10n;
    return switch (day.weekday) {
      DateTime.saturday => short ? l10n.dayShortSaturday : l10n.dayFullSaturday,
      DateTime.sunday => short ? l10n.dayShortSunday : l10n.dayFullSunday,
      DateTime.monday => short ? l10n.dayShortMonday : l10n.dayFullMonday,
      DateTime.tuesday => short ? l10n.dayShortTuesday : l10n.dayFullTuesday,
      DateTime.wednesday =>
        short ? l10n.dayShortWednesday : l10n.dayFullWednesday,
      DateTime.thursday => short ? l10n.dayShortThursday : l10n.dayFullThursday,
      _ => short ? l10n.dayShortFriday : l10n.dayFullFriday,
    };
  }

  /// 99 -> "99", 100 -> "99+" (the navigation badge cap).
  String compactCount(int value) => value > SprintExtras.navigationBadgeCap
      ? '${SprintExtras.navigationBadgeCap}+'
      : number(value);

  /// 73.4 -> "73%".
  String percent(num value) => '${value.round()}%';
}
