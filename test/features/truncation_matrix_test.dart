import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/l10n/locale_notifier.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/core/widgets/day_strip/day_strip.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';

import '../helpers/no_truncation.dart';
import '../helpers/pump_app.dart';
import 'booking/presentation/schedule_harness.dart';

/// Decision T1 of refactor 000: the screen matrices at 100%, 150% and 200%
/// text, in Arabic and English, at every window class: no text is cut short
/// with an ellipsis. Overflow checks in the other matrices miss this, because
/// a cut text lays out without an error. Measured with the bundled Cairo.
///
/// Allowed (decision T3): an app bar title may end with "…" as the native
/// bars do, and then the full title must show in the page body; checked here.
///
/// Known failure: the DayStrip cuts day names at 150% and 200% until its
/// redesign (decision 18) lands.
void main() {
  setUpAll(loadSprintFonts);

  const widths = [390.0, 720.0, 1194.0, 1440.0];

  ScheduleSelection pick(String unit, int day, int from, int to) =>
      ScheduleSelection(
        day: DateTime(2026, 11, 14 + day),
        unitId: unit,
        startMinutes: from * 60,
        endMinutes: to * 60,
      );

  final accountScreens = [
    '/home',
    '/facilities',
    '/facilities/${SeedIds.poolFacility}',
    '/facilities/${SeedIds.academyFacility}',
    AppPaths.bookings,
    AppPaths.bookingDetails('bk-09'),
    AppPaths.bookingCancelled('bk-y02'),
    AppPaths.notifications,
    AppPaths.profile,
    AppPaths.profileEdit,
  ];

  final bookingScreens = [
    AppPaths.facilitySchedule(
      SeedIds.poolFacility,
      ScheduleSelection(day: DateTime(2026, 11, 16), unitId: SeedIds.pool2),
    ),
    AppPaths.facilitySchedule(
      SeedIds.hallFacility,
      pick(SeedIds.hall2, 1, 16, 19),
    ),
    AppPaths.facilitySchedule(SeedIds.academyFacility),
    AppPaths.bookingSummary(
      SeedIds.futsalFacility,
      pick(SeedIds.futsal2, 1, 18, 19),
      shown: 300,
    ),
  ];

  Future<void> visit(
    WidgetTester tester,
    List<String> paths,
    Set<String> cut,
  ) async {
    for (final path in paths) {
      routerOf(tester).go(path);
      await tester.pumpAndSettle();
      for (final text in truncatedTexts(
        tester,
        knownFailures: const {DayStrip},
      )) {
        cut.add('$text on $path');
      }
      for (final title in cutTitlesMissingFromBody(tester)) {
        cut.add('app bar title "$title" is cut and not in the body on $path');
      }
    }
  }

  for (final width in widths) {
    for (final lang in ['ar', 'en']) {
      for (final scale in truncationScales) {
        final name = '$width $lang x$scale';

        testWidgets('account screens: no text cut short at $name', (
          tester,
        ) async {
          await pumpSprintApp(tester, size: Size(width, 900), textScale: scale);
          final c = containerOf(tester);
          await c.read(sessionProvider.notifier).actAs(SeedIds.bookerInternal);
          await c.read(localeProvider.notifier).set(Locale(lang));
          await tester.pumpAndSettle();
          final cut = <String>{};
          await visit(tester, accountScreens, cut);
          expect(cut, isEmpty, reason: cut.join('\n'));
        });

        testWidgets('booking screens: no text cut short at $name', (
          tester,
        ) async {
          await pumpSprintApp(
            tester,
            size: Size(width, 900),
            textScale: scale,
            overrides: [appClockProvider.overrideWithValue(clockAt(satMorning))],
          );
          final c = containerOf(tester);
          await c.read(sessionProvider.notifier).actAs(SeedIds.bookerExternal);
          await c.read(localeProvider.notifier).set(Locale(lang));
          await tester.pumpAndSettle();
          final cut = <String>{};
          await visit(tester, bookingScreens, cut);
          expect(cut, isEmpty, reason: cut.join('\n'));
        });
      }
    }
  }
}
