import 'package:flutter/widgets.dart' show Key, ValueKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/widgets/slot_chip/slot_state.dart' as chip;
import 'package:sprint/features/booking/domain/booking_repository.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';
import 'package:sprint/features/booking/presentation/checkout/checkout_screen.dart';
import 'package:sprint/features/booking/presentation/schedule/schedule_screen.dart';
import 'package:sprint/features/booking/presentation/schedule/selection_bar.dart';
import 'package:sprint/features/booking/presentation/summary/booking_summary_screen.dart';

import '../features/booking/presentation/schedule_harness.dart';
import '../helpers/pump_app.dart';

/// US-06, up to the summary: an exclusive pitch slot (payment and the second
/// half of the story are feature 6). Two people for one slot: one wins.
void main() {
  final futsal = SeedIds.futsalFacility;
  final Key eighteen = ValueKey('slot-${SeedIds.futsal2}-${18 * 60}');
  final selection = ScheduleSelection(
    day: DateTime(2026, 11, 15),
    unitId: SeedIds.futsal2,
  );

  int count(WidgetTester tester) =>
      containerOf(tester).read(dataLayerProvider).bookings.allBookings.length;

  testWidgets(
    'an available pitch slot reaches the summary and then checkout with a Hold',
    (tester) async {
      await openSchedule(
        tester,
        futsal,
        selection: selection,
        signInAs: SeedIds.bookerInternal,
      );
      final before = count(tester);
      await tester.ensureVisible(find.byKey(eighteen));
      await tester.tap(find.byKey(eighteen));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(SelectionBar.actionKey));
      await tester.pumpAndSettle();
      expect(find.byType(BookingSummaryScreen), findsOneWidget);
      expect(find.text(ar.bookingCoverageWholeMax(22)), findsOneWidget);

      await tester.tap(find.byKey(BookingSummaryScreen.actionKey));
      await tester.pumpAndSettle();
      expect(find.byType(CheckoutScreen), findsOneWidget);
      expect(
        count(tester),
        before + 1,
        reason: 'the booking exists, on hold, from the summary (BR-12)',
      );
    },
  );

  testWidgets('two people for one slot: the second sees it was booked', (
    tester,
  ) async {
    await openSchedule(
      tester,
      futsal,
      selection: selection,
      signInAs: SeedIds.bookerInternal,
    );
    await tester.ensureVisible(find.byKey(eighteen));
    await tester.tap(find.byKey(eighteen));
    await tester.pumpAndSettle();

    // Another person's booking lands first (the repository serialises writes).
    final results = await Future.wait([
      containerOf(tester)
          .read(bookingRepositoryProvider)
          .create(
            BookingRequest(
              userId: SeedIds.bookerExternal,
              unitId: SeedIds.futsal2,
              start: cairoAt(1, 18),
              end: cairoAt(1, 19),
            ),
          ),
      containerOf(tester)
          .read(bookingRepositoryProvider)
          .create(
            BookingRequest(
              userId: SeedIds.userUnverified,
              unitId: SeedIds.futsal2,
              start: cairoAt(1, 18),
              end: cairoAt(1, 19),
            ),
          ),
    ]);
    expect(results.where((r) => r.isOk), hasLength(1));
    await tester.pumpAndSettle();

    expect(find.byType(ScheduleScreen), findsOneWidget);
    expect(find.text(ar.bookingFailSlotTaken), findsOneWidget);
    expect(chipAtHour(tester, 18)!.state, chip.SlotState.full);
    expect(find.byType(BookingSummaryScreen), findsNothing);
  });

  testWidgets('the summary of a taken slot is never reached', (tester) async {
    await openSchedule(
      tester,
      futsal,
      selection: selection,
      signInAs: SeedIds.bookerInternal,
    );
    await containerOf(tester)
        .read(bookingRepositoryProvider)
        .create(
          BookingRequest(
            userId: SeedIds.bookerExternal,
            unitId: SeedIds.futsal2,
            start: cairoAt(1, 18),
            end: cairoAt(1, 19),
          ),
        );
    routerOf(tester).go(
      AppPaths.bookingSummary(
        futsal,
        selection.withTime(
          unitId: SeedIds.futsal2,
          startMinutes: 18 * 60,
          endMinutes: 19 * 60,
        ),
        shown: 140,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(BookingSummaryScreen), findsNothing);
    expect(find.byType(ScheduleScreen), findsOneWidget);
    expect(find.text(ar.bookingFailSlotTaken), findsOneWidget);
  });
}
