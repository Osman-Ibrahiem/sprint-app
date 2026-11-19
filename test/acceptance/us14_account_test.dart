import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/features/account/presentation/account_screen.dart';
import 'package:sprint/features/auth/presentation/account_card.dart';

import '../helpers/pump_app.dart';

/// US-14 account (T069, T071): rows, notifications answer, sign out, guest.
void main() {
  Future<void> open(WidgetTester t, {bool guest = false}) async {
    await pumpSprintApp(t, size: const Size(400, 1400));
    if (!guest) {
      await containerOf(t)
          .read(sessionProvider.notifier)
          .actAs(SeedIds.bookerInternal);
    }
    routerOf(t).go(AppPaths.profile);
    await t.pumpAndSettle();
  }

  testWidgets('rows in order and no national ID anywhere', (t) async {
    await open(t);
    for (final s in [
      ar.accountPersonalData,
      ar.languageTitle,
      ar.appearanceTitle,
      ar.accountNotifications,
      ar.signOutConfirm,
    ]) {
      expect(find.text(s), findsWidgets, reason: s);
    }
    expect(find.textContaining('nationalId'), findsNothing);
  });

  testWidgets('personal data opens edit profile', (t) async {
    await open(t);
    await t.tap(find.byKey(AccountScreen.personalKey));
    await t.pumpAndSettle();
    expect(currentPath(t), AppPaths.profileEdit);
  });

  testWidgets('the notifications row shows the answer and re-asks',
      (t) async {
    await open(t);
    expect(find.text(ar.accountNotificationsOff), findsOneWidget);
    await t.tap(find.byKey(AccountScreen.notificationsKey));
    await t.pumpAndSettle();
    await t.tap(find.text(ar.permissionAllow));
    await t.pumpAndSettle();
    expect(find.text(ar.accountNotificationsOn), findsOneWidget);
  });

  testWidgets('sign out asks first, then returns to guest', (t) async {
    await open(t);
    await t.tap(find.byKey(AccountCard.signOutKey));
    await t.pumpAndSettle();
    expect(find.text(ar.signOutTitle), findsOneWidget);
    await t.tap(find.text(ar.signOutConfirm).last);
    await t.pumpAndSettle();
    expect(find.text(ar.signInPromptTitle), findsOneWidget);
  });

  testWidgets('a guest sees the sign-in card plus language and appearance',
      (t) async {
    await open(t, guest: true);
    expect(find.text(ar.signInPromptTitle), findsOneWidget);
    expect(find.text(ar.languageTitle), findsWidgets);
    expect(find.byKey(AccountScreen.personalKey), findsNothing);
  });
}
