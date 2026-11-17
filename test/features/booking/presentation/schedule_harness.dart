import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/data/in_memory_data_layer.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/core/widgets/day_strip/day_strip.dart';
import 'package:sprint/core/widgets/slot_chip/slot_chip.dart';
import 'package:sprint/core/widgets/slot_chip/slot_state.dart' as chip;
import 'package:sprint/features/booking/domain/schedule_selection.dart';
import 'package:flutter_riverpod/misc.dart' as rp;

import '../../../helpers/pump_app.dart';

/// Saturday 2026-11-14 08:00 in Cairo: the seed days are relative to it.
DateTime get satMorning {
  CairoTime.ensureInitialized();
  return CairoTime.atWallClock(2026, 11, 14, 8);
}

DateTime cairoAt(int day, int hour, [int minute = 0]) {
  CairoTime.ensureInitialized();
  return CairoTime.atWallClock(2026, 11, 14 + day, hour, minute);
}

/// Opens the schedule of [facilityId] with [selection] in the address.
Future<void> openSchedule(
  WidgetTester tester,
  String facilityId, {
  ScheduleSelection selection = ScheduleSelection.empty,
  DateTime? now,
  Size size = const Size(400, 1400),
  String? signInAs,
  List<rp.Override> overrides = const [],

  /// Changes the data (settings, bookings) before the app opens.
  Future<void> Function(InMemoryDataLayer layer)? arrange,
}) async {
  final t = now ?? satMorning;
  InMemoryDataLayer? layer;
  if (arrange != null) {
    layer = InMemoryDataLayer.create(
      clock: Clock(() => t),
      paymentDelay: Duration.zero,
    );
    await arrange(layer);
  }
  await pumpSprintApp(
    tester,
    size: size,
    overrides: [
      appClockProvider.overrideWithValue(Clock(() => t)),
      if (layer != null) dataLayerProvider.overrideWithValue(layer),
      ...overrides,
    ],
  );
  if (signInAs != null) {
    await containerOf(tester).read(sessionProvider.notifier).actAs(signInAs);
    await tester.pumpAndSettle();
  }
  routerOf(tester).go(AppPaths.facilitySchedule(facilityId, selection));
  await tester.pumpAndSettle();
}

DayStrip dayStrip(WidgetTester tester) =>
    tester.widget<DayStrip>(find.byType(DayStrip));

List<SlotChip> chips(WidgetTester tester) =>
    tester.widgetList<SlotChip>(find.byType(SlotChip)).toList();

/// The chip that starts at Cairo wall-clock [hour], or null.
SlotChip? chipAtHour(WidgetTester tester, int hour) {
  for (final c in chips(tester)) {
    if (c.start.hour == hour) return c;
  }
  return null;
}

bool isState(SlotChip? c, chip.SlotState s) => c?.state == s;

/// The location on screen, also when it was pushed (a pushed route keeps its
/// own match list).
Uri currentUri(WidgetTester tester) {
  final config = routerOf(tester).routerDelegate.currentConfiguration;
  final last = config.last;
  return last is ImperativeRouteMatch ? last.matches.uri : config.uri;
}

int stackDepth(WidgetTester tester) =>
    routerOf(tester).routerDelegate.currentConfiguration.matches.length;
