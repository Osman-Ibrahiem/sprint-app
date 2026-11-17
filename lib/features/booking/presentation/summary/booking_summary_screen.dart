import 'package:flutter/material.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';

/// The booking summary (feature 005). Stand-in until US2 builds it.
class BookingSummaryScreen extends StatelessWidget {
  const BookingSummaryScreen({
    required this.facilityId,
    required this.selection,
    this.shown,
    super.key,
  });

  final String facilityId;
  final ScheduleSelection selection;

  /// The amount the schedule displayed, to say when the price changed.
  final int? shown;

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}
