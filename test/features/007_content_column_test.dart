// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/widgets/content_column/content_column.dart';
import 'package:sprint/features/notifications/data/notification_permission_store.dart';
import 'package:sprint/features/notifications/domain/notification_permission.dart';

import '../helpers/pump_app.dart';

/// H2: a bounded text column on Expanded and Large; compact is untouched.
void main() {
  final cases = {
    AppPaths.notifications: SprintExtras.notificationsColumnMax,
    AppPaths.profile: SprintExtras.accountColumnMax,
    AppPaths.profileEdit: SprintExtras.editProfileColumnMax,
  };
  for (final e in cases.entries) {
    for (final width in [1194.0, 1440.0, 390.0]) {
      testWidgets('${e.key} at $width', (t) async {
        await pumpSprintApp(t, size: Size(width, 900));
        final c = containerOf(t);
        await c.read(sessionProvider.notifier).actAs(SeedIds.bookerInternal);
        await c
            .read(notificationPermissionStoreProvider)
            .write(NotificationPermission.granted);
        routerOf(t).go(e.key);
        await t.pumpAndSettle();
        final column = find.byType(ContentColumn);
        if (width < 840) {
          // Compact: untouched (the full width, no side padding).
          final w = column.evaluate().isEmpty ? width : t.getSize(column).width;
          expect(w, width);
          return;
        }
        expect(column, findsOneWidget);
        final padding = t.widget<Padding>(
          find.descendant(of: column, matching: find.byType(Padding)).first,
        );
        final child = find.byWidget(padding.child!);
        expect(t.getSize(child).width, lessThanOrEqualTo(e.value));
      });
    }
  }
}
