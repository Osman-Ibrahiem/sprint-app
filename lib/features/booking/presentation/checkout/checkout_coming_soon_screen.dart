import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/adaptive/adaptive_app_bar.dart';
import 'package:sprint/core/adaptive/adaptive_back_button.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';
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
    final colors = context.colors;
    return Column(
      children: [
        AdaptiveAppBar(
          title: l10n.bookingCheckoutSoonTitle,
          leading: AdaptiveBackButton(onPressed: () => _backToSummary(context)),
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.all(SprintSpacing.space6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SprintIcon(
                    PhosphorIconsRegular.creditCard,
                    size: SprintSize.iconLg,
                    color: colors.inkMuted,
                  ),
                  const SizedBox(height: SprintSpacing.space3),
                  Text(
                    l10n.bookingCheckoutSoonTitle,
                    style: context.text.headline,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: SprintSpacing.space2),
                  Text(
                    l10n.bookingCheckoutSoonBody,
                    style: context.text.body.copyWith(color: colors.inkMuted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: SprintSpacing.space4),
                  SprintButton(
                    key: backKey,
                    label: l10n.bookingBackToSummary,
                    variant: SprintButtonVariant.secondary,
                    onPressed: () => _backToSummary(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
