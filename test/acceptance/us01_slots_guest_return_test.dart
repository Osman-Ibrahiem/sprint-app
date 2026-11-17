import 'package:flutter/widgets.dart' show Key, ValueKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/widgets/slot_chip/slot_state.dart' as chip;
import 'package:sprint/features/auth/presentation/account_gate.dart';
import 'package:sprint/features/booking/domain/booking_repository.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';
import 'package:sprint/features/booking/presentation/schedule/schedule_screen.dart';
import 'package:sprint/features/booking/presentation/schedule/selection_bar.dart';
import 'package:sprint/features/booking/presentation/summary/booking_summary_screen.dart';

import '../features/booking/presentation/schedule_harness.dart';
import '../helpers/pump_app.dart';
import '../helpers/sign_in_steps.dart';
import '../helpers/sign_up_steps.dart';

/// US-01, second half: a guest picks a slot, is asked to sign in or up, and
/// comes back to the same selection (spec US3; FR-021 – FR-023, FR-033, US-23).
void main() {
  final pool = SeedIds.poolFacility;
  final Key nine = ValueKey('slot-${SeedIds.pool5}-${9 * 60}');
  final selection = ScheduleSelection(
    day: DateTime(2026, 11, 15),
    unitId: SeedIds.pool5,
  );

  Future<void> guestSelectsNine(WidgetTester tester) async {
    await openSchedule(tester, pool, selection: selection);
    await tester.ensureVisible(find.byKey(nine));
    await tester.tap(find.byKey(nine));
    await tester.pumpAndSettle();
    expect(find.byKey(SelectionBar.barKey), findsOneWidget);
  }

  Future<void> tapContinue(WidgetTester tester) async {
    await tester.tap(find.byKey(SelectionBar.actionKey));
    await tester.pumpAndSettle();
  }

  void expectSameSelection(WidgetTester tester) {
    expect(find.byType(ScheduleScreen), findsOneWidget);
    expect(currentUri(tester).queryParameters, {
      'day': '2026-11-15',
      'unit': SeedIds.pool5,
      'start': '0900',
      'end': '1000',
    });
    expect(chipAtHour(tester, 9)!.state, chip.SlotState.selected);
  }

  testWidgets('a guest browses and selects with no prompt', (tester) async {
    await guestSelectsNine(tester);
    expect(find.text(ar.gateTitle), findsNothing);
    expect(currentUri(tester).path, AppPaths.facilitySchedule(pool));
  });

  testWidgets('continue asks for sign-in with the reason', (tester) async {
    await guestSelectsNine(tester);
    await tapContinue(tester);
    expect(find.text(ar.gateTitle), findsOneWidget);
    expect(find.text(ar.gateBody(ar.bookingGateReason)), findsOneWidget);
    expect(find.byType(BookingSummaryScreen), findsNothing);
  });

  testWidgets('sign in returns to the same selection, ready for a new tap', (
    tester,
  ) async {
    await guestSelectsNine(tester);
    await tapContinue(tester);
    await tester.tap(find.byKey(AccountGatePrompt.signInKey));
    await tester.pumpAndSettle();
    await signInWith(
      tester,
      identifier: 'karim@example.test',
      password: SeedIds.demoPassword,
    );

    expectSameSelection(tester);
    // The price line is now the external booker's own, and nothing moved on.
    expect(find.textContaining(ar.cataloguePriceExternalLabel), findsOneWidget);
    expect(find.textContaining(ar.cataloguePriceInternalLabel), findsNothing);
    expect(find.byType(BookingSummaryScreen), findsNothing);

    await tapContinue(tester);
    expect(find.byType(BookingSummaryScreen), findsOneWidget);
    // An EXTERNAL account books at the full price with no verification (US-23).
    expect(find.text('40 ج.م ${ar.cataloguePriceBasisShared}'), findsOneWidget);
    expect(find.byKey(BookingSummaryScreen.actionKey), findsOneWidget);
  });

  testWidgets('sign up returns to the same selection as an EXTERNAL account', (
    tester,
  ) async {
    await guestSelectsNine(tester);
    await tapContinue(tester);
    await tester.tap(find.byKey(AccountGatePrompt.signUpKey));
    await tester.pumpAndSettle();
    await fillSignUp(tester);
    await tapText(tester, ar.signUpButton);
    await enterCode(tester, mailboxCode(tester, newEmail)!);
    await tapText(tester, ar.confirmEmailButton);

    expectSameSelection(tester);
    expect(containerOf(tester).read(currentSessionProvider).isGuest, isFalse);
    await tapContinue(tester);
    expect(find.byType(BookingSummaryScreen), findsOneWidget);
    expect(find.text('40 ج.م ${ar.cataloguePriceBasisShared}'), findsOneWidget);
  });

  testWidgets('dismissing the gate keeps the selection and books nothing', (
    tester,
  ) async {
    await guestSelectsNine(tester);
    final before = containerOf(tester)
        .read(dataLayerProvider)
        .bookings
        .allBookings
        .length;
    await tapContinue(tester);
    await tester.tap(find.byKey(AccountGatePrompt.dismissKey));
    await tester.pumpAndSettle();
    expectSameSelection(tester);
    expect(
      containerOf(tester).read(dataLayerProvider).bookings.allBookings.length,
      before,
    );
    expect(containerOf(tester).read(currentSessionProvider).isGuest, isTrue);
  });

  testWidgets('a slot taken while signing in is said on the way back', (
    tester,
  ) async {
    await guestSelectsNine(tester);
    await tapContinue(tester);
    await tester.tap(find.byKey(AccountGatePrompt.signInKey));
    await tester.pumpAndSettle();
    // Another person fills lane 5's place meanwhile.
    final bookings = containerOf(tester).read(bookingRepositoryProvider);
    for (final user in [
      SeedIds.userUnverified,
      SeedIds.userExpired,
      SeedIds.userEngPending,
      SeedIds.userRejected,
      SeedIds.trainer1,
      SeedIds.trainer2,
      SeedIds.trainer3,
      SeedIds.hallManager,
    ]) {
      await bookings.create(
        BookingRequest(
          userId: user,
          unitId: SeedIds.pool5,
          start: cairoAt(1, 9),
          end: cairoAt(1, 10),
        ),
      );
    }
    await signInWith(
      tester,
      identifier: 'karim@example.test',
      password: SeedIds.demoPassword,
    );

    expect(find.text(ar.bookingFailSlotFull), findsOneWidget);
    expect(chipAtHour(tester, 9)!.state, chip.SlotState.full);
    expect(find.byKey(SelectionBar.barKey), findsNothing);
    expect(currentUri(tester).queryParameters.containsKey('start'), isFalse);
  });

  testWidgets('an overlap of the returning account is said on the way back', (
    tester,
  ) async {
    // Mona holds lane 1 on day +3 at 18:00; the guest picks tennis then.
    await openSchedule(
      tester,
      SeedIds.tennisFacility,
      selection: ScheduleSelection(
        day: DateTime(2026, 11, 17),
        unitId: SeedIds.tennis2,
      ),
    );
    final slot = ValueKey('slot-${SeedIds.tennis2}-${18 * 60}');
    await tester.ensureVisible(find.byKey(slot));
    await tester.tap(find.byKey(slot));
    await tester.pumpAndSettle();
    await tapContinue(tester);
    await tester.tap(find.byKey(AccountGatePrompt.signInKey));
    await tester.pumpAndSettle();
    await signInWith(
      tester,
      identifier: 'mona@example.test',
      password: SeedIds.demoPassword,
    );
    expect(find.textContaining('حمام السباحة الأولمبي'), findsOneWidget);
    expect(find.byKey(SelectionBar.barKey), findsNothing);
  });

  testWidgets(
    'opening the summary directly as a guest signs in and comes back',
    (tester) async {
      await openSchedule(tester, pool);
      final done = selection.withTime(
        unitId: SeedIds.pool5,
        startMinutes: 9 * 60,
        endMinutes: 10 * 60,
      );
      final target = AppPaths.bookingSummary(pool, done, shown: 20);
      routerOf(tester).go(target);
      await tester.pumpAndSettle();
      expect(currentUri(tester).path, AppPaths.signIn);
      expect(currentUri(tester).queryParameters['from'], target);

      await signInWith(
        tester,
        identifier: 'mona@example.test',
        password: SeedIds.demoPassword,
      );
      expect(find.byType(BookingSummaryScreen), findsOneWidget);
      expect(
        find.text('20 ج.م ${ar.cataloguePriceBasisShared}'),
        findsOneWidget,
      );
    },
  );

  testWidgets('a reload on the schedule reopens the same selection', (
    tester,
  ) async {
    await guestSelectsNine(tester);
    final address = currentUri(tester);
    // A web reload opens the same address again, in a fresh app.
    await openSchedule(
      tester,
      pool,
      selection: ScheduleSelection.fromQuery(address.queryParameters),
    );
    expectSameSelection(tester);
    expect(find.byKey(SelectionBar.barKey), findsOneWidget);
  });

  testWidgets('a seeded account that is already signed in passes straight on', (
    tester,
  ) async {
    await openSchedule(
      tester,
      pool,
      selection: selection,
      signInAs: SeedIds.bookerExternal,
    );
    await tester.ensureVisible(find.byKey(nine));
    await tester.tap(find.byKey(nine));
    await tester.pumpAndSettle();
    await tapContinue(tester);
    expect(find.text(ar.gateTitle), findsNothing);
    expect(find.byType(BookingSummaryScreen), findsOneWidget);
  });
}
