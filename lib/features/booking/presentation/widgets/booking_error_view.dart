import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// A clear failure with a retry, for errors that are not booking rules
/// (research R11). The booking feature's own: features do not import each
/// other's presentation code.
class BookingErrorView extends StatelessWidget {
  const BookingErrorView({required this.onRetry, super.key});

  final VoidCallback onRetry;

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
            SprintIcon(
              PhosphorIconsRegular.warningCircle,
              size: SprintSize.iconLg,
              color: colors.warning,
            ),
            const SizedBox(height: SprintSpacing.space3),
            Text(
              l10n.bookingErrorTitle,
              style: context.text.headline,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SprintSpacing.space2),
            Text(
              l10n.bookingErrorBody,
              style: context.text.body.copyWith(color: colors.inkMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SprintSpacing.space4),
            SprintButton(
              label: l10n.bookingRetry,
              icon: const SprintButtonIcon(PhosphorIconsRegular.arrowsClockwise),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
