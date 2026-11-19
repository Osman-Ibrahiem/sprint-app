// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/l10n/locale_notifier.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/theme/theme_mode_notifier.dart';

import '../helpers/pump_app.dart';

/// T077: each new screen at four widths, both languages and themes, at 200%
/// text: nothing overflows.
void main() {
  final screens = [
    AppPaths.bookings,
    AppPaths.bookingDetails('bk-09'),
    AppPaths.bookingCancelled('bk-y02'),
    AppPaths.notifications,
    AppPaths.profile,
    AppPaths.profileEdit,
    AppPaths.facilities,
  ];
  for (final path in screens) {
    for (final width in [390.0, 720.0, 1194.0, 1440.0]) {
      for (final en in [false, true]) {
        for (final dark in [false, true]) {
          testWidgets('$path $width ${en ? 'en' : 'ar'} ${dark ? 'dark' : 'light'}',
              (t) async {
            await pumpSprintApp(
              t,
              size: Size(width, 900),
              textScale: 2,
            );
            final c = containerOf(t);
            await c
                .read(sessionProvider.notifier)
                .actAs(SeedIds.bookerInternal);
            await c.read(localeProvider.notifier).set(Locale(en ? 'en' : 'ar'));
            await c
                .read(themeModeProvider.notifier)
                .set(dark ? ThemeMode.dark : ThemeMode.light);
            await t.pumpAndSettle();
            routerOf(t).go(path);
            await t.pumpAndSettle();
            expect(t.takeException(), isNull);
          });
        }
      }
    }
  }
}
