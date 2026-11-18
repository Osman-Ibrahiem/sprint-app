import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint/app/shell/placeholders/no_access_screen.dart';
import 'package:sprint/features/booking/presentation/providers/checkout_providers.dart';

/// Shows [child] to the owner of the booking. Someone else's booking shows
/// `NoAccessScreen` at the same location (contracts/routes.md); a missing one
/// is left to [child] to explain.
class BookingOwnerGate extends ConsumerWidget {
  const BookingOwnerGate({
    required this.bookingId,
    required this.child,
    super.key,
  });

  final String bookingId;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(checkoutAccessProvider(bookingId)).value;
    if (access == CheckoutAccess.notOwner) return const NoAccessScreen();
    return child;
  }
}
