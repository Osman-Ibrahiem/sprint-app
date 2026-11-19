import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint/core/adaptive/adaptive_dialog.dart';
import 'package:sprint/features/notifications/data/notification_permission_store.dart';
import 'package:sprint/features/notifications/domain/notification_permission.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Asks for the (simulated) notification permission once: at the first moment
/// the booker reaches the notification step (after the first confirmation or
/// the first visit to the centre). Stores the answer and changes nothing
/// visible but that; asking again is the Account row's job (US-14, FR-021).
Future<void> maybeAskNotificationPermission(
  BuildContext context,
  WidgetRef ref,
) async {
  final store = ref.read(notificationPermissionStoreProvider);
  if (store.read() != null) return;
  await askNotificationPermission(context, ref);
}

/// Always asks (the Account row), and stores the answer.
Future<NotificationPermission?> askNotificationPermission(
  BuildContext context,
  WidgetRef ref,
) async {
  final l10n = AppLocalizations.of(context);
  final store = ref.read(notificationPermissionStoreProvider);
  final answer = await showSprintDialog<NotificationPermission>(
    context: context,
    title: l10n.permissionTitle,
    message: l10n.permissionMessage,
    actions: [
      SprintDialogAction(
        label: l10n.permissionDeny,
        value: NotificationPermission.denied,
      ),
      SprintDialogAction(
        label: l10n.permissionAllow,
        value: NotificationPermission.granted,
        isDefault: true,
      ),
    ],
  );
  if (answer != null) await store.write(answer);
  return answer;
}
