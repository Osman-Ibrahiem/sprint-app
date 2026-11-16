import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/adaptive/adaptive_app_bar.dart';
import 'package:sprint/core/l10n/directional_icon.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Where "عرض المواعيد" lands until the booking feature ships: no slots and no
/// booking action (FR-022).
class ScheduleComingSoonScreen extends StatelessWidget {
  const ScheduleComingSoonScreen({required this.facilityId, super.key});

  final String facilityId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return Column(
      children: [
        AdaptiveAppBar(
          title: l10n.catalogueScheduleSoonTitle,
          leading: IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            icon: const DirectionalIcon(PhosphorIconsRegular.arrowRight),
            onPressed: () => context.go(AppPaths.facilityDetails(facilityId)),
          ),
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.all(SprintSpacing.space6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    PhosphorIconsRegular.calendarBlank,
                    size: SprintSize.iconLg,
                    color: colors.inkMuted,
                  ),
                  const SizedBox(height: SprintSpacing.space3),
                  Text(
                    l10n.catalogueScheduleSoonTitle,
                    style: context.text.headline,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: SprintSpacing.space2),
                  Text(
                    l10n.catalogueScheduleSoonBody,
                    style: context.text.body.copyWith(color: colors.inkMuted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: SprintSpacing.space4),
                  SprintButton(
                    label: l10n.catalogueScheduleSoonBack,
                    variant: SprintButtonVariant.secondary,
                    onPressed: () =>
                        context.go(AppPaths.facilityDetails(facilityId)),
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
