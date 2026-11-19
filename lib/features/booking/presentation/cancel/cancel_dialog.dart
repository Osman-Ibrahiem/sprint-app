import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/adaptive/adaptive_dialog.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/features/booking/domain/cancel_preview.dart';
import 'package:sprint/features/booking/presentation/cancel/cancel_providers.dart';
import 'package:sprint/features/booking/presentation/cancel/cancel_wording.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The whole cancel interaction (US-13, US-14, BR-30, BR-31, BR-48): asks the
/// repository for the preview, shows the platform dialog with the computed
/// wording, cancels, and on success goes to the result. The repository
/// re-checks the cutoff and the hold at confirmation, so a dialog left open
/// past the cutoff says "فات وقت الإلغاء" and changes nothing.
///
/// Returns what happened, or null when the person backed out.
Future<CancelOutcome?> runCancelFlow(
  BuildContext context,
  WidgetRef ref, {
  required String bookingId,
  required bool pending,
}) async {
  final l10n = AppLocalizations.of(context);
  final actions = ref.read(cancelActionsProvider);
  final preview = await actions.preview(bookingId);
  if (!context.mounted) return null;

  if (!preview.canCancel) {
    await _info(context, l10n.cancelClosedTitle, _closedBody(context, preview));
    return const CancelClosed();
  }

  final accepted = await showSprintDialog<bool>(
    context: context,
    title: l10n.cancelDialogTitle,
    message: CancelWording.message(context, preview, pending: pending),
    actions: [
      SprintDialogAction(label: l10n.cancelActionBack, value: false, isDefault: true),
      SprintDialogAction(
        label: l10n.cancelActionConfirm,
        value: true,
        isDestructive: true,
      ),
    ],
  );
  if (accepted != true || !context.mounted) return null;

  final outcome = await actions.confirm(bookingId);
  if (!context.mounted) return outcome;
  switch (outcome) {
    case CancelDone():
      context.go(AppPaths.bookingCancelled(bookingId));
    case CancelClosed():
      await _info(context, l10n.cancelClosedTitle, _closedBody(context, preview));
    case CancelAlready():
      await _info(context, l10n.cancelAlreadyTitle, null);
    case CancelRefused():
      await _info(context, l10n.cancelFailed, null);
  }
  return outcome;
}

String _closedBody(BuildContext context, CancelPreview p) {
  final format = SprintFormat.of(context);
  final until = CairoTime.toCairo(p.cancelUntil);
  return AppLocalizations.of(context).cancelClosedBody(
    '${format.date(until)} ${format.localTime(until)}',
  );
}

Future<void> _info(BuildContext context, String title, String? message) =>
    showSprintDialog<void>(
      context: context,
      title: title,
      message: message,
      actions: [
        SprintDialogAction(
          label: AppLocalizations.of(context).cancelActionBack,
          isDefault: true,
        ),
      ],
    );
