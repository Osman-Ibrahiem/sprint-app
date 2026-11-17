import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/widgets/slot_chip/slot_state.dart' as chip;
import 'package:sprint/features/booking/domain/schedule_selection.dart';
import 'package:sprint/features/booking/presentation/schedule/schedule_screen.dart';
import 'package:sprint/features/booking/presentation/schedule/selection_bar.dart';
import 'package:sprint/features/booking/presentation/schedule/selection_panel.dart';
import 'package:sprint/features/booking/presentation/summary/booking_summary_screen.dart';
import 'package:sprint/features/catalogue/presentation/facilities/facilities_screen.dart';

import '../../../helpers/pump_app.dart';
import 'schedule_harness.dart';

/// Layout follows the window, and the state survives resize, rotation and fold
/// (spec US7 scenarios 3, 4; FR-042; SC-011).
void main() {
  final futsal = SeedIds.futsalFacility;
  final selection = ScheduleSelection(
    day: DateTime(2026, 11, 15),
    unitId: SeedIds.futsal2,
    startMinutes: 18 * 60,
    endMinutes: 19 * 60,
  );

  Future<void> openAt(
    WidgetTester tester,
    double width, {
    ScheduleSelection? s,
    List<ui.DisplayFeature> features = const [],
  }) async {
    await openSchedule(
      tester,
      futsal,
      selection: s ?? selection,
      size: Size(width, 900),
      signInAs: SeedIds.bookerExternal,
    );
    if (features.isNotEmpty) {
      setWindow(tester, size: Size(width, 900), features: features);
      await tester.pumpAndSettle();
    }
  }

  group('the selection: bar or panel', () {
    for (final width in [400.0, 700.0]) {
      testWidgets('at $width the bar shows, not the panel', (tester) async {
        await openAt(tester, width);
        expect(find.byKey(SelectionBar.barKey), findsOneWidget);
        expect(find.byKey(SelectionPanel.panelKey), findsNothing);
      });
    }

    for (final width in [1000.0, 1300.0]) {
      testWidgets('at $width the panel sits beside the grid, no bar', (
        tester,
      ) async {
        await openAt(tester, width);
        expect(find.byKey(SelectionPanel.panelKey), findsOneWidget);
        expect(find.byKey(SelectionBar.barKey), findsNothing);
        final panel = tester.getRect(find.byKey(SelectionPanel.panelKey));
        final grid = tester.getRect(
          find.byKey(const ValueKey('schedule-grid')),
        );
        expect(panel.overlaps(grid), isFalse);
        expect(find.byKey(SelectionBar.actionKey), findsOneWidget);
      });

      testWidgets('at $width with nothing chosen the panel says what to do', (
        tester,
      ) async {
        await openAt(
          tester,
          width,
          s: ScheduleSelection(
            day: DateTime(2026, 11, 15),
            unitId: SeedIds.futsal2,
          ),
        );
        expect(find.text(ar.bookingSelectionPrompt), findsOneWidget);
      });
    }

    testWidgets('the panel\'s action opens the summary like the bar', (
      tester,
    ) async {
      await openAt(tester, 1300);
      await tester.tap(find.byKey(SelectionBar.actionKey));
      await tester.pumpAndSettle();
      expect(find.byType(BookingSummaryScreen), findsOneWidget);
    });
  });

  group('beside the facilities list', () {
    testWidgets(
      'the schedule, summary and success sit in the pane from medium up',
      (tester) async {
        await openAt(tester, 700);
        Finder inPane(Type t) => find.descendant(
          of: find.byKey(FacilitiesScreen.detailsSlotKey),
          matching: find.byType(t),
        );
        expect(find.byKey(FacilitiesScreen.listSlotKey), findsOneWidget);
        expect(inPane(ScheduleScreen), findsOneWidget);

        await tester.tap(find.byKey(SelectionBar.actionKey));
        await tester.pumpAndSettle();
        expect(inPane(BookingSummaryScreen), findsOneWidget);
        expect(find.byKey(FacilitiesScreen.listSlotKey), findsOneWidget);
      },
    );

    testWidgets('on compact they are full screen', (tester) async {
      await openAt(tester, 400);
      expect(find.byKey(FacilitiesScreen.listSlotKey), findsNothing);
      expect(find.byType(ScheduleScreen), findsOneWidget);
    });
  });

  group('resize, rotation and fold keep the selection', () {
    void expectKept(WidgetTester tester) {
      expect(currentUri(tester).queryParameters, {
        'day': '2026-11-15',
        'unit': SeedIds.futsal2,
        'start': '1800',
        'end': '1900',
      });
      expect(chipAtHour(tester, 18)!.state, chip.SlotState.selected);
    }

    testWidgets('1300 to 400 and back', (tester) async {
      await openAt(tester, 1300);
      expectKept(tester);
      setWindow(tester, size: const Size(400, 900));
      await tester.pumpAndSettle();
      expectKept(tester);
      expect(find.byKey(SelectionBar.barKey), findsOneWidget);
      setWindow(tester, size: const Size(1300, 900));
      await tester.pumpAndSettle();
      expectKept(tester);
      expect(find.byKey(SelectionPanel.panelKey), findsOneWidget);
    });

    testWidgets('portrait to landscape and back', (tester) async {
      await openAt(tester, 400);
      setWindow(tester, size: const Size(900, 400));
      await tester.pumpAndSettle();
      // A short window builds only the visible chips: the address and the
      // bar prove the selection is kept.
      expect(currentUri(tester).queryParameters['start'], '1800');
      expect(
        find.byType(SelectionBar).evaluate().length +
            find.byType(SelectionPanel).evaluate().length,
        1,
      );
      setWindow(tester, size: const Size(400, 900));
      await tester.pumpAndSettle();
      expectKept(tester);
    });

    const hinge = Rect.fromLTWH(490, 0, 20, 900);
    const feature = ui.DisplayFeature(
      bounds: hinge,
      type: ui.DisplayFeatureType.hinge,
      state: ui.DisplayFeatureState.postureHalfOpened,
    );

    testWidgets(
      'a vertical hinge: nothing sits under it, and unfolding keeps the state',
      (tester) async {
        await openAt(tester, 1000, features: const [feature]);
        for (final key in [
          FacilitiesScreen.listSlotKey,
          FacilitiesScreen.detailsSlotKey,
          SelectionPanel.panelKey,
          SelectionBar.barKey,
        ]) {
          final f = find.byKey(key);
          if (f.evaluate().isEmpty) continue;
          expect(tester.getRect(f).overlaps(hinge), isFalse, reason: '$key');
        }
        expectKept(tester);
        expect(tester.takeException(), isNull);

        setWindow(tester, size: const Size(1000, 900));
        await tester.pumpAndSettle();
        expectKept(tester);
      },
    );
  });
}
