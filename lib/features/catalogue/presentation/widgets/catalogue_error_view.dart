import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// A clear failure with a retry that reloads the failed screen (FR-033, R10).
class CatalogueErrorView extends StatelessWidget {
  const CatalogueErrorView({required this.onRetry, this.compact = false, super.key});

  final VoidCallback onRetry;

  /// A shorter layout for a details pane.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.all(SprintSpacing.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIconsRegular.warningCircle,
              size: SprintSize.iconLg,
              color: colors.warning,
            ),
            const SizedBox(height: SprintSpacing.space3),
            Text(
              l10n.catalogueErrorTitle,
              style: context.text.headline,
              textAlign: TextAlign.center,
            ),
            if (!compact) ...[
              const SizedBox(height: SprintSpacing.space2),
              Text(
                l10n.catalogueErrorBody,
                style: context.text.body.copyWith(color: colors.inkMuted),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: SprintSpacing.space4),
            SprintButton(
              label: l10n.catalogueRetry,
              icon: const SprintButtonIcon(PhosphorIconsRegular.arrowsClockwise),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
