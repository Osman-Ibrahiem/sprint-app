import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/adaptive/adaptive_pressable.dart';
import 'package:sprint/core/l10n/locale_notifier.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/theme/theme_mode_notifier.dart';
import 'package:sprint/core/widgets/day_strip/day_strip.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';
import 'package:sprint/features/booking/presentation/schedule/selection_bar.dart';

import '../../../helpers/pump_app.dart';
import 'schedule_harness.dart';

/// Every booking screen at every width, language, theme and text scale: no
/// overflow, no error and every tap target at least 48 (spec US7 scenarios 1,
/// 2, 6; FR-039 – FR-043; SC-010).
void main() {
  const widths = [400.0, 700.0, 1000.0, 1300.0];

  ScheduleSelection pick(
    String unit,
    int day,
    int from,
    int to, {
    String? trainer,
  }) => ScheduleSelection(
    day: DateTime(2026, 11, 14 + day),
    unitId: unit,
    trainerId: trainer,
    startMinutes: from * 60,
    endMinutes: to * 60,
  );

  // (name, location) of every screen of the flow, signed in as the external
  // booker except where it is a guest screen.
  final screens = <(String, String, bool)>[
    (
      'slot path',
      AppPaths.facilitySchedule(
        SeedIds.poolFacility,
        ScheduleSelection(day: DateTime(2026, 11, 16), unitId: SeedIds.pool2),
      ),
      false,
    ),
    (
      'slot selected',
      AppPaths.facilitySchedule(
        SeedIds.futsalFacility,
        pick(SeedIds.futsal2, 1, 18, 19),
      ),
      true,
    ),
    (
      'range selected',
      AppPaths.facilitySchedule(
        SeedIds.hallFacility,
        pick(SeedIds.hall2, 1, 16, 19),
      ),
      true,
    ),
    ('trainer step', AppPaths.facilitySchedule(SeedIds.academyFacility), false),
    (
      'trainer sessions',
      AppPaths.facilitySchedule(
        SeedIds.academyFacility,
        pick(SeedIds.room1, 2, 10, 11, trainer: SeedIds.trainerRecord1),
      ),
      true,
    ),
    (
      'paid summary',
      AppPaths.bookingSummary(
        SeedIds.futsalFacility,
        pick(SeedIds.futsal2, 1, 18, 19),
        shown: 300,
      ),
      true,
    ),
    (
      'free summary',
      AppPaths.bookingSummary(
        SeedIds.hallFacility,
        pick(SeedIds.hall2, 1, 16, 19),
        shown: 0,
      ),
      true,
    ),
    (
      'checkout placeholder',
      AppPaths.bookingCheckout(
        SeedIds.futsalFacility,
        pick(SeedIds.futsal2, 1, 18, 19),
      ),
      true,
    ),
  ];

  for (final width in widths) {
    for (final lang in ['ar', 'en']) {
      for (final dark in [false, true]) {
        for (final scale in [1.0, 2.0]) {
          final name = '$width $lang${dark ? ' dark' : ''} x$scale';
          testWidgets('no overflow and 48dp targets at $name', (tester) async {
            await pumpSprintApp(
              tester,
              size: Size(width, 900),
              textScale: scale,
              overrides: [
                appClockProvider.overrideWithValue(clockAt(satMorning)),
              ],
            );
            final c = containerOf(tester);
            await c.read(localeProvider.notifier).set(Locale(lang));
            await c
                .read(themeModeProvider.notifier)
                .set(dark ? ThemeMode.dark : ThemeMode.light);
            await c
                .read(sessionProvider.notifier)
                .actAs(SeedIds.bookerExternal);
            await tester.pumpAndSettle();
            for (final (label, path, _) in screens) {
              routerOf(tester).go(path);
              await tester.pumpAndSettle();
              final error = tester.takeException();
              expect(error, isNull, reason: '$label ($path)\n${_where(error)}');
              _expectTargets(tester, label);
            }
          });
        }
      }
    }
  }

  testWidgets(
    'Arabic: today is at the start (right) of the strip, slots run early to late',
    (tester) async {
      await openSchedule(
        tester,
        SeedIds.futsalFacility,
        selection: ScheduleSelection(
          day: DateTime(2026, 11, 15),
          unitId: SeedIds.futsal2,
        ),
      );
      final strip = find.byType(DayStrip);
      double dayX(String n) => tester
          .getCenter(find.descendant(of: strip, matching: find.text(n)))
          .dx;
      expect(
        dayX('14'),
        greaterThan(dayX('15')),
        reason: 'today is at the right',
      );
      expect(dayX('15'), greaterThan(dayX('16')));
      final nine = tester
          .getCenter(find.byKey(const ValueKey('slot-u-futsal-2-540')))
          .dx;
      final ten = tester
          .getCenter(find.byKey(const ValueKey('slot-u-futsal-2-600')))
          .dx;
      expect(
        nine,
        greaterThan(ten),
        reason: 'earlier slots sit nearer the start (right)',
      );
    },
  );

  testWidgets(
    'compact: the action stays reachable below the grid, not over it',
    (tester) async {
      await openSchedule(
        tester,
        SeedIds.futsalFacility,
        selection: pick(SeedIds.futsal2, 1, 18, 19),
        size: const Size(400, 700),
      );
      final bar = tester.getRect(find.byKey(SelectionBar.barKey));
      expect(bar.bottom, lessThanOrEqualTo(700));
      final list = tester.getRect(find.byKey(const ValueKey('schedule-grid')));
      expect(list.bottom, lessThanOrEqualTo(bar.top + 0.5));
    },
  );

  test('no hard-coded left/right alignment in the booking screens', () {
    final bad = RegExp(
      r'Alignment\.(centerLeft|centerRight|topLeft|topRight|bottomLeft|bottomRight)|'
      r'EdgeInsets\.(only|fromLTRB)\(.*(left|right)|TextAlign\.(left|right)|Positioned\(',
    );
    for (final f
        in Directory('lib/features/booking/presentation')
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))) {
      expect(bad.hasMatch(f.readAsStringSync()), isFalse, reason: f.path);
    }
  });
}

/// Render sizes, not semantics rects: those are clipped by scroll viewports.
void _expectTargets(WidgetTester tester, String label) {
  final finders = [
    find.byType(AdaptivePressable),
    find.byType(IconButton),
    find.byType(SprintButton),
  ];
  for (final finder in finders) {
    for (final element in finder.evaluate()) {
      final box = element.renderObject as RenderBox?;
      if (box == null || !box.hasSize) continue;
      expect(
        box.size.height,
        greaterThanOrEqualTo(47.9),
        reason: '${element.widget.runtimeType} on $label is ${box.size}',
      );
      expect(
        box.size.width,
        greaterThanOrEqualTo(47.9),
        reason: '${element.widget.runtimeType} on $label is ${box.size}',
      );
    }
  }
}

/// The widget a rendering error names, to find it quickly.
String _where(Object? error) {
  if (error is! FlutterError) return '$error';
  final lines = error.diagnostics.map((d) => d.toDescription()).join(' | ');
  return lines;
}
