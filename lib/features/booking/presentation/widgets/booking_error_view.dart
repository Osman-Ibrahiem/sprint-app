import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/features/booking/presentation/widgets/empty_state.dart';
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
    return EmptyState(
      icon: PhosphorIconsRegular.warningCircle,
      iconColor: context.colors.warning,
      title: l10n.bookingErrorTitle,
      body: l10n.bookingErrorBody,
      actionLabel: l10n.bookingRetry,
      actionIcon: const SprintButtonIcon(PhosphorIconsRegular.arrowsClockwise),
      actionVariant: SprintButtonVariant.primary,
      onAction: onRetry,
    );
  }
}
