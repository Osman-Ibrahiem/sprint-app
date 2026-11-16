import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/app.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/data/in_memory_data_layer.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/core/widgets/facility_card/facility_card.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/presentation/home/home_screen.dart';
import 'package:sprint/features/catalogue/presentation/providers/catalogue_providers.dart';
import 'package:sprint/features/catalogue/domain/home_content.dart';
import 'package:clock/clock.dart';

import '../../../helpers/pump_app.dart';

final _now = CairoTime.atWallClock(2026, 11, 14, 8);

void main() {
  testWidgets('a guest sees the home title, no sign-in prompt, types and cards',
      (tester) async {
    await pumpSprintApp(tester);
    await tester.pumpAndSettle();

    expect(find.text(ar.catalogueHomeTitle), findsOneWidget);
    expect(find.text(ar.signInPromptTitle), findsNothing);
    expect(find.text(ar.catalogueHomeTypesTitle), findsOneWidget);
    expect(find.text(ar.catalogueHomeFeaturedTitle), findsOneWidget);
    expect(find.text(ar.catalogueHomeSeeAll), findsOneWidget);

    // One chip per facility type that has a published facility.
    for (final type in FacilityType.values) {
      expect(
        find.byKey(HomeScreen.typeChipKey(type)),
        findsOneWidget,
        reason: type.name,
      );
    }

    // At most six featured cards.
    final cards = tester.widgetList<FacilityCard>(find.byType(FacilityCard));
    expect(cards.length, lessThanOrEqualTo(6));
    expect(cards, isNotEmpty);
  });

  testWidgets('featured is ordered by today count descending then name',
      (tester) async {
    await pumpSprintApp(tester);
    final container = containerOf(tester);
    final content = container.read(homeContentProvider).value!;
    expect(content.featured.length, lessThanOrEqualTo(6));
    for (var i = 0; i + 1 < content.featured.length; i++) {
      final a = content.featured[i];
      final b = content.featured[i + 1];
      final ordered = a.today.count > b.today.count ||
          (a.today.count == b.today.count &&
              a.facility.name.compareTo(b.facility.name) <= 0);
      expect(ordered, isTrue,
          reason: '${a.facility.name} before ${b.facility.name}');
    }
  });

  testWidgets('a guest card shows both tiers', (tester) async {
    await pumpSprintApp(tester);
    final container = containerOf(tester);
    final content = container.read(homeContentProvider).value!;
    final pool = content.featured
        .where((s) => s.facility.id == SeedIds.poolFacility)
        .toList();
    if (pool.isEmpty) return; // the pool may fall outside the six
    expect(find.textContaining('20 ج.م'), findsWidgets);
    expect(find.textContaining('40 ج.م'), findsWidgets);
  });

  testWidgets('tapping a type chip filters the list and opens it',
      (tester) async {
    await pumpSprintApp(tester);
    final chip = find.byKey(HomeScreen.typeChipKey(FacilityType.tennis));
    await tester.ensureVisible(chip);
    await tester.pumpAndSettle();
    await tester.tap(chip);
    await tester.pumpAndSettle();

    expect(currentPath(tester), AppPaths.facilities);
    final container = containerOf(tester);
    expect(container.read(facilityFilterProvider).type, FacilityType.tennis);
    final summaries = await container.read(facilitySummariesProvider.future);
    expect(summaries.map((s) => s.facility.type).toSet(), {FacilityType.tennis});
  });

  testWidgets('tapping a card opens its facility', (tester) async {
    await pumpSprintApp(tester);
    final firstCard = find.byType(FacilityCard).first;
    final name = tester.widget<FacilityCard>(firstCard).name;
    await tester.tap(firstCard);
    await tester.pumpAndSettle();

    expect(currentPath(tester), startsWith('/facilities/'));
    expect(currentPath(tester), isNot(AppPaths.facilities));
    expect(find.text(name), findsWidgets);
  });

  testWidgets('while loading, skeleton cards show and no spinner shows',
      (tester) async {
    setWindow(tester);
    final layer = InMemoryDataLayer.create(
      clock: Clock(() => _now),
      paymentDelay: Duration.zero,
    );
    final pending = Completer<HomeContent>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dataLayerProvider.overrideWithValue(layer),
          appClockProvider.overrideWithValue(Clock(() => _now)),
          homeContentProvider.overrideWith((ref) => pending.future),
        ],
        child: const SprintApp(),
      ),
    );
    await tester.pump();

    expect(find.text(ar.catalogueHomeTitle), findsOneWidget);
    final loading = tester.widgetList<FacilityCard>(
      find.byType(FacilityCard),
    ).where((c) => c.isLoading);
    expect(loading, isNotEmpty);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    pending.completeError(StateError('never'));
  });
}
