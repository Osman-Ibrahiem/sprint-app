import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('switching user changes the Profile card (FR-031)',
      (tester) async {
    await pumpSprintApp(tester, size: const Size(400, 900));
    routerOf(tester).go('/profile');
    await tester.pumpAndSettle();
    expect(find.text(ar.signInPromptTitle), findsOneWidget);

    await tester.runAsync(
      () => containerOf(tester)
          .read(sessionProvider.notifier)
          .selectUser(SeedIds.bookerInternal),
    );
    await tester.pumpAndSettle();
    expect(find.text(ar.signInPromptTitle), findsNothing);
    expect(find.text('منى عبد الله'), findsOneWidget);
    expect(find.textContaining(ar.tierInternal), findsOneWidget);

    await tester.runAsync(
      () => containerOf(tester)
          .read(sessionProvider.notifier)
          .selectUser(SeedIds.trainer1),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining(ar.roleTrainer), findsOneWidget);
    expect(find.textContaining(ar.tierExternal), findsOneWidget);

    await tester.runAsync(
      () => containerOf(tester).read(sessionProvider.notifier).selectUser(null),
    );
    await tester.pumpAndSettle();
    expect(find.text(ar.signInPromptTitle), findsOneWidget);
  });

  testWidgets('the demo screen lists the users and the settings inspector',
      (tester) async {
    await pumpSprintApp(tester, size: const Size(500, 900));
    routerOf(tester).push('/demo');
    await tester.pumpAndSettle();
    final list = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.text(ar.demoGuest), 200, scrollable: list);
    expect(find.text(ar.demoUserTitle), findsWidgets);
    await tester.scrollUntilVisible(
      find.text(ar.demoSettingsPick),
      200,
      scrollable: list,
    );
    expect(find.text(ar.demoSettingsTitle), findsOneWidget);
  });
}
