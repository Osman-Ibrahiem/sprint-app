import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/features/demo/presentation/demo_007_section.dart';
import 'package:sprint/features/notifications/data/notification_permission_store.dart';
import 'package:sprint/features/notifications/domain/notification_permission.dart';

import '../../../helpers/pump_app.dart';

/// T065, T067: the permission is asked once; the demo actions work.
void main() {
  testWidgets('asked once at the first visit to the centre, answer stored',
      (t) async {
    await pumpSprintApp(t, size: const Size(400, 900));
    await containerOf(t)
        .read(sessionProvider.notifier)
        .actAs(SeedIds.bookerInternal);
    routerOf(t).go(AppPaths.notifications);
    await t.pumpAndSettle();
    expect(find.text(ar.permissionTitle), findsOneWidget);
    await t.tap(find.text(ar.permissionAllow));
    await t.pumpAndSettle();
    expect(
      containerOf(t).read(notificationPermissionStoreProvider).read(),
      NotificationPermission.granted,
    );
    routerOf(t).go(AppPaths.home);
    await t.pumpAndSettle();
    routerOf(t).go(AppPaths.notifications);
    await t.pumpAndSettle();
    expect(find.text(ar.permissionTitle), findsNothing);
  });

  testWidgets('demo: a reminder and a facility cancel on demand', (t) async {
    await pumpSprintApp(t, size: const Size(400, 3000));
    await containerOf(t)
        .read(sessionProvider.notifier)
        .actAs(SeedIds.bookerInternal);
    routerOf(t).go(AppPaths.demo);
    await t.pumpAndSettle();
    await t.ensureVisible(find.byKey(Demo007Section.reminderKey));
    await t.tap(find.byKey(Demo007Section.reminderKey));
    await t.pumpAndSettle();
    expect(find.text(ar.demo007Done), findsOneWidget);
  });
}
