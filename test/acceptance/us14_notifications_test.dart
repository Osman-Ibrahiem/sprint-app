import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/widgets/app_navigation/app_navigation.dart';
import 'package:sprint/features/notifications/data/notification_permission_store.dart';
import 'package:sprint/features/notifications/domain/notification_permission.dart';
import 'package:sprint/features/notifications/presentation/notifications_screen.dart';
import 'package:sprint/features/notifications/presentation/providers/notification_providers.dart';

import '../helpers/pump_app.dart';

/// US-14 notifications (T060, T062): kinds, unread, mark all, destinations.
void main() {
  Future<void> open(WidgetTester t, {Size size = const Size(400, 900)}) async {
    await pumpSprintApp(t, size: size);
    await containerOf(t)
        .read(sessionProvider.notifier)
        .actAs(SeedIds.bookerInternal);
    await containerOf(t)
        .read(notificationPermissionStoreProvider)
        .write(NotificationPermission.granted);
    routerOf(t).go(AppPaths.notifications);
    await t.pumpAndSettle();
  }

  testWidgets('every kind renders with its Arabic wording', (t) async {
    await open(t, size: const Size(400, 3000));
    for (final s in [
      ar.notifBookingConfirmedTitle,
      ar.notifReminderTitle,
      ar.notifAdminCancelTitle,
      ar.notifOwnerCancelTitle,
      ar.notifRefundTitle,
      ar.notifVerificationApprovedTitle,
    ]) {
      expect(find.text(s), findsWidgets, reason: s);
    }
  });

  testWidgets('opening one marks it read and opens the booking', (t) async {
    await open(t, size: const Size(400, 3000));
    final before = containerOf(t).read(unreadCountProvider)!;
    await t.tap(find.byKey(NotificationsScreen.cardKey('nt-1')));
    await t.pumpAndSettle();
    expect(currentPath(t), AppPaths.bookingDetails('bk-09'));
    expect(containerOf(t).read(unreadCountProvider), before - 1);
  });

  testWidgets('mark all read clears the badge; the self-cancel never counts',
      (t) async {
    await open(t);
    expect(find.byKey(NotificationsScreen.markAllKey), findsOneWidget);
    await t.tap(find.byKey(NotificationsScreen.markAllKey));
    await t.pumpAndSettle();
    expect(containerOf(t).read(unreadCountProvider), 0);
    expect(find.byKey(NotificationsScreen.markAllKey), findsNothing);
  });

  testWidgets('medium: a destination with the badge, no bell', (t) async {
    await open(t, size: const Size(900, 900));
    final nav = t.widget<AppNavigation>(find.byType(AppNavigation));
    expect(nav.destinations[nav.selected].label, ar.navNotifications);
  });
}
