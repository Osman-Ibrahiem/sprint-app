import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// A friendly screen for a missing or unpublished facility: never a blank page
/// (FR-026).
class FacilityNotFound extends StatelessWidget {
  const FacilityNotFound({super.key});

  static const containerKey = ValueKey<String>('facility-not-found');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return Center(
      key: containerKey,
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.all(SprintSpacing.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIconsRegular.mapPin,
              size: SprintSize.iconLg,
              color: colors.inkMuted,
            ),
            const SizedBox(height: SprintSpacing.space3),
            Text(
              l10n.catalogueFacilityNotFoundTitle,
              style: context.text.headline,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SprintSpacing.space2),
            Text(
              l10n.catalogueFacilityNotFoundBody,
              style: context.text.body.copyWith(color: colors.inkMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SprintSpacing.space4),
            SprintButton(
              label: l10n.catalogueBackToFacilities,
              icon: const SprintButtonIcon(
                PhosphorIconsRegular.arrowRight,
                mirrorInRtl: true,
              ),
              onPressed: () => context.go(AppPaths.facilities),
            ),
          ],
        ),
      ),
    );
  }
}
