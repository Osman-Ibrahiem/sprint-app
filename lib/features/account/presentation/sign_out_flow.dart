import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint/core/adaptive/adaptive_dialog.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Asks first, then signs out; the demo data stays (US-14, FR-016).
Future<void> confirmSignOut(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showSprintDialog<bool>(
    context: context,
    title: l10n.signOutTitle,
    message: l10n.signOutBody,
    actions: [
      SprintDialogAction(label: l10n.signOutKeep, value: false),
      SprintDialogAction(
        label: l10n.signOutConfirm,
        value: true,
        isDestructive: true,
        isDefault: true,
      ),
    ],
  );
  if (confirmed ?? false) await ref.read(sessionProvider.notifier).signOut();
}
