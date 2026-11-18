import 'package:flutter/widgets.dart';
import 'package:sprint/core/adaptive/adaptive_dialog.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// "ترك الدفع؟" (BR-47): leaving releases the place. True when the booker
/// chose to leave; false for "إكمال الدفع" or when dismissed. The platform's
/// own dialog, with the leave word on the destructive action.
Future<bool> confirmLeaveCheckout(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final leave = await showSprintDialog<bool>(
    context: context,
    title: l10n.checkoutLeaveTitle,
    message: l10n.checkoutLeaveBody,
    actions: [
      SprintDialogAction(
        label: l10n.checkoutLeaveConfirm,
        value: true,
        isDestructive: true,
      ),
      SprintDialogAction(
        label: l10n.checkoutLeaveStay,
        value: false,
        isDefault: true,
      ),
    ],
  );
  return leave ?? false;
}
