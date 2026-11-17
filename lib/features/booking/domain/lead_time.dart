/// A reminder lead (BR-39) split for wording: whole hours, an optional extra
/// half hour, or plain minutes when it is neither. Pure; the words come from
/// the ARB plural messages in presentation.
class LeadTime {
  const LeadTime({required this.hours, required this.halfHour})
      : minutes = null;
  const LeadTime.minutes(int this.minutes)
      : hours = 0,
        halfHour = false;

  /// Whole hours (0 when only a half hour or plain minutes).
  final int hours;

  /// True for "an hour and a half" style leads.
  final bool halfHour;

  /// Set only when the lead is not a whole or half number of hours.
  final int? minutes;
}

/// 60 → 1 h, 90 → 1 h + half, 120 → 2 h, 180 → 3 h, 30 → half an hour,
/// 45 → 45 minutes.
LeadTime describeLead(int minutes) {
  if (minutes >= 30 && minutes % 30 == 0) {
    return LeadTime(hours: minutes ~/ 60, halfHour: minutes % 60 == 30);
  }
  return LeadTime.minutes(minutes);
}
