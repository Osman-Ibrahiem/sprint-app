import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/features/notifications/presentation/notifications_screen.dart';

import '../helpers/pump_app.dart';

/// US-13 reminders (T063, T068): the cancel action is decided at display time.
void main() {
  Future<void> open(WidgetTester t) async {
    await pumpSprintApp(t, size: const Size(400, 3000));
    await containerOf(t)
        .read(sessionProvider.notifier)
        .actAs(SeedIds.bookerInternal);
    routerOf(t).go(AppPaths.notifications);
    await t.pumpAndSettle();
  }

  testWidgets('after the cutoff the reminder has no cancel, with a line',
      (t) async {
    await open(t); // seeded reminder is for the booking starting in an hour
    expect(find.byKey(reminderCancelKey), findsNothing);
    expect(find.textContaining(ar.notifReminderCutoffClosed), findsOneWidget);
  });
}
