import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/app/shell/root_header.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';

import '../../helpers/pump_app.dart';

/// T043: the bell sits in the header of Home and Facilities on compact for a
/// signed-in person only.
void main() {
  testWidgets('guest: no bell on compact', (t) async {
    await pumpSprintApp(t);
    expect(find.byKey(RootHeader.bellKey), findsNothing);
  });

  testWidgets('booker on compact: bell with the unread count, opens the '
      'centre', (t) async {
    await pumpSprintApp(t);
    await containerOf(t).read(sessionProvider.notifier).actAs(SeedIds.bookerInternal);
    await t.pumpAndSettle();
    expect(find.byKey(RootHeader.bellKey), findsOneWidget);
    routerOf(t).go(AppPaths.facilities);
    await t.pumpAndSettle();
    expect(find.byKey(RootHeader.bellKey), findsOneWidget);
    await t.tap(find.byKey(RootHeader.bellKey));
    await t.pumpAndSettle();
    expect(currentPath(t), AppPaths.notifications);
  });

  testWidgets('medium and up: no bell, the destination carries the badge',
      (t) async {
    await pumpSprintApp(t, size: const Size(900, 900));
    await containerOf(t).read(sessionProvider.notifier).actAs(SeedIds.bookerInternal);
    await t.pumpAndSettle();
    expect(find.byKey(RootHeader.bellKey), findsNothing);
  });
}
