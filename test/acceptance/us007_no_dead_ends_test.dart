import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';

import '../helpers/pump_app.dart';

/// T078 (FR-036, SC-009): no 007 route ends on a placeholder.
void main() {
  test('the two placeholders no longer exist', () {
    for (final f in [
      'lib/app/shell/placeholders/bookings_placeholder.dart',
      'lib/app/shell/placeholders/profile_placeholder.dart',
      'lib/app/shell/placeholders/pending_screen.dart',
    ]) {
      expect(File(f).existsSync(), isFalse, reason: f);
    }
  });

  final paths = [
    AppPaths.home,
    AppPaths.facilities,
    AppPaths.bookings,
    AppPaths.notifications,
    AppPaths.profile,
    AppPaths.profileEdit,
    AppPaths.bookingDetails('bk-09'),
    AppPaths.bookingDetails('bk-y02'),
    AppPaths.demo,
  ];

  for (final path in paths) {
    testWidgets('booker: $path renders a real screen', (t) async {
      await pumpSprintApp(t, size: const Size(400, 900));
      await containerOf(t)
          .read(sessionProvider.notifier)
          .actAs(SeedIds.bookerInternal);
      routerOf(t).go(path);
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(find.byType(Scaffold), findsWidgets);
    });
  }

  for (final path in [AppPaths.bookings, AppPaths.profile, AppPaths.home]) {
    testWidgets('guest: $path renders', (t) async {
      await pumpSprintApp(t);
      routerOf(t).go(path);
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
    });
  }
}
