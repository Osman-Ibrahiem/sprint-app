import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/adaptive/adaptive_app_bar.dart';
import 'package:sprint/core/adaptive/adaptive_back_button.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';
import 'package:sprint/features/booking/presentation/widgets/empty_state.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Where a paid booking stops until feature 6 (FR-028): a deliberate screen
/// with a way back to the summary. No booking exists, no place is held, and
/// there is no payment control.
class CheckoutComingSoonScreen extends StatelessWidget {
  const CheckoutComingSoonScreen({
    required this.facilityId,
    required this.selection,
    super.key,
  });

  final String facilityId;
  final ScheduleSelection selection;

  static const backKey = ValueKey<String>('checkout-back');

  void _backToSummary(BuildContext context) => context.canPop()
      ? context.pop()
      : context.go(AppPaths.bookingSummary(facilityId, selection));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        AdaptiveAppBar(
          title: l10n.bookingCheckoutSoonTitle,
          leading: AdaptiveBackButton(onPressed: () => _backToSummary(context)),
        ),
        Expanded(
          child: EmptyState(
            icon: PhosphorIconsRegular.creditCard,
            title: l10n.bookingCheckoutSoonTitle,
            body: l10n.bookingCheckoutSoonBody,
            actionLabel: l10n.bookingBackToSummary,
            actionKey: backKey,
            onAction: () => _backToSummary(context),
          ),
        ),
      ],
    );
  }
}
