import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/features/account/presentation/edit_profile_screen.dart';

import '../helpers/pump_app.dart';

/// US-14 edit profile (T072, T073): save rule, locked fields, saved name.
void main() {
  Future<void> open(WidgetTester t, {bool guest = false}) async {
    await pumpSprintApp(t, size: const Size(400, 1000));
    if (!guest) {
      await containerOf(t)
          .read(sessionProvider.notifier)
          .actAs(SeedIds.bookerInternal);
    }
    routerOf(t).go(AppPaths.profileEdit);
    await t.pumpAndSettle();
  }

  bool saveEnabled(WidgetTester t) => t
      .widget<SprintButton>(find.byKey(EditProfileScreen.saveKey))
      .onPressed != null;

  testWidgets('Save needs a valid, changed name; a short name shows the error',
      (t) async {
    await open(t);
    expect(saveEnabled(t), isFalse);
    await t.enterText(find.byType(TextField).first, 'م');
    await t.pump();
    expect(find.text(ar.editProfileNameError), findsOneWidget);
    expect(saveEnabled(t), isFalse);
    await t.enterText(find.byType(TextField).first, '  منى سالم  ');
    await t.pump();
    expect(saveEnabled(t), isTrue);
  });

  testWidgets('email and phone are locked with the reason', (t) async {
    await open(t);
    expect(find.text(ar.editProfileLockedHelper), findsNWidgets(2));
  });

  testWidgets('saving shows the new name in the account', (t) async {
    await open(t);
    await t.enterText(find.byType(TextField).first, 'منى سالم');
    await t.pump();
    await t.tap(find.byKey(EditProfileScreen.saveKey));
    await t.pumpAndSettle();
    routerOf(t).go(AppPaths.profile);
    await t.pumpAndSettle();
    expect(find.text('منى سالم'), findsWidgets);
  });

  testWidgets('a guest cannot reach it', (t) async {
    await open(t, guest: true);
    expect(currentPath(t), AppPaths.signIn);
  });
}
