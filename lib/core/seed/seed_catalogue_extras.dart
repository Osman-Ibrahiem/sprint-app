import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/features/catalogue/domain/closure.dart';
import 'package:sprint/features/catalogue/domain/operating_hours.dart';

// Catalogue-only extras the Foundation's seed lacks (research R6, FR-029).
// Placeholders until Dr. Sara's real data arrives; all fictional.

/// Pool lane 6 has its own evening hours (4:00 pm to 10:00 pm every day) so the
/// details page can show a unit that differs from its facility (FR-021).
List<OperatingHours> seedCatalogueExtraHours() => [
      for (var day = 1; day <= 7; day++)
        OperatingHours(
          ownerId: SeedIds.pool6,
          dayOfWeek: day,
          openMinutes: 16 * 60,
          closeMinutes: 22 * 60,
        ),
    ];

/// An upcoming facility-scope closure on the tennis facility (5 to 6 days from
/// today). Upcoming, never current, so no other feature's test sees a closed
/// tennis court today; a "closed right now" state is a test fixture (R6).
List<Closure> seedCatalogueExtraClosures(DateTime now) {
  final today = CairoTime.toCairo(now);
  return [
    Closure(
      id: 'cl-cat-1',
      scope: ClosureScope.facility,
      scopeId: SeedIds.tennisFacility,
      from: CairoTime.atWallClock(today.year, today.month, today.day + 5),
      to: CairoTime.atWallClock(today.year, today.month, today.day + 6),
      reason: 'صيانة الملاعب',
    ),
  ];
}
