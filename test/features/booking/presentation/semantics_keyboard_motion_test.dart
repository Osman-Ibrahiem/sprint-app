import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/widgets/slot_chip/slot_state.dart' as chip;
import 'package:sprint/features/booking/domain/schedule_selection.dart';
import 'package:sprint/features/booking/presentation/schedule/schedule_notice_view.dart';
import 'package:sprint/features/booking/presentation/schedule/selection_bar.dart';
import 'package:sprint/features/booking/presentation/schedule/unit_picker.dart';
import 'package:sprint/features/booking/presentation/summary/booking_summary_screen.dart';

import '../../../helpers/pump_app.dart';
import 'schedule_harness.dart';

/// Screen readers, keyboard and reduced motion (spec US7 scenarios 5, 7, 8;
/// FR-041; SC-010).
void main() {
  final pool = SeedIds.poolFacility;
  ScheduleSelection lane(String unit, int day) =>
      ScheduleSelection(day: DateTime(2026, 11, 14 + day), unitId: unit);
  Key slot(String unit, int hour) => ValueKey('slot-$unit-${hour * 60}');

  bool focusIn(Key key) {
    var found = false;
    FocusManager.instance.primaryFocus?.context?.visitAncestorElements((e) {
      if (e.widget.key == key) {
        found = true;
        return false;
      }
      return true;
    });
    return found;
  }

  Future<bool> tabTo(WidgetTester tester, Key key, {int max = 80}) async {
    for (var i = 0; i < max; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      if (focusIn(key)) return true;
    }
    return false;
  }

  group('screen readers', () {
    testWidgets('a slot reads as a sentence; full and past say why', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await openSchedule(
        tester,
        pool,
        selection: lane(SeedIds.pool2, 3),
        now: cairoAt(0, 12, 30),
      );
      String label(Key k) => tester.getSemantics(find.byKey(k)).label;
      // Lane 2, day +3, 10:00 is full.
      final full = label(slot(SeedIds.pool2, 10));
      expect(full, contains(ar.slotFull));
      expect(full, contains('10'));
      expect(
        label(slot(SeedIds.pool2, 12)),
        contains(ar.slotAvailablePlaces(3)),
      );
      // Past: today at 9:00 with the clock at 12:30.
      routerOf(tester)
          .go(AppPaths.facilitySchedule(pool, lane(SeedIds.pool1, 0)));
      await tester.pumpAndSettle();
      expect(label(slot(SeedIds.pool1, 9)), contains(ar.slotPast));
      handle.dispose();
    });

    testWidgets('units and days carry their state in words', (tester) async {
      final handle = tester.ensureSemantics();
      await openSchedule(tester, pool, selection: lane(SeedIds.pool1, 1));
      expect(
        tester
            .getSemantics(find.byKey(UnitPicker.chipKey(SeedIds.pool2)))
            .label,
        ar.bookingUnitHasPlaces('حارة 2'),
      );
      expect(find.bySemanticsLabel(RegExp(ar.dayHasRoom)), findsWidgets);
      handle.dispose();
    });

    testWidgets('the notice is a live region', (tester) async {
      final handle = tester.ensureSemantics();
      await openSchedule(tester, pool, selection: lane('u-gone', 1));
      final node = tester.getSemantics(find.byType(ScheduleNoticeView));
      expect(node.flagsCollection.isLiveRegion, isTrue);
      expect(node.label, ar.bookingChoiceGone);
      handle.dispose();
    });

    testWidgets('the summary rows read as label: value', (tester) async {
      final handle = tester.ensureSemantics();
      await openSchedule(
        tester,
        SeedIds.futsalFacility,
        signInAs: SeedIds.bookerInternal,
      );
      routerOf(tester).go(
        AppPaths.bookingSummary(
          SeedIds.futsalFacility,
          ScheduleSelection(
            day: DateTime(2026, 11, 15),
            unitId: SeedIds.futsal2,
            startMinutes: 18 * 60,
            endMinutes: 19 * 60,
          ),
          shown: 140,
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsLabel(
          '${ar.bookingRowFacility}: ملعب كرة القدم الخماسي',
        ),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('${ar.bookingRowUnit}: ملعب ب'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('${ar.bookingRowTime}: 6:00 م – 7:00 م'),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  group('keyboard', () {
    testWidgets(
      'Tab reaches the unit, a slot and the action; Enter and Space select',
      (tester) async {
        await openSchedule(
          tester,
          SeedIds.futsalFacility,
          selection: ScheduleSelection(
            day: DateTime(2026, 11, 15),
            unitId: SeedIds.futsal1,
          ),
          signInAs: SeedIds.bookerInternal,
          size: const Size(400, 3000),
        );
        expect(
          await tabTo(tester, UnitPicker.chipKey(SeedIds.futsal2)),
          isTrue,
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(currentUri(tester).queryParameters['unit'], SeedIds.futsal2);

        expect(await tabTo(tester, slot(SeedIds.futsal2, 18)), isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pumpAndSettle();
        expect(chipAtHour(tester, 18)!.state, chip.SlotState.selected);

        expect(await tabTo(tester, SelectionBar.actionKey), isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(find.byType(BookingSummaryScreen), findsOneWidget);
      },
    );
  });

  group('reduced motion', () {
    testWidgets('selecting a slot settles in one frame', (tester) async {
      await openSchedule(
        tester,
        SeedIds.futsalFacility,
        selection: ScheduleSelection(
          day: DateTime(2026, 11, 15),
          unitId: SeedIds.futsal2,
        ),
      );
      await tester.ensureVisible(find.byKey(slot(SeedIds.futsal2, 18)));
      await tester.tap(find.byKey(slot(SeedIds.futsal2, 18)));
      await tester.pump();
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
      expect(chipAtHour(tester, 18)!.state, chip.SlotState.selected);
    });
  });
}
