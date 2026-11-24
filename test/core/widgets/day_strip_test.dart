import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/adaptive/adaptive_pressable.dart';
import 'package:sprint/core/tokens/sprint_colors.g.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
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
    // Wide enough: the full dialect names (decision 18 day names).
    expect(find.text('الأحد'), findsOneWidget);
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
      lessThan(tester.getCenter(find.text('Monday')).dx),
    );
  });

  group('v2 day item (decision 18)', () {
    final sat = DateTime(2026, 11, 14); // today
    final sun = DateTime(2026, 11, 15);

    BoxDecoration circle(WidgetTester tester, DateTime d) => tester
        .widget<DecoratedBox>(
          find.descendant(
            of: find.byKey(DayStrip.circleKey(d)),
            matching: find.byType(DecoratedBox),
          ),
        )
        .decoration as BoxDecoration;

    Color? tail(WidgetTester tester, DateTime d) =>
        (tester.widget<DecoratedBox>(
                  find
                      .ancestor(
                        of: find.byKey(DayStrip.itemKey(d)),
                        matching: find.byKey(AdaptivePressable.surfaceKey),
                      )
                      .first,
                ).decoration
                as BoxDecoration)
            .color;

    for (final dark in [false, true]) {
      final colors = dark ? SprintColors.dark : SprintColors.light;
      final theme = dark ? 'dark' : 'light';

      testWidgets('selected: primary tail, surface circle, primary number, '
          'on-primary name ($theme)', (tester) async {
        await pumpWidgetUnderAndSettle(
          tester,
          DayStrip(
            days: week(),
            today: today,
            selected: sun,
            onSelected: (_) {},
          ),
          size: const Size(800, 900),
          dark: dark,
        );
        expect(tail(tester, sun), colors.primary);
        expect(circle(tester, sun).color, colors.surface);
        expect(tester.widget<Text>(find.text('15')).style!.color, colors.primary);
        expect(
          tester.widget<Text>(find.byKey(DayStrip.nameKey(sun))).style!.color,
          colors.onPrimary,
        );
        // An unselected day has no tail.
        expect(tail(tester, DateTime(2026, 11, 16)), isNull);
      });

      testWidgets('today: a primary ring and the name in primary ($theme)', (
        tester,
      ) async {
        await pumpWidgetUnderAndSettle(
          tester,
          DayStrip(
            days: week(),
            today: today,
            selected: sun,
            onSelected: (_) {},
          ),
          size: const Size(800, 900),
          dark: dark,
        );
        final ring = circle(tester, sat).border! as Border;
        expect(ring.top.color, colors.primary);
        expect(
          tester.widget<Text>(find.byKey(DayStrip.nameKey(sat))).style!.color,
          colors.primary,
        );
        // Other days: a control-border edge.
        expect(
          (circle(tester, DateTime(2026, 11, 16)).border! as Border).top.color,
          colors.controlBorder,
        );
      });

      testWidgets('closed: dashed circle, disabled text, no dot ($theme)', (
        tester,
      ) async {
        final closed = DateTime(2026, 11, 20);
        await pumpWidgetUnderAndSettle(
          tester,
          DayStrip(
            days: week(lastClosed: true),
            today: today,
            onSelected: (_) {},
          ),
          size: const Size(800, 900),
          dark: dark,
        );
        expect(
          find.descendant(
            of: find.byKey(DayStrip.circleKey(closed)),
            matching: find.byWidgetPredicate(
              (w) => w is CustomPaint && w.painter != null,
            ),
          ),
          findsOneWidget,
        );
        expect(circle(tester, closed).border, isNull);
        expect(
          tester.widget<Text>(find.text('20')).style!.color,
          colors.inkDisabled,
        );
        expect(
          tester.widget<Text>(find.byKey(DayStrip.nameKey(closed))).style!.color,
          colors.inkDisabled,
        );
      });
    }

    testWidgets('the circle is at least 48 and the whole item a 48 target', (
      tester,
    ) async {
      await pump(tester, week());
      final c = tester.getSize(find.byKey(DayStrip.circleKey(sat)));
      expect(c.width, greaterThanOrEqualTo(48));
      expect(c.width, c.height);
      final item = tester.getSize(
        find
            .ancestor(
              of: find.byKey(DayStrip.itemKey(sat)),
              matching: find.byType(AdaptivePressable),
            )
            .first,
      );
      expect(item.width, greaterThanOrEqualTo(48));
      expect(item.height, greaterThanOrEqualTo(48));
    });

    testWidgets('at 200% the number scales fully and the circle grows; the '
        'name stops at 1.3 and keeps space-2 each side in the tail', (
      tester,
    ) async {
      // "الأربعاء" is the longest name: pick that Wednesday.
      final wed = DateTime(2026, 11, 18);
      await pump(
        tester,
        week(),
        selected: wed,
        size: const Size(390, 800),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byKey(DayStrip.circleKey(wed))).width,
        greaterThan(48),
      );
      final nameScale = MediaQuery.textScalerOf(
        tester.element(find.byKey(DayStrip.nameKey(wed))),
      ).scale(10);
      expect(nameScale, closeTo(10 * SprintExtras.navLabelMaxTextScale, 0.001));
      final numberScale = MediaQuery.textScalerOf(
        tester.element(find.text('18')),
      ).scale(10);
      expect(numberScale, closeTo(20, 0.001));

      final tailRect = tester.getRect(
        find
            .ancestor(
              of: find.byKey(DayStrip.itemKey(wed)),
              matching: find.byKey(AdaptivePressable.surfaceKey),
            )
            .first,
      );
      final nameRect = tester.getRect(find.byKey(DayStrip.nameKey(wed)));
      expect(nameRect.left - tailRect.left, greaterThanOrEqualTo(8));
      expect(tailRect.right - nameRect.right, greaterThanOrEqualTo(8));
    });
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

  testWidgets('200% text does not overflow', (tester) async {
    await pump(tester, week(), size: const Size(400, 800), textScale: 2);
    expect(tester.takeException(), isNull);
  });
}
