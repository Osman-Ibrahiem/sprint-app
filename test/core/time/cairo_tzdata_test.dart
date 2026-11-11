import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:timezone/data/latest.dart' as full;
import 'package:timezone/timezone.dart' as tz;

import '../../../tool/gen_cairo_tzdata.dart';

void main() {
  test('only Cairo is bundled, so the web build stays small', () {
    CairoTime.ensureInitialized();
    expect(tz.timeZoneDatabase.locations.keys, ['Africa/Cairo']);
  });

  test('the committed Cairo-only database matches the full database', () {
    final generated = generateCairoTzdata();
    final committed = File('lib/core/time/cairo_tzdata.g.dart');
    expect(committed.readAsStringSync(), generated,
        reason: 'run dart run tool/gen_cairo_tzdata.dart');
  });

  test('offsets agree with the full database for 2026 - 2035', () {
    CairoTime.ensureInitialized();
    final small = tz.getLocation('Africa/Cairo');
    // Compare before the full database replaces the in-memory one.
    final instants = [
      for (var y = 2026; y <= 2035; y++)
        for (var m = 1; m <= 12; m++) DateTime.utc(y, m, 15, 12),
    ];
    final smallOffsets = [
      for (final i in instants) tz.TZDateTime.from(i, small).timeZoneOffset,
    ];
    full.initializeTimeZones();
    final all = tz.getLocation('Africa/Cairo');
    final fullOffsets = [
      for (final i in instants) tz.TZDateTime.from(i, all).timeZoneOffset,
    ];
    expect(smallOffsets, fullOffsets);
  });
}
