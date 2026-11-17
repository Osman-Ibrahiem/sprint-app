import 'package:flutter/widgets.dart' show Key, ValueKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/data/in_memory_data_layer.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/widgets/slot_chip/slot_state.dart' as chip;
import 'package:sprint/features/booking/domain/booking_repository.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';
import 'package:sprint/features/booking/presentation/schedule/selection_bar.dart';
import 'package:sprint/features/booking/presentation/summary/booking_summary_screen.dart';
import 'package:sprint/features/settings/domain/booking_mode.dart';
import 'package:sprint/features/settings/domain/setting_definition.dart';
import 'package:sprint/features/settings/domain/setting_registry.dart';

import '../features/booking/presentation/schedule_harness.dart';
import '../helpers/pump_app.dart';

/// US-07: a place in a shared unit; the slot fills up and shows "مكتمل".
void main() {
  final hall = SeedIds.hallFacility;
  final Key nine = ValueKey('slot-${SeedIds.hall2}-${9 * 60}');
  final selection = ScheduleSelection(
    day: DateTime(2026, 11, 15),
    unitId: SeedIds.hall2,
  );

  // The free hall as a shared unit of six places, with five already booked.
  Future<void> sharedHallWithFive(InMemoryDataLayer l) async {
    await l.settings.set(
      SettingKeys.bookingMode,
      BookingMode.shared,
      const SettingScope.unit(SeedIds.hall2),
      actorId: SeedIds.superAdmin,
    );
    await l.settings.set(
      SettingKeys.capacity,
      6,
      const SettingScope.unit(SeedIds.hall2),
      actorId: SeedIds.superAdmin,
    );
    for (final user in [
      SeedIds.bookerInternal,
      SeedIds.userUnverified,
      SeedIds.userExpired,
      SeedIds.userEngPending,
      SeedIds.userRejected,
    ]) {
      await l.bookings.create(
        BookingRequest(
          userId: user,
          unitId: SeedIds.hall2,
          start: cairoAt(1, 9),
          end: cairoAt(1, 10),
        ),
      );
    }
  }

  testWidgets('a lane with one place left says so (few left)', (tester) async {
    // Lane 2 (capacity 3) has two bookings on day +2 at 12:00.
    await openSchedule(
      tester,
      SeedIds.poolFacility,
      selection: ScheduleSelection(
        day: DateTime(2026, 11, 16),
        unitId: SeedIds.pool2,
      ),
    );
    expect(chipAtHour(tester, 12)!.state, chip.SlotState.fewLeft);
    expect(find.text(ar.slotFewLeft(1)), findsOneWidget);
  });

  testWidgets(
    'five of six places taken: one more booking succeeds and the slot fills',
    (tester) async {
      await openSchedule(
        tester,
        hall,
        selection: selection,
        signInAs: SeedIds.bookerExternal,
        arrange: sharedHallWithFive,
      );
      expect(chipAtHour(tester, 9)!.state, chip.SlotState.fewLeft);
      expect(chipAtHour(tester, 9)!.remaining, 1);

      await tester.ensureVisible(find.byKey(nine));
      await tester.tap(find.byKey(nine));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(SelectionBar.actionKey));
      await tester.pumpAndSettle();
      expect(find.byType(BookingSummaryScreen), findsOneWidget);
      expect(find.text(ar.bookingCoverageOnePlace), findsOneWidget);
      await tester.tap(find.byKey(BookingSummaryScreen.actionKey));
      await tester.pumpAndSettle();

      routerOf(tester).pop();
      await tester.pumpAndSettle();
      final bookings = containerOf(tester).read(dataLayerProvider).bookings;
      expect(
        bookings.allBookings.where(
          (b) => b.unitId == SeedIds.hall2 && b.start == cairoAt(1, 9),
        ),
        hasLength(6),
      );
    },
  );

  testWidgets('a full slot shows مكتمل and cannot be selected', (tester) async {
    await openSchedule(
      tester,
      hall,
      selection: selection,
      signInAs: SeedIds.bookerExternal,
      arrange: (l) async {
        await sharedHallWithFive(l);
        await l.bookings.create(
          BookingRequest(
            userId: SeedIds.trainer1,
            unitId: SeedIds.hall2,
            start: cairoAt(1, 9),
            end: cairoAt(1, 10),
          ),
        );
      },
    );
    final full = chipAtHour(tester, 9)!;
    expect(full.state, chip.SlotState.full);
    expect(full.onSelected, isNull);
    expect(find.text(ar.slotFull), findsWidgets);
    await tester.ensureVisible(find.byKey(nine));
    await tester.tap(find.byKey(nine), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(SelectionBar), findsNothing);
  });
}
