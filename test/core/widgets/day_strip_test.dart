import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/tokens/sprint_colors.g.dart';
import 'package:sprint/core/widgets/day_strip/day_strip.dart';
import 'package:sprint/core/widgets/day_strip/day_strip_day.dart';

import '../../helpers/widget_harness.dart';

void main() {
  final today = DateTime(2026, 11, 14);
  List<DayStripDay> week({bool firstHasRoom = true, bool lastClosed = false}) =>
      [
        for (var i = 0; i < 7; i++)
          DayStripDay(
            date: DateTime(2026, 11, 14 + i),
            hasAvailability: i == 0 ? firstHasRoom : i != 2,
            isClosed: lastClosed && i == 6,
          ),
      ];

  Future<void> pump(
    WidgetTester tester,
    List<DayStripDay> days, {
    DateTime? selected,
    Size size = const Size(800, 900),
    Locale locale = const Locale('ar'),
    double textScale = 1,
  }) =>
      pumpWidgetUnderAndSettle(
        tester,
        DayStrip(
          days: days,
          today: today,
          selected: selected,
          onSelected: (_) {},
        ),
        size: size,
        locale: locale,
        textScale: textScale,
      );

  test('defaultSelection: the first day with room, else the first open day',
      () {
    expect(DayStrip.defaultSelection(week())!.date, DateTime(2026, 11, 14));

    final noRoom = [
      for (final d in week()) DayStripDay(date: d.date, hasAvailability: false),
    ];
    expect(DayStrip.defaultSelection(noRoom)!.date, DateTime(2026, 11, 14));

    final closedFirst = [
      DayStripDay(date: today, hasAvailability: false, isClosed: true),
      DayStripDay(
        date: DateTime(2026, 11, 15),
        hasAvailability: true,
      ),
    ];
    expect(DayStrip.defaultSelection(closedFirst)!.date, DateTime(2026, 11, 15));
  });

  testWidgets('shows exactly the supplied days, today first and named '
      '"النهارده"', (tester) async {
    await pump(tester, week().take(3).toList());
    expect(find.text('النهارده'), findsOneWidget);
    expect(find.text('الحد'), findsOneWidget);
    expect(find.text('الاتنين'), findsOneWidget);
    expect(find.text('التلات'), findsNothing);
    // Today is on the start side: right in Arabic.
    expect(
      tester.getCenter(find.text('النهارده')).dx,
      greaterThan(tester.getCenter(find.text('الاتنين')).dx),
    );
  });

  testWidgets('English puts today on the left', (tester) async {
    await pump(tester, week().take(3).toList(), locale: const Locale('en'));
    expect(find.text('Today'), findsOneWidget);
    expect(
      tester.getCenter(find.text('Today')).dx,
      lessThan(tester.getCenter(find.text('Mon')).dx),
    );
  });

  testWidgets('the selected day is primary / on-primary', (tester) async {
    await pump(tester, week(), selected: DateTime(2026, 11, 15));
    final sunday = tester.widget<Text>(find.text('الحد'));
    expect(sunday.style!.color, SprintColors.light.onPrimary);
    final pill = tester.widget<Container>(
      find
          .ancestor(of: find.text('الحد'), matching: find.byType(Container))
          .first,
    );
    expect((pill.decoration! as BoxDecoration).color, SprintColors.light.primary);
  });

  testWidgets('a closed day is not pressable and is spoken "مقفول"',
      (tester) async {
    var picks = 0;
    await pumpWidgetUnderAndSettle(
      tester,
      DayStrip(
        days: week(lastClosed: true),
        today: today,
        onSelected: (_) => picks++,
      ),
      size: const Size(800, 900),
    );
    expect(find.text('مقفول'), findsNothing);
    await tester.tap(find.text('الجمعة'));
    await tester.pumpAndSettle();
    expect(picks, 0);

    final handle = tester.ensureSemantics();
    expect(find.bySemanticsLabel(RegExp('مقفول')), findsOneWidget);
    handle.dispose();
  });

  testWidgets('compact scrolls horizontally and keeps the selected day '
      'visible', (tester) async {
    await pump(
      tester,
      week(),
      selected: DateTime(2026, 11, 20),
      size: const Size(400, 800),
    );
    final scroll = tester.widget<SingleChildScrollView>(
      find.byType(SingleChildScrollView).last,
    );
    expect(scroll.scrollDirection, Axis.horizontal);
  });

  testWidgets('medium and larger spread across the width', (tester) async {
    await pump(tester, week(), size: const Size(800, 900));
    expect(
      find.byWidgetPredicate(
        (w) => w is SingleChildScrollView && w.scrollDirection == Axis.horizontal,
      ),
      findsNothing,
    );
    expect(tester.getSize(find.byType(DayStrip)).width, greaterThan(600));
  });

  testWidgets('arrow keys move focus between days', (tester) async {
    await pump(tester, week());
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    final first = FocusManager.instance.primaryFocus?.debugLabel;
    expect(first, 'day-0');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    // In Arabic the left arrow moves to the next day in reading order.
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'day-1');
  });

  testWidgets('a one-day window and a thirty-day window both build',
      (tester) async {
    await pump(tester, [week().first]);
    expect(find.text('النهارده'), findsOneWidget);

    final month = [
      for (var i = 0; i < 30; i++)
        DayStripDay(date: DateTime(2026, 11, 14 + i), hasAvailability: true),
    ];
    await pump(tester, month, size: const Size(800, 900));
    expect(tester.takeException(), isNull);
  });

  testWidgets('non-consecutive days assert in debug builds', (tester) async {
    final broken = [
      week().first,
      DayStripDay(date: DateTime(2026, 11, 16), hasAvailability: true),
    ];
    await pump(tester, broken);
    expect(tester.takeException(), isA<AssertionError>());
  });

  testWidgets('the day pill is 64 high', (tester) async {
    await pump(tester, week());
    final pill = find
        .descendant(of: find.byType(DayStrip), matching: find.byType(Container))
        .first;
    expect(tester.getSize(pill).height, 64);
  });

  testWidgets('200% text does not overflow', (tester) async {
    await pump(tester, week(), size: const Size(400, 800), textScale: 2);
    expect(tester.takeException(), isNull);
  });
}
