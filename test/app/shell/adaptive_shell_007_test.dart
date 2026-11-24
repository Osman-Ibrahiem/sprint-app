import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/l10n/locale_notifier.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/widgets/app_navigation/app_navigation.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

import '../../helpers/pump_app.dart';

/// T041, T042: notifications is a shell destination from the medium class for
/// a signed-in person, hidden on compact (the bell opens it) and for a guest.
void main() {
  Future<void> signedIn(WidgetTester tester, Size size) async {
    await pumpSprintApp(tester, size: size);
    await containerOf(tester)
        .read(sessionProvider.notifier)
        .actAs(SeedIds.bookerInternal);
    await tester.pumpAndSettle();
  }

  testWidgets('compact booker: four tabs, no notifications item', (t) async {
    await signedIn(t, const Size(400, 800));
    expect(find.text(ar.navNotifications), findsNothing);
    for (final l in [ar.navHome, ar.navFacilities, ar.navBookings, ar.navAccount]) {
      expect(find.text(l), findsWidgets, reason: l);
    }
  });

  testWidgets('medium booker: five items, the badge shows the unread count',
      (t) async {
    await signedIn(t, const Size(700, 900));
    expect(find.text(ar.navNotifications), findsWidgets);
    final nav = t.widget<AppNavigation>(find.byType(AppNavigation));
    expect(nav.destinations, hasLength(5));
    final unread = nav.destinations
        .singleWhere((d) => d.label == ar.navNotifications)
        .badgeCount;
    expect(unread, greaterThan(0));
    // Between bookings and account.
    expect(nav.destinations.map((d) => d.label).toList().indexOf(ar.navNotifications), 3);
  });

  testWidgets('English: the navigation item says "Alerts", the screen title '
      'stays "Notifications"; Arabic is "الإشعارات" (decision N1)', (t) async {
    final en = lookupAppLocalizations(const Locale('en'));
    expect(en.navNotifications, 'Alerts');
    expect(en.notificationsTitle, 'Notifications');
    expect(ar.navNotifications, 'الإشعارات');
    await signedIn(t, const Size(700, 900));
    await containerOf(t).read(localeProvider.notifier).set(const Locale('en'));
    await t.pumpAndSettle();
    final nav = t.widget<AppNavigation>(find.byType(AppNavigation));
    expect(nav.destinations.map((d) => d.label), contains('Alerts'));
  });

  testWidgets('a guest never gets the notifications item', (t) async {
    await pumpSprintApp(t, size: const Size(700, 900));
    expect(find.text(ar.navNotifications), findsNothing);
  });

  testWidgets('resize keeps the selection; /notifications on compact keeps '
      'the origin tab highlighted', (t) async {
    await signedIn(t, const Size(400, 800));
    routerOf(t).go(AppPaths.bookings);
    await t.pumpAndSettle();
    routerOf(t).go(AppPaths.notifications);
    await t.pumpAndSettle();
    var nav = t.widget<AppNavigation>(find.byType(AppNavigation));
    expect(nav.destinations[nav.selected].label, ar.navBookings);
    // Widen: it becomes a destination and is selected itself.
    t.view.physicalSize = const Size(700, 900);
    await t.pumpAndSettle();
    nav = t.widget<AppNavigation>(find.byType(AppNavigation));
    expect(nav.destinations[nav.selected].label, ar.navNotifications);
    // Narrow again: back to the tab it came from.
    t.view.physicalSize = const Size(400, 800);
    await t.pumpAndSettle();
    nav = t.widget<AppNavigation>(find.byType(AppNavigation));
    expect(nav.destinations[nav.selected].label, ar.navBookings);
  });

  testWidgets('guest on /notifications, /bookings/:id and /profile/edit goes '
      'to sign in with from', (t) async {
    await pumpSprintApp(t);
    for (final path in [
      AppPaths.notifications,
      AppPaths.bookingDetails('bk-09'),
      AppPaths.profileEdit,
    ]) {
      routerOf(t).go(path);
      await t.pumpAndSettle();
      final uri = routerOf(t).routerDelegate.currentConfiguration.uri;
      expect(uri.path, AppPaths.signIn, reason: path);
      expect(uri.queryParameters['from'], path);
    }
  });

  testWidgets("another user's booking id shows no access, never its data",
      (t) async {
    await signedIn(t, const Size(400, 800));
    routerOf(t).go(AppPaths.bookingDetails('bk-10')); // external booker's
    await t.pumpAndSettle();
    expect(find.text('bk-10'), findsNothing);
    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('a direct load of /notifications on compact highlights the home '
      'tab', (t) async {
    await signedIn(t, const Size(400, 800));
    routerOf(t).go(AppPaths.notifications);
    await t.pumpAndSettle();
    final nav = t.widget<AppNavigation>(find.byType(AppNavigation));
    expect(nav.destinations[nav.selected].label, ar.navHome);
  });
}
