import 'package:flutter/material.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';

/// Where a paid booking stops until feature 6 (feature 005). Stand-in until
/// US2 builds it.
class CheckoutComingSoonScreen extends StatelessWidget {
  const CheckoutComingSoonScreen({
    required this.facilityId,
    required this.selection,
    super.key,
  });

  final String facilityId;
  final ScheduleSelection selection;

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}
