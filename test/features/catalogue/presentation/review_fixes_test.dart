import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/data/in_memory_data_layer.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/presentation/providers/catalogue_providers.dart';

import '../fixtures/catalogue_fixtures.dart';

final _seedNow = CairoTime.atWallClock(2026, 11, 14, 8);

ProviderContainer _container({
  required DateTime Function() now,
  Set<String> unpublishIds = const {},
}) {
  final layer = InMemoryDataLayer.create(
    clock: Clock(now),
    seed: catalogueSeed(_seedNow, unpublishIds: unpublishIds),
    paymentDelay: Duration.zero,
  );
  return ProviderContainer(
    overrides: [
      dataLayerProvider.overrideWithValue(layer),
      appClockProvider.overrideWithValue(Clock(now)),
    ],
  );
}

void main() {
  test('starting from a home type chip drops the other filters', () {
    final container = _container(now: () => _seedNow);
    addTearDown(container.dispose);
    final notifier = container.read(facilityFilterProvider.notifier);
    notifier.setFree(true);
    notifier.setOwningUnit(SeedIds.pool6);

    notifier.startWithType(FacilityType.swimming);

    final filter = container.read(facilityFilterProvider);
    expect(filter.type, FacilityType.swimming);
    expect(filter.free, isNull);
    expect(filter.owningUnitId, isNull);
  });

  test(
    "today's data is rebuilt after its screen goes away, not frozen",
    () async {
      var now = _seedNow;
      final container = _container(now: () => now);
      addTearDown(container.dispose);

      Future<int> poolCount() async {
        final sub = container.listen(facilitySummariesProvider, (_, _) {});
        final list = await container.read(facilitySummariesProvider.future);
        sub.close();
      // Let the auto-dispose run, as it does when a screen leaves the tree.
      await Future<void>.delayed(Duration.zero);
        return list
            .firstWhere((s) => s.facility.id == SeedIds.poolFacility)
            .today
            .count;
      }

      final morning = await poolCount();
      now = CairoTime.atWallClock(2026, 11, 14, 21, 30);
      final evening = await poolCount();

      expect(morning, greaterThan(0));
      expect(evening, lessThan(morning));
    },
  );

  test(
    'an upcoming booking stays on the home even if its facility is unpublished',
    () async {
      final open = _container(now: () => _seedNow);
      addTearDown(open.dispose);
      await open
          .read(sessionProvider.notifier)
          .selectUser(SeedIds.bookerInternal);
      final before = await open.read(homeContentProvider.future);
      expect(before.upcoming, isNotEmpty);
      final facilityId = before.upcoming.first.booking.facilityId;

      final hidden = _container(
        now: () => _seedNow,
        unpublishIds: {facilityId},
      );
      addTearDown(hidden.dispose);
      await hidden
          .read(sessionProvider.notifier)
          .selectUser(SeedIds.bookerInternal);
      final after = await hidden.read(homeContentProvider.future);

      expect(after.upcoming.length, before.upcoming.length);
      expect(
        after.upcoming
            .firstWhere((u) => u.booking.facilityId == facilityId)
            .facilityName,
        isNotEmpty,
      );
      expect(after.featured.any((s) => s.facility.id == facilityId), isFalse);
    },
  );

  test('a booking that has not started is not "booked before"', () async {
    // The same seed, read a year earlier: every booking is in the future.
    final container = _container(
      now: () => _seedNow.subtract(const Duration(days: 365)),
    );
    addTearDown(container.dispose);
    await container
        .read(sessionProvider.notifier)
        .selectUser(SeedIds.bookerInternal);

    final content = await container.read(homeContentProvider.future);

    expect(
      content.upcoming.every(
        (u) => u.booking.status == BookingStatus.confirmed,
      ),
      isTrue,
    );
    expect(content.suggestions, isEmpty);
  });
}
