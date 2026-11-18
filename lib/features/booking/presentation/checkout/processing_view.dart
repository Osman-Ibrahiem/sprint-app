import 'package:flutter/material.dart';
import 'package:sprint/core/adaptive/adaptive_app_bar.dart';
import 'package:sprint/core/adaptive/adaptive_loader.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/status_badge/sprint_status.dart';
import 'package:sprint/features/booking/domain/booking_summary_view.dart';
import 'package:sprint/features/booking/presentation/checkout/checkout_booking_card.dart';
import 'package:sprint/features/booking/presentation/checkout/countdown_text.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// "بنأكد الدفع": the provider has not answered yet. No back and no dialog
/// (nothing to leave while a payment is in flight): the system back is
/// absorbed (FR-018). Shows the booking and how long the place stays held.
class ProcessingView extends StatelessWidget {
  const ProcessingView({
    required this.summary,
    required this.remaining,
    super.key,
  });

  final BookingSummaryView summary;
  final Duration? remaining;

  static const loaderKey = ValueKey<String>('processing-loader');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return PopScope(
      canPop: false,
      child: Column(
        children: [
          AdaptiveAppBar(
            title: l10n.checkoutTitle,
            leading: const SizedBox.shrink(),
          ),
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
                      Center(
                        child: AdaptiveLoader(
                          key: loaderKey,
                          semanticLabel: l10n.processingTitle,
                          size: SprintExtras.processingLoader,
                        ),
                      ),
                      const SizedBox(height: SprintSpacing.space4),
                      Semantics(
                        header: true,
                        child: Text(
                          l10n.processingTitle,
                          style: context.text.titleLg,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: SprintSpacing.space2),
                      Text(
                        l10n.processingBody,
                        style: context.text.body.copyWith(
                          color: colors.inkMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: SprintSpacing.space6),
                      CheckoutBookingCard(
                        view: summary,
                        status: SprintStatus.pendingPayment,
                      ),
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
