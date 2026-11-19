import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/presentation/cancel/cancel_dialog.dart';
import 'package:sprint/features/booking/presentation/providers/my_bookings_providers.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The actions of a booking's details: cancel (BR-30, BR-48) and, while
/// holding, "إكمال الدفع". What is offered comes from the repository's preview
/// (one rule behind the dialog, the reminder and this screen); no status is
/// assumed here.
class DetailsActions extends ConsumerWidget {
  const DetailsActions({required this.details, super.key});

  final BookingDetails details;

  static const cancelKey = ValueKey<String>('details-cancel');
  static const payKey = ValueKey<String>('details-pay');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final b = details.booking;
    final canCancel = details.cancelPreview.canCancel;
    final pending = b.status == BookingStatus.pendingPayment;

    Future<void> cancel() => runCancelFlow(
      context,
      ref,
      bookingId: b.id,
      pending: pending,
    );

    if (pending) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SprintButton(
            key: payKey,
            label: l10n.bookingDetailsPay(
              SprintFormat.of(context).price(b.priceAtBooking),
            ),
            expand: true,
            onPressed: () => context.go(
              AppPaths.bookingCheckoutFor(b.facilityId, b.id),
            ),
          ),
          if (canCancel) ...[
            const SizedBox(height: SprintSpacing.space2),
            SprintButton(
              key: cancelKey,
              label: l10n.bookingDetailsCancel,
              variant: SprintButtonVariant.ghost,
              expand: true,
              onPressed: cancel,
            ),
          ],
        ],
      );
    }
    if (b.status == BookingStatus.confirmed && canCancel) {
      return SprintButton(
        key: cancelKey,
        label: l10n.bookingDetailsCancel,
        variant: SprintButtonVariant.danger,
        expand: true,
        onPressed: cancel,
      );
    }
    return const SizedBox.shrink();
  }
}
