import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/adaptive/adaptive_app_bar.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/core/widgets/status_badge/sprint_status.dart';
import 'package:sprint/features/booking/domain/booking_summary_view.dart';
import 'package:sprint/features/booking/presentation/checkout/checkout_booking_card.dart';
import 'package:sprint/features/booking/presentation/checkout/countdown_text.dart';
import 'package:sprint/features/booking/presentation/checkout/state_icon_disc.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// "لسه مستنيين تأكيد الدفع": processing took longer than the wait. The place
/// stays held until the provider answers (BR-46); a late charge on an expired
/// booking is refunded automatically, and the words say so. "تحديث الحالة"
/// reads the provider's status once; leaving for the bookings is allowed and
/// the answer still applies in the background.
class AwaitingView extends StatelessWidget {
  const AwaitingView({
    required this.summary,
    required this.remaining,
    required this.refreshing,
    required this.onRefresh,
    super.key,
  });

  final BookingSummaryView summary;
  final Duration? remaining;
  final bool refreshing;
  final VoidCallback onRefresh;

  static const refreshKey = ValueKey<String>('awaiting-refresh');
  static const bookingsKey = ValueKey<String>('awaiting-bookings');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return Column(
      children: [
        AdaptiveAppBar(title: l10n.checkoutTitle),
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.all(SprintSpacing.space6),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: SprintExtras.centredColumn,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const StateIconDisc(),
                    const SizedBox(height: SprintSpacing.space4),
                    Semantics(
                      header: true,
                      liveRegion: true,
                      child: Text(
                        l10n.awaitingTitle,
                        style: context.text.title,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: SprintSpacing.space2),
                    Text(
                      l10n.awaitingBody,
                      style: context.text.body.copyWith(color: colors.inkMuted),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: SprintSpacing.space6),
                    CheckoutBookingCard(
                      view: summary,
                      status: SprintStatus.pendingPayment,
                    ),
                    // The Hold may be extended while the payment is pending
                    // (BR-46), so the time left stays visible, under the card
                    // as on the processing screen.
                    if (remaining != null) ...[
                      const SizedBox(height: SprintSpacing.space4),
                      Text(
                        l10n.processingHeld(countdownText(remaining!)),
                        key: CheckoutBookingCard.footerKey,
                        style: context.text.caption.copyWith(
                          color: colors.inkMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: SprintSpacing.space6),
                    SprintButton(
                      expand: true,
                      key: refreshKey,
                      label: l10n.awaitingRefresh,
                      loading: refreshing,
                      loadingLabel: l10n.awaitingRefreshing,
                      onPressed: refreshing ? null : onRefresh,
                    ),
                    const SizedBox(height: SprintSpacing.space2),
                    SprintButton(
                      expand: true,
                      key: bookingsKey,
                      label: l10n.awaitingBackToBookings,
                      variant: SprintButtonVariant.ghost,
                      onPressed: () => context.go(AppPaths.bookings),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
