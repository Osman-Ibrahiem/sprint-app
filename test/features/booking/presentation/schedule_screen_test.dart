import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/widgets/slot_chip/slot_state.dart' as chip;
import 'package:sprint/features/booking/domain/schedule_selection.dart';
import 'package:sprint/features/booking/presentation/schedule/schedule_screen.dart';

import '../../../helpers/pump_app.dart';
import 'schedule_harness.dart';

/// US1: a guest sees the days, units and slots (spec US1 scenarios 1 – 7, 10).
void main() {
  ScheduleSelection sel(int day, String unit) =>
      ScheduleSelection(day: DateTime(2026, 11, 14 + day), unitId: unit);

  testWidgets('seven days from today, none before and none after', (tester) async {
    await openSchedule(tester, SeedIds.poolFacility);
    final strip = dayStrip(tester);
    expect(strip.days, hasLength(7));
    expect(strip.days.first.date, DateTime(2026, 11, 14));
    expect(strip.days.last.date, DateTime(2026, 11, 20));
    expect(strip.today, DateTime(2026, 11, 14));
  });

  testWidgets('with no parameters the first day with places and first unit show',
      (tester) async {
    await openSchedule(tester, SeedIds.poolFacility);
    expect(dayStrip(tester).selected, DateTime(2026, 11, 14));
    expect(find.text('حارة 1'), findsWidgets);
    expect(currentUri(tester).queryParameters, isEmpty,
        reason: 'defaults do not rewrite the address');
  });

  testWidgets('lane 2: full on day +3 at 10:00, few-left on day +2', (tester) async {
    await openSchedule(tester, SeedIds.poolFacility, selection: sel(3, SeedIds.pool2));
    expect(isState(chipAtHour(tester, 10), chip.SlotState.full), isTrue);
    expect(chipAtHour(tester, 10)!.onSelected, isNull);

    routerOf(tester).go('/facilities/${SeedIds.poolFacility}/schedule'
        '?day=2026-11-16&unit=${SeedIds.pool2}');
    await tester.pumpAndSettle();
    final few = chipAtHour(tester, 12)!;
    expect(few.state, chip.SlotState.fewLeft);
    expect(few.remaining, 1);
    expect(find.text(ar.slotFewLeft(1)), findsOneWidget);
  });

  testWidgets('an exclusive unit shows no count', (tester) async {
    await openSchedule(tester, SeedIds.futsalFacility, selection: sel(1, SeedIds.futsal2));
    final all = chips(tester);
    expect(all, isNotEmpty);
    expect(all.every((c) => c.remaining == null), isTrue);
  });

  testWidgets('earlier slots today are past and cannot be chosen', (tester) async {
    await openSchedule(
      tester,
      SeedIds.poolFacility,
      selection: sel(0, SeedIds.pool1),
      now: cairoAt(0, 12, 30),
    );
    for (final h in [8, 9, 10, 11, 12]) {
      final c = chipAtHour(tester, h)!;
      expect(c.state, chip.SlotState.past, reason: '$h:00');
      expect(c.onSelected, isNull);
    }
    expect(find.text(ar.slotPast), findsWidgets);
  });

  testWidgets('pitch A has no slots on its closure day, pitch B has', (tester) async {
    await openSchedule(tester, SeedIds.futsalFacility, selection: sel(3, SeedIds.futsal1));
    expect(chips(tester), isEmpty);
    expect(find.byKey(ScheduleScreen.nothingLeftKey), findsOneWidget);
    routerOf(tester).go('/facilities/${SeedIds.futsalFacility}/schedule'
        '?day=2026-11-17&unit=${SeedIds.futsal2}');
    await tester.pumpAndSettle();
    expect(chips(tester), isNotEmpty);
  });

  testWidgets('the hall is closed on Friday: the day is closed', (tester) async {
    await openSchedule(tester, SeedIds.hallFacility);
    final friday = dayStrip(tester).days.firstWhere((d) => d.date.weekday == DateTime.friday);
    expect(friday.isClosed, isTrue);
    expect(dayStrip(tester).days.where((d) => !d.isClosed), hasLength(6));
  });

  testWidgets('one unit shows its name and no picker', (tester) async {
    await openSchedule(tester, SeedIds.gymFacility);
    expect(find.text('أرضية الصالة'), findsOneWidget);
    expect(find.text(ar.bookingUnitLabel), findsNothing);
  });

  testWidgets('several units show a picker marking places', (tester) async {
    await openSchedule(tester, SeedIds.poolFacility);
    for (var i = 1; i <= 6; i++) {
      expect(find.text('حارة $i'), findsWidgets);
    }
    expect(find.text(ar.bookingUnitLabel), findsOneWidget);
    expect(find.bySemanticsLabel(ar.bookingUnitHasPlaces('حارة 1')), findsOneWidget);
  });

  testWidgets('a guest sees both tier prices with their labels', (tester) async {
    await openSchedule(tester, SeedIds.poolFacility);
    expect(find.textContaining(ar.cataloguePriceInternalLabel), findsOneWidget);
    expect(find.textContaining(ar.cataloguePriceExternalLabel), findsOneWidget);
    expect(find.textContaining('20 ج.م'), findsOneWidget);
    expect(find.textContaining('40 ج.م'), findsOneWidget);
    expect(find.textContaining(ar.cataloguePriceBasisShared), findsWidgets);
  });

  testWidgets('an exclusive unit says the price is for the whole booking',
      (tester) async {
    await openSchedule(tester, SeedIds.futsalFacility);
    expect(find.textContaining(ar.cataloguePriceBasisExclusive), findsWidgets);
    expect(find.textContaining('140 ج.م'), findsOneWidget);
    expect(find.textContaining('300 ج.م'), findsOneWidget);
  });

  testWidgets('browsing never asks for sign-in', (tester) async {
    await openSchedule(tester, SeedIds.poolFacility);
    expect(currentUri(tester).path, '/facilities/${SeedIds.poolFacility}/schedule');
    expect(find.text(ar.signInTitle), findsNothing);
  });

  testWidgets('a free facility says it is free and has no payment step', (tester) async {
    await openSchedule(tester, SeedIds.hallFacility);
    expect(find.text(ar.bookingFree), findsOneWidget);
    expect(find.text(ar.catalogueFreeNoPayment), findsOneWidget);
  });
}
