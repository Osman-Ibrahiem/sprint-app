import 'package:flutter/material.dart';

/// The success screen of a free booking (feature 005). Stand-in until US4
/// builds it.
class BookingDoneScreen extends StatelessWidget {
  const BookingDoneScreen({
    required this.facilityId,
    required this.bookingId,
    super.key,
  });

  final String facilityId;
  final String bookingId;

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}
