import 'package:flutter/widgets.dart' show Key, ValueKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/widgets/slot_chip/slot_state.dart' as chip;
import 'package:sprint/features/booking/domain/booking_repository.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';
import 'package:sprint/features/booking/presentation/schedule/selection_bar.dart';
import 'package:sprint/features/settings/domain/setting_definition.dart';
import 'package:sprint/features/settings/domain/setting_registry.dart';

import '../../../helpers/pump_app.dart';
import 'schedule_harness.dart';

/// US2: one slot in a paid facility, up to the summary (spec US2 scenarios
/// 1, 2, 5 – 7; FR-014, FR-020, FR-023, FR-033).
void main() {
  ScheduleSelection sel(int day, String unit) =>
      ScheduleSelection(day: DateTime(2026, 11, 14 + day), unitId: unit);

  Key slotKey(String unit, int hour) => ValueKey('slot-$unit-${hour * 60}');

  Future<void> tapSlot(WidgetTester tester, String unit, int hour) async {
    await tester.ensureVisible(find.byKey(slotKey(unit, hour)));
    await tester.tap(find.byKey(slotKey(unit, hour)));
    await tester.pumpAndSettle();
  }

  group('selecting', () {
    testWidgets('a tap selects, shows the bar with time and price', (
      tester,
    ) async {
      await openSchedule(
        tester,
        SeedIds.poolFacility,
        selection: sel(1, SeedIds.pool5),
        signInAs: SeedIds.bookerInternal,
      );
      expect(find.byKey(SelectionBar.barKey), findsNothing);

      await tapSlot(tester, SeedIds.pool5, 9);
      expect(chipAtHour(tester, 9)!.state, chip.SlotState.selected);
      expect(find.byKey(SelectionBar.barKey), findsOneWidget);
      expect(find.byKey(SelectionBar.actionKey), findsOneWidget);
      expect(find.textContaining('20 ج.م'), findsWidgets);
      expect(currentUri(tester).queryParameters, containsPair('start', '0900'));
      expect(currentUri(tester).queryParameters, containsPair('end', '1000'));
    });

    testWidgets('another slot moves the selection; the same slot clears it', (
      tester,
    ) async {
      await openSchedule(
        tester,
        SeedIds.poolFacility,
        selection: sel(1, SeedIds.pool5),
        signInAs: SeedIds.bookerInternal,
      );
      await tapSlot(tester, SeedIds.pool5, 9);
      await tapSlot(tester, SeedIds.pool5, 11);
      expect(chipAtHour(tester, 9)!.state, isNot(chip.SlotState.selected));
      expect(chipAtHour(tester, 11)!.state, chip.SlotState.selected);

      await tapSlot(tester, SeedIds.pool5, 11);
      expect(find.byKey(SelectionBar.barKey), findsNothing);
      expect(currentUri(tester).queryParameters.containsKey('start'), isFalse);
    });

    testWidgets('full and past slots cannot be selected', (tester) async {
      await openSchedule(
        tester,
        SeedIds.poolFacility,
        selection: sel(3, SeedIds.pool2),
        signInAs: SeedIds.bookerInternal,
      );
      await tester.ensureVisible(find.byKey(slotKey(SeedIds.pool2, 10)));
      await tester.tap(find.byKey(slotKey(SeedIds.pool2, 10)));
      await tester.pumpAndSettle();
      expect(find.byKey(SelectionBar.barKey), findsNothing);
    });

    testWidgets(
      'a non-booker role selects and continues like a booker (FR-023)',
      (tester) async {
        await openSchedule(
          tester,
          SeedIds.futsalFacility,
          selection: sel(1, SeedIds.futsal2),
          signInAs: SeedIds.hallManager,
        );
        await tapSlot(tester, SeedIds.futsal2, 10);
        await tester.tap(find.byKey(SelectionBar.actionKey));
        await tester.pumpAndSettle();
        expect(
          currentUri(tester).path,
          '/facilities/${SeedIds.futsalFacility}/schedule/summary',
        );
      },
    );
  });

  group('refusals', () {
    testWidgets(
      'an overlap with the booker\'s own booking is said at the tap (BR-13)',
      (tester) async {
        // The internal booker holds lane 1 on day +3 at 18:00.
        await openSchedule(
          tester,
          SeedIds.tennisFacility,
          selection: sel(3, SeedIds.tennis2),
          signInAs: SeedIds.bookerInternal,
        );
        await tapSlot(tester, SeedIds.tennis2, 18);
        expect(find.byType(SelectionBar), findsNothing);
        expect(chipAtHour(tester, 18)!.state, isNot(chip.SlotState.selected));
        expect(find.textContaining('حمام السباحة الأولمبي'), findsOneWidget);
        expect(find.textContaining('6:00'), findsWidgets);
        expect(
          currentUri(tester).queryParameters.containsKey('start'),
          isFalse,
        );
      },
    );

    testWidgets('a reached cap is said on continue (BR-14)', (tester) async {
      await openSchedule(
        tester,
        SeedIds.futsalFacility,
        selection: sel(1, SeedIds.futsal2),
        signInAs: SeedIds.bookerInternal,
        arrange: (l) async {
          await l.settings.set(
            SettingKeys.maxActiveBookingsPerUser,
            2,
            const SettingScope.university(),
            actorId: SeedIds.superAdmin,
          );
        },
      );
      await tapSlot(tester, SeedIds.futsal2, 10);
      await tester.tap(find.byKey(SelectionBar.actionKey));
      await tester.pumpAndSettle();
      expect(find.text(ar.bookingFailTooMany(2)), findsOneWidget);
      expect(
        currentUri(tester).path,
        '/facilities/${SeedIds.futsalFacility}/schedule',
      );
      expect(currentUri(tester).queryParameters.containsKey('start'), isFalse);
    });

    testWidgets(
      'a slot taken meanwhile is said, the selection clears, the chip is full',
      (tester) async {
        await openSchedule(
          tester,
          SeedIds.futsalFacility,
          selection: sel(1, SeedIds.futsal2),
          signInAs: SeedIds.bookerInternal,
        );
        await tapSlot(tester, SeedIds.futsal2, 10);
        expect(chipAtHour(tester, 10)!.state, chip.SlotState.selected);

        await containerOf(tester)
            .read(bookingRepositoryProvider)
            .create(
              BookingRequest(
                userId: SeedIds.bookerExternal,
                unitId: SeedIds.futsal2,
                start: cairoAt(1, 10),
                end: cairoAt(1, 11),
              ),
            );
        await tester.pumpAndSettle();
        expect(find.text(ar.bookingFailSlotTaken), findsOneWidget);
        expect(chipAtHour(tester, 10)!.state, chip.SlotState.full);
        expect(find.byType(SelectionBar), findsNothing);
        expect(
          currentUri(tester).queryParameters.containsKey('start'),
          isFalse,
        );
      },
    );
  });

  group('continue', () {
    testWidgets(
      'opens the summary with the same selection and the shown price',
      (tester) async {
        await openSchedule(
          tester,
          SeedIds.futsalFacility,
          selection: sel(1, SeedIds.futsal2),
          signInAs: SeedIds.bookerInternal,
        );
        await tapSlot(tester, SeedIds.futsal2, 18);
        await tester.tap(find.byKey(SelectionBar.actionKey));
        await tester.pumpAndSettle();
        final uri = currentUri(tester);
        expect(
          uri.path,
          '/facilities/${SeedIds.futsalFacility}/schedule/summary',
        );
        expect(uri.queryParameters, {
          'day': '2026-11-15',
          'unit': SeedIds.futsal2,
          'start': '1800',
          'end': '1900',
          'shown': '140',
        });
      },
    );
  });
}
