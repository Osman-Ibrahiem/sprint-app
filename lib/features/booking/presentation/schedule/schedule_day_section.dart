import 'package:flutter/material.dart';
import 'package:sprint/core/widgets/day_strip/day_strip.dart';
import 'package:sprint/core/widgets/day_strip/day_strip_day.dart';
import 'package:sprint/features/booking/domain/facility_schedule.dart';

/// The existing [DayStrip] fed with the schedule's days (FR-002 – FR-004).
/// Closed days are disabled and announced by the strip itself.
class ScheduleDaySection extends StatelessWidget {
  const ScheduleDaySection({
    required this.days,
    required this.today,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<ScheduleDay> days;
  final DateTime today;
  final DateTime? selected;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) => DayStrip(
    days: [
      for (final d in days)
        DayStripDay(
          date: d.date,
          hasAvailability: d.hasAvailability,
          isClosed: d.isClosed,
        ),
    ],
    today: today,
    selected: selected,
    onSelected: (d) => onSelected(d.date),
  );
}
