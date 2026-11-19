import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/features/notifications/data/notification_permission_store.dart';
import 'package:sprint/features/notifications/domain/notification_permission.dart';
import 'package:sprint/features/notifications/presentation/notifications_screen.dart';
import 'package:sprint/features/notifications/presentation/providers/reminder_providers.dart';

import 'package:sprint/core/l10n/sprint_format.dart';

import '../helpers/pump_app.dart';

/// US-13 story 6, scenarios 1 to 5 (T068; BR-39, BR-40). The moving-clock
/// cases of the card itself are in `reminder_card_test.dart`.
void main() {
  Future<void> open(WidgetTester t, {bool granted = true}) async {
    await pumpSprintApp(t, size: const Size(400, 3000));
    final c = containerOf(t);
    await c.read(sessionProvider.notifier).actAs(SeedIds.bookerInternal);
    if (granted) {
      await c
          .read(notificationPermissionStoreProvider)
          .write(NotificationPermission.granted);
    }
    routerOf(t).go(AppPaths.notifications);
    await t.pumpAndSettle();
  }

  testWidgets('1: one reminder however many times the checker runs', (t) async {
    await open(t);
    final c = containerOf(t);
    await t.runAsync(() async {
      for (var i = 0; i < 4; i++) {
        await c.read(reminderSchedulerProvider).run();
        await c.read(reminderSchedulerProvider).forceReminder('bk-09');
      }
    });
    final list = await t.runAsync(
      () =>
          c.read(dataLayerProvider).notifications.list(SeedIds.bookerInternal),
    );
    expect(list!.where((n) => n.id == 'rem-bk-09'), hasLength(1));
  });

  testWidgets('2: after the cutoff the action is gone with a line, and the '
      'card opens the booking', (t) async {
    await open(t); // the seeded reminder is for the booking in an hour
    final card = find.byKey(NotificationsScreen.cardKey('rem-bk-y01'));
    expect(
      find.descendant(of: card, matching: find.byKey(reminderCancelKey)),
      findsNothing,
    );
    expect(
      find.descendant(
        of: card,
        matching: find.textContaining(ar.notifReminderCutoffClosed),
      ),
      findsOneWidget,
    );
    await t.tap(card);
    await t.pumpAndSettle();
    expect(currentPath(t), AppPaths.bookingDetails('bk-y01'));
  });

  testWidgets('2: before the cutoff the reminder offers cancel', (t) async {
    await open(t);
    final c = containerOf(t);
    await t.runAsync(
      () => c.read(reminderSchedulerProvider).forceReminder('bk-09'),
    );
    await t.pump(const Duration(seconds: 1));
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await t.pumpAndSettle();
    final card = find.byKey(NotificationsScreen.cardKey('rem-bk-09'));
    expect(
      find.descendant(of: card, matching: find.byKey(reminderCancelKey)),
      findsOneWidget,
    );
  });

  testWidgets('4: the permission dialog shows once and the answer is kept', (
    t,
  ) async {
    await open(t, granted: false);
    expect(find.text(ar.permissionTitle), findsOneWidget);
    await t.tap(find.text(ar.permissionDeny));
    await t.pumpAndSettle();
    expect(
      containerOf(t).read(notificationPermissionStoreProvider).read(),
      NotificationPermission.denied,
    );
    routerOf(t).go(AppPaths.home);
    await t.pumpAndSettle();
    routerOf(t).go(AppPaths.notifications);
    await t.pumpAndSettle();
    expect(find.text(ar.permissionTitle), findsNothing);
  });

  testWidgets('5: the text gives the real start time of the booking', (
    t,
  ) async {
    await open(t);
    final start = containerOf(t)
        .read(dataLayerProvider)
        .bookings
        .allBookings
        .firstWhere((x) => x.id == 'bk-y01')
        .start;
    final time = SprintFormat('ar').time(start);
    expect(
      find.textContaining(
        ar.notifReminderBodyAt('SP-1201', ar.notifReminderWhenToday(time)),
      ),
      findsOneWidget,
    );
  });
}
