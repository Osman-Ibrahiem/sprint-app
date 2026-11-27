import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/tokens/sprint_text.g.dart';
import 'package:sprint/core/widgets/day_strip/day_strip.dart';
import 'package:sprint/core/widgets/day_strip/day_strip_day.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

import '../../helpers/no_truncation.dart';
import '../../helpers/widget_harness.dart';

/// Decision T1 of refactor 000 on the DayStrip: every day name in full, never
/// an ellipsis, at 100%, 150% and 200%. The v2 day item (decision 18) fixed
/// the old pill, which cut six of seven names at 150% and 200%.
void main() {
  setUpAll(loadSprintFonts);

  final today = DateTime(2026, 11, 14);
  final week = [
    for (var i = 0; i < 7; i++)
      DayStripDay(date: DateTime(2026, 11, 14 + i), hasAvailability: true),
  ];

  for (final lang in ['ar', 'en']) {
    for (final scale in truncationScales) {
      testWidgets('DayStrip: no day name cut short, $lang x$scale', (
        tester,
      ) async {
        await pumpWidgetUnderAndSettle(
          tester,
          DayStrip(days: week, today: today, onSelected: (_) {}),
          size: const Size(390, 800),
          locale: Locale(lang),
          textScale: scale,
        );
        expectNoTruncation(tester, reason: 'DayStrip $lang x$scale');
        expect(tester.takeException(), isNull);
      });
    }
  }

  group('full name when it fits, short name when not (decision 18)', () {
    final wed = DateTime(2026, 11, 18);

    Future<String> wednesday(
      WidgetTester tester, {
      required String lang,
      required double scale,
      required double width,
      bool selected = false,
    }) async {
      await pumpWidgetUnderAndSettle(
        tester,
        DayStrip(
          days: week,
          today: today,
          selected: selected ? wed : null,
          onSelected: (_) {},
        ),
        size: Size(width, 800),
        locale: Locale(lang),
        textScale: scale,
      );
      expectNoTruncation(tester);
      return tester.widget<Text>(find.byKey(DayStrip.nameKey(wed))).data!;
    }

    testWidgets('Arabic on a phone: "الأربعاء", selected or not, at 100% and '
        '200% (compact week widths)', (tester) async {
      for (final selected in [false, true]) {
        for (final scale in [1.0, 2.0]) {
          expect(
            await wednesday(
              tester,
              lang: 'ar',
              scale: scale,
              width: 390,
              selected: selected,
            ),
            'الأربعاء',
          );
        }
      }
    });

    test('the rule: full when it fits the slot minus space-1 each side, '
        'else short ("الأربعاء" / "الأربع", "النهارده" / "اليوم")', () {
      String pick(String full, String short, double slot, double scale) =>
          DayStrip.fittingName(
            full: full,
            short: short,
            slotWidth: slot,
            style: SprintText.micro,
            scaler: TextScaler.linear(scale),
            direction: TextDirection.rtl,
          );
      expect(pick('الأربعاء', 'الأربع', 48, 1), 'الأربعاء');
      expect(pick('الأربعاء', 'الأربع', 48, 1.3), 'الأربع');
      expect(pick('الأربعاء', 'الأربع', 56, 1.3), 'الأربعاء');
      expect(pick('النهارده', 'اليوم', 48, 1), 'النهارده');
      expect(pick('النهارده', 'اليوم', 48, 1.3), 'اليوم');
    });

    testWidgets('today falls back to "اليوم" (en "Today") when "النهارده" '
        'does not fit', (tester) async {
      final ar = lookupAppLocalizations(const Locale('ar'));
      final en = lookupAppLocalizations(const Locale('en'));
      expect(ar.dayTodayShort, 'اليوم');
      expect(en.dayTodayShort, 'Today');
      // A wide day: the full word.
      await pumpWidgetUnderAndSettle(
        tester,
        DayStrip(days: week, today: today, onSelected: (_) {}),
        size: const Size(1000, 800),
      );
      expect(find.text('النهارده'), findsOneWidget);
    });

    testWidgets('English: "Wednesday" where the day is wide enough, "Wed" '
        'where it is not', (tester) async {
      // 390: seven days of about 55.7, too narrow for "Wednesday" (59).
      expect(await wednesday(tester, lang: 'en', scale: 1, width: 390), 'Wed');
      // 600, 840, 1200: all seven fit and spread over the width.
      for (final width in [600.0, 840.0, 1200.0]) {
        expect(
          await wednesday(tester, lang: 'en', scale: 1, width: width),
          'Wednesday',
          reason: '$width',
        );
      }
      // 320: six days and a half of about 49, too narrow for it.
      expect(await wednesday(tester, lang: 'en', scale: 1, width: 320), 'Wed');
    });

    testWidgets('never the Modern Standard forms; today stays "النهارده"', (
      tester,
    ) async {
      await pumpWidgetUnderAndSettle(
        tester,
        DayStrip(days: week, today: today, onSelected: (_) {}),
        size: const Size(1000, 800),
      );
      expect(find.text('النهارده'), findsOneWidget);
      expect(find.text('الاتنين'), findsOneWidget);
      expect(find.text('التلات'), findsOneWidget);
      expect(find.text('الاثنين'), findsNothing);
      expect(find.text('الثلاثاء'), findsNothing);
    });

    testWidgets('a screen reader hears the full name even when the short one '
        'shows', (tester) async {
      final handle = tester.ensureSemantics();
      await wednesday(tester, lang: 'ar', scale: 2, width: 390);
      expect(find.bySemanticsLabel(RegExp('الأربعاء')), findsOneWidget);
      handle.dispose();
    });
  });
}
