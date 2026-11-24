import 'package:intl/intl.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// 12-hour times and short dates with Western digits in both languages. The
/// digits are written here, never by intl: the plain `ar` locale would print
/// Arabic-Indic digits.

/// "5:00 م" / "5:00 PM" for [minutes] after midnight, with a no-break space
/// before the period (decision V1).
String minutesText(int minutes, AppLocalizations l10n) {
  final period = DateFormat('a', l10n.localeName == 'en' ? 'en' : 'ar');
  final hour = minutes ~/ 60;
  final h = hour % 12 == 0 ? 12 : hour % 12;
  final min = (minutes % 60).toString().padLeft(2, '0');
  return '$h:$min${SprintFormat.nbsp}'
      '${period.format(DateTime(2000, 1, 1, hour))}';
}

/// The Cairo time of a UTC instant.
String cairoTimeText(DateTime instant, AppLocalizations l10n) {
  final c = CairoTime.toCairo(instant);
  return minutesText(c.hour * 60 + c.minute, l10n);
}

/// "السبت 14/11" / "Saturday 14/11" for the Cairo day of a UTC instant.
String cairoDateText(DateTime instant, AppLocalizations l10n) {
  final c = CairoTime.toCairo(instant);
  return '${l10n.catalogueDayName('${c.weekday}')} ${c.day}/${c.month}';
}
