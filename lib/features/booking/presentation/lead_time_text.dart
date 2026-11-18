import 'package:sprint/features/booking/domain/lead_time.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// "ساعة", "ساعة ونص", "ساعتين", "3 ساعات" for a lead in minutes, from the
/// ARB plural messages (never a typed-in number).
String leadTimeText(AppLocalizations l10n, int minutes) {
  final lead = describeLead(minutes);
  final plain = lead.minutes;
  if (plain != null) return l10n.leadMinutes(plain);
  return lead.halfHour ? l10n.leadHoursHalf(lead.hours) : l10n.leadHours(lead.hours);
}
