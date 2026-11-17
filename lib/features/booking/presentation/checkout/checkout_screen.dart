import 'package:flutter/widgets.dart';

/// Replaced task by task (T031 onward).
class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({
    required this.facilityId,
    required this.bookingId,
    super.key,
  });

  final String facilityId;
  final String bookingId;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
