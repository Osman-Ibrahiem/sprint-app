import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/catalogue/presentation/home/suggestions_section.dart';
import 'package:sprint/features/catalogue/presentation/home/upcoming_bookings_section.dart';
import 'package:sprint/features/catalogue/presentation/providers/catalogue_providers.dart';

import '../../../helpers/pump_app.dart';

final _now = CairoTime.atWallClock(2026, 11, 14, 8);

Future<void> openHome(WidgetTester tester, {String? userId}) async {
  await pumpSprintApp(
    tester,
    size: const Size(400, 3000),
    overrides: [appClockProvider.overrideWithValue(Clock(() => _now))],
  );
  if (userId != null) {
    await containerOf(tester).read(sessionProvider.notifier).selectUser(userId);
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets(
    'the booker sees only upcoming confirmed bookings, soonest first',
    (tester) async {
      await openHome(tester, userId: SeedIds.bookerInternal);
      final content = await containerOf(tester)
          .read(homeContentProvider.future);

      expect(content.upcoming, isNotEmpty);
      final starts = [for (final u in content.upcoming) u.booking.start];
      expect([...starts]..sort(), starts);
      for (final u in content.upcoming) {
        expect(u.booking.status, BookingStatus.confirmed);
        expect(u.booking.start.isAfter(_now), isTrue);
        expect(
          find.byKey(UpcomingBookingsSection.rowKey(u.booking.id)),
          findsOneWidget,
        );
      }
      expect(find.text(ar.statusConfirmed), findsWidgets);
      expect(find.text(ar.catalogueUpcomingSeeAll), findsOneWidget);
      expect(find.text(ar.catalogueUpcomingTitle), findsOneWidget);
    },
  );

  testWidgets('suggestions show their reason in words', (tester) async {
    await openHome(tester, userId: SeedIds.bookerInternal);
    final content = await containerOf(tester).read(homeContentProvider.future);
    expect(content.suggestions, isNotEmpty);
    expect(content.suggestions.length, lessThanOrEqualTo(4));
    expect(find.text(ar.catalogueSuggestionsTitle), findsOneWidget);
    for (final s in content.suggestions) {
      expect(
        find.byKey(SuggestionsSection.reasonKey(s.facility.facility.id)),
        findsOneWidget,
      );
    }
  });

  testWidgets(
    'a user with no upcoming bookings sees the short note and discovery',
    (tester) async {
      await openHome(tester, userId: SeedIds.hallManager);
      expect(find.byKey(UpcomingBookingsSection.noneKey), findsOneWidget);
      expect(find.text(ar.catalogueUpcomingNone), findsOneWidget);
      expect(find.text(ar.catalogueSuggestionsTitle), findsNothing);
      expect(find.text(ar.catalogueHomeFeaturedTitle), findsOneWidget);
    },
  );

  testWidgets('switching to guest removes all personal content', (
    tester,
  ) async {
    await openHome(tester, userId: SeedIds.bookerInternal);
    expect(find.text(ar.catalogueUpcomingTitle), findsOneWidget);
    await containerOf(tester).read(sessionProvider.notifier).selectUser(null);
    await tester.pump();
    expect(find.text(ar.catalogueUpcomingTitle), findsNothing);
    expect(find.text(ar.catalogueUpcomingNone), findsNothing);
    expect(find.text(ar.catalogueSuggestionsTitle), findsNothing);
    await tester.pumpAndSettle();
    expect(find.text(ar.catalogueUpcomingTitle), findsNothing);
    final content = await containerOf(tester).read(homeContentProvider.future);
    expect(content.upcoming, isEmpty);
    expect(content.suggestions, isEmpty);
  });
}
