import 'package:sprint/core/seed/seed_data.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/features/catalogue/domain/closure.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures/catalogue_fixtures.dart';

void main() {
  final now = CairoTime.atWallClock(2026, 11, 14, 8);

  group('seed extras', () {
    test('the tenant seed keeps the Foundation facility hours for lane 6', () {
      final seed = SeedData.build(now);
      final facilityHours =
          seed.hours.where((h) => h.ownerId == SeedIds.poolFacility);
      final laneSixHours = seed.hours.where((h) => h.ownerId == SeedIds.pool6);
      expect(laneSixHours, isEmpty);
      expect(facilityHours, isNotEmpty);
    });

    test('the lane-6 fixture gives lane 6 its own evening hours only', () {
      final seed = laneSixSeed(now);
      final laneSix = seed.hours.where((h) => h.ownerId == SeedIds.pool6).toList();
      expect(laneSix, hasLength(7));
      for (final h in laneSix) {
        expect(h.openMinutes, 16 * 60);
        expect(h.closeMinutes, 22 * 60);
      }
      expect(
        seed.hours.where((h) => h.ownerId == SeedIds.pool1),
        isEmpty,
        reason: 'other lanes get the facility hours, not their own',
      );
    });

    test('the tennis facility has an upcoming facility-scope closure', () {
      final seed = SeedData.build(now);
      final closure = seed.closures.firstWhere(
        (c) =>
            c.scope == ClosureScope.facility &&
            c.scopeId == SeedIds.tennisFacility,
      );
      expect(closure.reason, 'صيانة الملاعب');
      expect(closure.from.isAfter(now), isTrue);
      expect(closure.to.isAfter(closure.from), isTrue);
      expect(cairoDay(closure.from), 5, reason: 'five days from today');
      expect(cairoDay(closure.to), 6);
    });

    test('the closed-today fixture closes the tennis facility now', () {
      final seed = closedTodaySeed(now);
      final closure = seed.closures.firstWhere(
        (c) =>
            c.scope == ClosureScope.facility &&
            c.scopeId == SeedIds.tennisFacility &&
            !c.from.isAfter(now) &&
            c.to.isAfter(now),
      );
      expect(closure.reason, 'صيانة');
    });

    test('every seeded facility still has at least one active unit', () {
      final seed = SeedData.build(now);
      for (final facility in seed.facilities) {
        final units = seed.units
            .where((u) => u.facilityId == facility.id && u.isActive);
        expect(units, isNotEmpty, reason: facility.name);
      }
    });
  });
}

/// The Cairo day of [instant], relative to the fixture's "now".
int cairoDay(DateTime instant) {
  final today = CairoTime.toCairo(CairoTime.atWallClock(2026, 11, 14, 8));
  final day = CairoTime.toCairo(instant);
  return DateTime(day.year, day.month, day.day)
      .difference(DateTime(today.year, today.month, today.day))
      .inDays;
}
