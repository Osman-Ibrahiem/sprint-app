import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/features/booking/presentation/details/booking_details_screen.dart';
import 'package:sprint/features/booking/presentation/details/status_banner.dart';
import 'package:sprint/features/booking/presentation/providers/my_bookings_providers.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Result of a cancel (`/bookings/:id/cancelled`, US-13): the cause, the money
/// line from the same amounts as the dialog, and the way back (BR-31, BR-32).
class CancelResultScreen extends ConsumerWidget {
  const CancelResultScreen({required this.bookingId, super.key});

  final String bookingId;

  static const backKey = ValueKey<String>('cancel-result-back');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final d = ref.watch(bookingDetailsProvider(bookingId)).value;
    final now = ref.watch(appClockProvider).now();
    if (d == null) return BookingDetailsView(bookingId: bookingId);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.cancelResultTitle, style: context.text.titleLg),
            const SizedBox(height: SprintSpacing.space4),
            StatusBanner(details: d, now: now),
            const SizedBox(height: SprintSpacing.space4),
            SprintButton(
              key: backKey,
              label: l10n.cancelResultBack,
              expand: true,
              onPressed: () => context.go(AppPaths.bookings),
            ),
          ],
        ),
      ),
    );
  }
}
