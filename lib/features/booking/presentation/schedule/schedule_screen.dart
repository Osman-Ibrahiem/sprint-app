import 'package:flutter/material.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';

/// The schedule of one facility (feature 005). Stand-in until US1 builds it:
/// it already receives the facility and the selection the address carries.
class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({
    required this.facilityId,
    required this.selection,
    super.key,
  });

  final String facilityId;
  final ScheduleSelection selection;

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}
