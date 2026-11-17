import 'package:flutter/widgets.dart' show Key, ValueKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/widgets/day_strip/day_strip.dart';
import 'package:sprint/core/widgets/slot_chip/slot_state.dart' as chip;
import 'package:sprint/features/booking/domain/schedule_selection.dart';
import 'package:sprint/features/booking/presentation/schedule/schedule_screen.dart';
import 'package:sprint/features/booking/presentation/schedule/selection_bar.dart';
import 'package:sprint/features/booking/presentation/schedule/trainer_step.dart';
import 'package:sprint/features/booking/presentation/summary/booking_summary_screen.dart';
import 'package:sprint/features/settings/domain/setting_definition.dart';
import 'package:sprint/features/settings/domain/setting_registry.dart';

import '../features/booking/presentation/schedule_harness.dart';
import '../helpers/pump_app.dart';

/// US-09: the trainer first, then one grid of that trainer's sessions (spec
/// US5; BR-09; FR-017 – FR-019). Seed: trainer 1 (capacity 3) gives sessions
/// in room 1 on Sat to Wed, 10:00–14:00; trainer 2 in room 2, 16:00–20:00;
/// trainer 3 in room 1 on Thu and Fri, 12:00–16:00.
void main() {
  final academy = SeedIds.academyFacility;
  const hisham = 'الكابتن هشام فؤاد';

  ScheduleSelection withTrainer(String trainer, {int? day}) =>
      ScheduleSelection(
        day: day == null ? null : DateTime(2026, 11, 14 + day),
        trainerId: trainer,
      );
  Key session(String unit, int hour) => ValueKey('slot-$unit-${hour * 60}');

  Future<void> choose(WidgetTester tester, String trainerId) async {
    await tester.tap(find.byKey(TrainerList.rowKey(trainerId)));
    await tester.pumpAndSettle();
  }

  group('the trainer step', () {
    testWidgets('comes first: names, bios, sessions words; no slots, no days', (
      tester,
    ) async {
      await openSchedule(tester, academy);
      expect(find.byKey(ScheduleScreen.trainerStepKey), findsOneWidget);
      expect(find.text(ar.bookingTrainerStepTitle), findsOneWidget);
      for (final t in [
        SeedIds.trainerRecord1,
        SeedIds.trainerRecord2,
        SeedIds.trainerRecord3,
      ]) {
        expect(find.byKey(TrainerList.rowKey(t)), findsOneWidget);
      }
      expect(find.text(hisham), findsOneWidget);
      expect(find.text(ar.bookingTrainerHasSessions), findsNWidgets(3));
      expect(chips(tester), isEmpty);
      expect(find.byType(DayStrip), findsNothing);
    });

    testWidgets(
      'choosing a trainer writes it in the address and shows one grid',
      (tester) async {
        await openSchedule(tester, academy);
        await choose(tester, SeedIds.trainerRecord1);
        expect(
          currentUri(tester).queryParameters,
          containsPair('trainer', SeedIds.trainerRecord1),
        );
        expect(find.text(ar.bookingTrainerChosen(hisham)), findsOneWidget);
        expect(find.byType(DayStrip), findsOneWidget);
        expect(
          find.text(ar.bookingUnitLabel),
          findsNothing,
          reason: 'no unit picker',
        );
        expect(chips(tester), isNotEmpty);
      },
    );

    testWidgets('a facility with no trainers says so, with a way back', (
      tester,
    ) async {
      await openSchedule(tester, academy, overrides: [noTrainersCatalogue()]);
      expect(find.byKey(ScheduleScreen.emptyKey), findsOneWidget);
      expect(find.text(ar.bookingNoTrainersTitle), findsOneWidget);
      expect(find.text(ar.bookingBackToFacility), findsOneWidget);
    });
  });

  group('the sessions of a trainer (BR-09)', () {
    testWidgets(
      'only inside the trainer\'s availability, of the session length',
      (tester) async {
        await openSchedule(
          tester,
          academy,
          selection: withTrainer(SeedIds.trainerRecord1, day: 2),
        );
        expect(chips(tester).map((c) => c.start.hour), [10, 11, 12, 13]);
      },
    );

    testWidgets(
      'days without a session for that trainer have no availability',
      (tester) async {
        await openSchedule(
          tester,
          academy,
          selection: withTrainer(SeedIds.trainerRecord1, day: 2),
        );
        final strip = dayStrip(tester);
        // 2026-11-19 is a Thursday and 2026-11-20 a Friday: trainer 1 is off.
        expect(
          strip.days
              .firstWhere((d) => d.date == DateTime(2026, 11, 19))
              .hasAvailability,
          isFalse,
        );
        expect(
          strip.days
              .firstWhere((d) => d.date == DateTime(2026, 11, 20))
              .hasAvailability,
          isFalse,
        );
        expect(
          strip.days
              .firstWhere((d) => d.date == DateTime(2026, 11, 16))
              .hasAvailability,
          isTrue,
        );
      },
    );

    testWidgets('places left are the smaller of the room and the trainer', (
      tester,
    ) async {
      await openSchedule(
        tester,
        academy,
        selection: withTrainer(SeedIds.trainerRecord1, day: 2),
      );
      // Room 1 holds 6, trainer 1 takes 3: three places at 10:00 on Monday.
      expect(chipAtHour(tester, 10)!.remaining, 3);
    });

    testWidgets(
      'a session at the trainer\'s capacity is full while the room has places',
      (tester) async {
        await openSchedule(
          tester,
          academy,
          selection: withTrainer(SeedIds.trainerRecord1, day: 1),
        );
        final full = chipAtHour(tester, 11)!;
        expect(full.state, chip.SlotState.full);
        expect(full.onSelected, isNull);
        expect(chipAtHour(tester, 12)!.state, isNot(chip.SlotState.full));
      },
    );

    testWidgets('the session length is the setting: 90 minutes', (
      tester,
    ) async {
      await openSchedule(
        tester,
        academy,
        selection: withTrainer(SeedIds.trainerRecord1, day: 2),
        arrange: (l) async => l.settings.set(
          SettingKeys.sessionMinutes,
          90,
          const SettingScope.university(),
          actorId: SeedIds.superAdmin,
        ),
      );
      expect(chips(tester).map((c) => (c.start.hour, c.start.minute)), [
        (10, 0),
        (11, 30),
      ]);
    });
  });

  group('changing the trainer (FR-019)', () {
    testWidgets('clears the time, keeps the day when it is still valid', (
      tester,
    ) async {
      await openSchedule(
        tester,
        academy,
        selection: withTrainer(SeedIds.trainerRecord1, day: 2),
        signInAs: SeedIds.bookerInternal,
      );
      await tester.ensureVisible(find.byKey(session(SeedIds.room1, 10)));
      await tester.tap(find.byKey(session(SeedIds.room1, 10)));
      await tester.pumpAndSettle();
      expect(find.byKey(SelectionBar.barKey), findsOneWidget);

      await tester.tap(find.byKey(ChosenTrainerRow.changeKey));
      await tester.pumpAndSettle();
      expect(find.byKey(ScheduleScreen.trainerStepKey), findsOneWidget);
      expect(currentUri(tester).queryParameters, {'day': '2026-11-16'});

      await choose(tester, SeedIds.trainerRecord2);
      expect(currentUri(tester).queryParameters, {
        'day': '2026-11-16',
        'trainer': SeedIds.trainerRecord2,
      });
      expect(chips(tester).map((c) => c.start.hour), [16, 17, 18, 19]);
      expect(find.byKey(SelectionBar.barKey), findsNothing);
    });
  });

  group('the summary', () {
    testWidgets('names the trainer, the room and the session length', (
      tester,
    ) async {
      await openSchedule(
        tester,
        academy,
        selection: withTrainer(SeedIds.trainerRecord1, day: 2),
        signInAs: SeedIds.bookerInternal,
      );
      await tester.ensureVisible(find.byKey(session(SeedIds.room1, 10)));
      await tester.tap(find.byKey(session(SeedIds.room1, 10)));
      await tester.pumpAndSettle();
      expect(
        currentUri(tester).queryParameters,
        containsPair('unit', SeedIds.room1),
      );
      await tester.tap(find.byKey(SelectionBar.actionKey));
      await tester.pumpAndSettle();

      expect(find.byType(BookingSummaryScreen), findsOneWidget);
      expect(find.text(hisham), findsOneWidget);
      expect(find.text('غرفة تدريب 1'), findsOneWidget);
      expect(find.text(ar.bookingSessionLength(60)), findsOneWidget);
      expect(find.text(ar.bookingPayAction), findsOneWidget);
    });
  });

  group('empty and restored states', () {
    testWidgets('a trainer with no sessions in the window says so', (
      tester,
    ) async {
      await openSchedule(
        tester,
        academy,
        arrange: (l) async => l.settings.set(
          SettingKeys.bookingWindowDays,
          1,
          const SettingScope.university(),
          actorId: SeedIds.superAdmin,
        ),
      );
      expect(find.text(ar.bookingTrainerNoSessions), findsOneWidget);
      await choose(tester, SeedIds.trainerRecord3);
      expect(find.text(ar.bookingTrainerNoSessionsBody), findsOneWidget);
      expect(find.byKey(ChosenTrainerRow.changeKey), findsOneWidget);
    });

    testWidgets('a reload with trainer and time in the address restores both', (
      tester,
    ) async {
      await openSchedule(
        tester,
        academy,
        selection: ScheduleSelection(
          day: DateTime(2026, 11, 16),
          unitId: SeedIds.room1,
          trainerId: SeedIds.trainerRecord1,
          startMinutes: 10 * 60,
          endMinutes: 11 * 60,
        ),
      );
      expect(find.text(ar.bookingTrainerChosen(hisham)), findsOneWidget);
      expect(chipAtHour(tester, 10)!.state, chip.SlotState.selected);
      expect(find.byKey(SelectionBar.barKey), findsOneWidget);
    });

    testWidgets(
      'an unknown trainer in the address falls back to the trainer step',
      (tester) async {
        await openSchedule(
          tester,
          academy,
          selection: withTrainer('tr-gone', day: 2),
        );
        expect(find.byKey(ScheduleScreen.trainerStepKey), findsOneWidget);
        expect(find.text(ar.bookingChoiceGone), findsOneWidget);
      },
    );
  });
}
