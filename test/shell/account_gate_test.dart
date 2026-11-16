import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/shell/placeholders/sign_in_prompt.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/widgets/slot_chip/slot_chip.dart';
import 'package:sprint/core/widgets/slot_chip/slot_state.dart';
import 'package:sprint/features/auth/presentation/account_gate.dart';
import 'package:sprint/features/demo/presentation/gate_demo.dart';

import '../helpers/pump_app.dart';
import '../helpers/sign_in_steps.dart';
import '../helpers/sign_up_steps.dart';

/// The account gate over a screen that keeps its state (FR-016, FR-017,
/// research R6): sign in, sign up and dismiss all come back to the same place.
void main() {
  const slot = ValueKey<String>('gate-demo-slot-18');

  Future<void> openDemoAndSelectSlot(WidgetTester tester) async {
    routerOf(tester).go('/demo');
    await tester.pumpAndSettle();
    final book = find.byKey(slot);
    await tester.scrollUntilVisible(
      book,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.byKey(slot));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(slot));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(GateDemo.bookKey));
    await tester.pumpAndSettle();
  }

  SlotState slotState(WidgetTester tester) =>
      tester.widget<SlotChip>(find.byKey(slot)).state;

  double offset(WidgetTester tester) => tester
      .state<ScrollableState>(find.byType(Scrollable).first)
      .position
      .pixels;

  Future<void> tapBook(WidgetTester tester) async {
    await tester.ensureVisible(find.byKey(GateDemo.bookKey));
    await tester.tap(find.byKey(GateDemo.bookKey));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'a guest gets the prompt over the screen; dismiss changes nothing',
    (tester) async {
      await pumpSprintApp(tester, size: const Size(400, 1100));
      await openDemoAndSelectSlot(tester);
      final before = offset(tester);

      await tapBook(tester);
      expect(find.text(ar.gateTitle), findsOneWidget);
      expect(find.text(ar.gateBody(ar.gateReasonBook)), findsOneWidget);
      expect(find.text(ar.gateSignIn), findsOneWidget);
      expect(find.text(ar.gateSignUp), findsOneWidget);
      // The gate does not run the action.
      expect(find.text(ar.gateDemoReady), findsNothing);

      await tester.tap(find.byKey(AccountGatePrompt.dismissKey));
      await tester.pumpAndSettle();
      expect(find.text(ar.gateTitle), findsNothing);
      expect(currentPath(tester), '/demo');
      expect(find.text(ar.gateDemoDismissed), findsOneWidget);
      expect(slotState(tester), SlotState.selected);
      expect(offset(tester), before);
      expect(containerOf(tester).read(currentSessionProvider).isGuest, isTrue);
    },
  );

  testWidgets('sign in returns true to the same screen with its state kept', (
    tester,
  ) async {
    await pumpSprintApp(tester, size: const Size(400, 1100));
    await openDemoAndSelectSlot(tester);
    final before = offset(tester);

    await tapBook(tester);
    await tester.tap(find.byKey(AccountGatePrompt.signInKey));
    await tester.pumpAndSettle();
    expect(topUri(tester).path, '/sign-in');

    await signInWith(
      tester,
      identifier: 'mona@example.test',
      password: SeedIds.demoPassword,
    );
    expect(currentPath(tester), '/demo');
    expect(containerOf(tester).read(currentSessionProvider).isGuest, isFalse);
    expect(find.text(ar.gateDemoReady), findsOneWidget);
    expect(slotState(tester), SlotState.selected);
    expect(offset(tester), before);
    // Nothing was done for the person: a new tap is needed.
    expect(find.text(ar.gateDemoDismissed), findsNothing);
  });

  testWidgets('a signed-in person passes the gate without a prompt', (
    tester,
  ) async {
    await pumpSprintApp(tester, size: const Size(400, 1100));
    await containerOf(tester)
        .read(sessionProvider.notifier)
        .actAs(SeedIds.bookerInternal);
    await openDemoAndSelectSlot(tester);
    await tapBook(tester);
    expect(find.text(ar.gateTitle), findsNothing);
    expect(find.text(ar.gateDemoReady), findsOneWidget);
  });

  testWidgets('sign up through the code returns to the same screen', (
    tester,
  ) async {
    await pumpSprintApp(tester, size: const Size(400, 1100));
    await openDemoAndSelectSlot(tester);
    final before = offset(tester);

    await tapBook(tester);
    await tester.tap(find.byKey(AccountGatePrompt.signUpKey));
    await tester.pumpAndSettle();
    expect(topUri(tester).path, '/sign-up');

    await fillSignUp(tester);
    await tapText(tester, ar.signUpButton);
    expect(topUri(tester).path, '/confirm-email');
    await enterCode(tester, mailboxCode(tester, newEmail)!);
    await tapText(tester, ar.confirmEmailButton);

    expect(currentPath(tester), '/demo');
    expect(containerOf(tester).read(currentSessionProvider).isGuest, isFalse);
    expect(find.text(ar.gateDemoReady), findsOneWidget);
    expect(slotState(tester), SlotState.selected);
    expect(offset(tester), before);
  });

  testWidgets('backing out of sign in returns false and keeps the screen', (
    tester,
  ) async {
    await pumpSprintApp(tester, size: const Size(400, 1100));
    await openDemoAndSelectSlot(tester);
    await tapBook(tester);
    await tester.tap(find.byKey(AccountGatePrompt.signInKey));
    await tester.pumpAndSettle();
    routerOf(tester).pop();
    await tester.pumpAndSettle();
    expect(currentPath(tester), '/demo');
    expect(find.text(ar.gateDemoDismissed), findsOneWidget);
    expect(slotState(tester), SlotState.selected);
  });

  testWidgets(
    'the guest prompt on My Bookings goes straight to sign in (FR-019)',
    (tester) async {
      await pumpSprintApp(tester);
      routerOf(tester).go('/bookings');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(SignInPrompt.signInKey));
      await tester.pumpAndSettle();
      // The person already chose: the gate does not ask again.
      expect(find.text(ar.gateTitle), findsNothing);
      expect(topUri(tester).path, '/sign-in');
      routerOf(tester).pop();
      await tester.pumpAndSettle();
      expect(currentPath(tester), '/bookings');
    },
  );

  testWidgets('the guest prompt goes straight to sign up (FR-019)', (
    tester,
  ) async {
    await pumpSprintApp(tester);
    routerOf(tester).go('/bookings');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(SignInPrompt.signUpKey));
    await tester.pumpAndSettle();
    expect(find.text(ar.gateTitle), findsNothing);
    expect(topUri(tester).path, '/sign-up');
  });
}
