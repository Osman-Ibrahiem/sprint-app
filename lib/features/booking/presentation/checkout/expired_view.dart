import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/adaptive/adaptive_app_bar.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/core/widgets/status_badge/sprint_status.dart';
import 'package:sprint/features/booking/domain/booking_summary_view.dart';
import 'package:sprint/features/booking/presentation/checkout/checkout_booking_card.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// "المهلة خلصت": the Hold is over and the place is released (FR-004, BR-12).
/// An hourglass in a `warning-soft` circle (decorative), the words, the
/// booking with an "انتهت المهلة" badge, and two ways on. The title is an
/// assertive live region and takes focus.
class ExpiredView extends StatelessWidget {
  const ExpiredView({required this.facilityId, required this.summary, super.key});

  final String facilityId;
  final BookingSummaryView? summary;

  static const titleKey = ValueKey<String>('expired-title');
  static const pickAnotherKey = ValueKey<String>('expired-pick-another');
  static const homeKey = ValueKey<String>('expired-home');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return Column(
      children: [
        AdaptiveAppBar(title: l10n.bookingSummaryTitle),
        Expanded(
          child: Center(
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
                      child: ExcludeSemantics(
                        child: Container(
                          width: SprintSize.controlHeight,
                          height: SprintSize.controlHeight,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.warningSoft,
                          ),
                          alignment: Alignment.center,
                          child: SprintIcon(
                            PhosphorIconsRegular.hourglass,
                            size: SprintSize.iconLg,
                            color: colors.warning,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: SprintSpacing.space3),
                    Focus(
                      autofocus: true,
                      child: Semantics(
                        header: true,
                        liveRegion: true,
                        child: Text(
                          l10n.holdExpiredTitle,
                          key: titleKey,
                          style: context.text.titleLg,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: SprintSpacing.space2),
                    Text(
                      l10n.holdExpiredBody,
                      style: context.text.body.copyWith(color: colors.inkMuted),
                      textAlign: TextAlign.center,
                    ),
                    if (summary != null) ...[
                      const SizedBox(height: SprintSpacing.space6),
                      CheckoutBookingCard(
                        view: summary!,
                        status: SprintStatus.expired,
                      ),
                    ],
                    const SizedBox(height: SprintSpacing.space6),
                    SprintButton(
                      key: pickAnotherKey,
                      label: l10n.holdExpiredPickAnother,
                      onPressed: () =>
                          context.go(AppPaths.facilitySchedule(facilityId)),
                    ),
                    const SizedBox(height: SprintSpacing.space2),
                    SprintButton(
                      key: homeKey,
                      label: l10n.backToHome,
                      variant: SprintButtonVariant.ghost,
                      onPressed: () => context.go(AppPaths.home),
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
