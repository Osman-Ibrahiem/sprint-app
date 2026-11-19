import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/adaptive/adaptive_app_bar.dart';
import 'package:sprint/core/adaptive/adaptive_back_button.dart';
import 'package:sprint/core/adaptive/adaptive_refresh.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/motion/skeleton.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart' show cairoDayOf;
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/notification_card/notification_card.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/core/window/window_size.dart';
import 'package:sprint/features/booking/presentation/widgets/empty_state.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/presentation/cancel/cancel_dialog.dart';
import 'package:sprint/features/booking/presentation/providers/my_bookings_providers.dart';
import 'package:sprint/features/notifications/domain/notification.dart';
import 'package:sprint/features/notifications/domain/notification_kind.dart';
import 'package:sprint/features/notifications/presentation/notification_card_data.dart';
import 'package:sprint/features/notifications/presentation/providers/notification_providers.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The notifications centre (US-14, FR-NTF-02, BR-39, BR-41): newest first,
/// unread marked, one tap opens the destination and marks the record read.
/// Pushed with a back button on compact, a destination from the medium class.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  static const markAllKey = ValueKey<String>('notifications-mark-all');
  static const emptyKey = ValueKey<String>('notifications-empty');
  static ValueKey<String> cardKey(String id) =>
      ValueKey<String>('notification-$id');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final compact = WindowSize.of(context).isCompact;
    final async = ref.watch(notificationsListProvider);
    final unread = ref.watch(unreadCountProvider) ?? 0;
    final clock = ref.watch(appClockProvider);

    Future<void> markAll() async {
      final user = ref.read(currentSessionProvider).user;
      if (user == null) return;
      await ref
          .read(notificationRepositoryProvider)
          .markAllRead(user.id, clock.now());
    }

    final header = Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(l10n.notificationsTitle, style: context.text.titleLg),
          ),
        ),
        if (unread > 0)
          SprintButton(
            key: markAllKey,
            label: l10n.notificationsMarkAllRead,
            variant: SprintButtonVariant.ghost,
            onPressed: markAll,
          ),
      ],
    );

    Widget body = async.when(
      loading: () => ListView(
        padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
        children: [
          for (var i = 0; i < 4; i++) ...[
            const Skeleton(height: SprintExtras.notificationCardHeight),
            const SizedBox(height: SprintSpacing.space3),
          ],
        ],
      ),
      error: (_, _) => EmptyState(
        icon: PhosphorIconsRegular.warningCircle,
        title: l10n.bookingsLoadError,
        actionLabel: l10n.bookingsRetry,
        onAction: () => ref.invalidate(notificationsListProvider),
      ),
      data: (list) => list.isEmpty
          ? EmptyState(
              key: emptyKey,
              icon: PhosphorIconsRegular.bell,
              title: l10n.notificationsEmptyTitle,
              body: l10n.notificationsEmptyBody,
            )
          : AdaptiveRefresh(
              onRefresh: () async => ref.invalidate(notificationsListProvider),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsetsDirectional.fromSTEB(
                  SprintSpacing.space4,
                  SprintSpacing.space2,
                  SprintSpacing.space4,
                  SprintExtras.screenBottomPadding,
                ),
                itemCount: list.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: SprintSpacing.space3),
                itemBuilder: (context, i) =>
                    NotificationTile(notification: list[i]),
              ),
            ),
    );

    if (compact) {
      return Column(
        children: [
          AdaptiveAppBar(
            title: l10n.notificationsTitle,
            leading: AdaptiveBackButton(
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go(AppPaths.home),
            ),
            actions: [
              if (unread > 0)
                TextButton(
                  key: markAllKey,
                  onPressed: markAll,
                  child: Text(l10n.notificationsMarkAllRead),
                ),
            ],
          ),
          Expanded(child: body),
        ],
      );
    }
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.all(SprintSpacing.space6),
            child: header,
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

/// One record as a card: marks it read, then opens its destination.
const reminderCancelKey = ValueKey<String>('reminder-cancel');

class NotificationTile extends ConsumerWidget {
  const NotificationTile({required this.notification, super.key});

  final Notification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = notification;
    final data = NotificationCardData.of(context, n);
    final format = SprintFormat.of(context);
    final now = ref.watch(appClockProvider).now();
    final sameDay = cairoDayOf(n.sentAt) == cairoDayOf(now);
    final time = sameDay ? format.time(n.sentAt) : format.date(n.sentAt);
    // A reminder decides at display time whether cancelling is still open
    // (BR-40): the same preview as the details and the dialog.
    Widget? actions;
    var body = data.body;
    final bookingId = n.payload['bookingId'];
    if (n.kind == NotificationKind.bookingReminder && bookingId != null) {
      final d = ref.watch(bookingDetailsProvider(bookingId)).value;
      if (d != null && d.booking.status == BookingStatus.confirmed) {
        if (d.cancelPreview.canCancel) {
          actions = SprintButton(
            key: reminderCancelKey,
            label: AppLocalizations.of(context).notifCancelBooking,
            variant: SprintButtonVariant.ghost,
            onPressed: () => runCancelFlow(
              context,
              ref,
              bookingId: bookingId,
              pending: false,
            ),
          );
        } else {
          body = '$body ${AppLocalizations.of(context).notifReminderCutoffClosed}';
        }
      }
    }
    return NotificationCard(
      key: NotificationsScreen.cardKey(n.id),
      actions: actions,
      icon: data.icon,
      tone: data.tone,
      title: data.title,
      body: body,
      time: time,
      unread: n.readAt == null,
      onTap: () async {
        if (n.readAt == null) {
          await ref
              .read(notificationRepositoryProvider)
              .markRead(n.id, ref.read(appClockProvider).now());
        }
        if (data.destination != null && context.mounted) {
          context.go(data.destination!);
        }
      },
    );
  }
}
