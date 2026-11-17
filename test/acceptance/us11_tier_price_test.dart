import 'package:flutter/widgets.dart' show Key, ValueKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/data/in_memory_data_layer.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/booking_quote.dart';
import 'package:sprint/features/booking/domain/booking_repository.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';
import 'package:sprint/features/booking/presentation/schedule/selection_bar.dart';
import 'package:sprint/features/booking/presentation/summary/booking_summary_screen.dart';
import 'package:sprint/features/catalogue/domain/price.dart';

import '../features/booking/presentation/schedule_harness.dart';
import '../helpers/pump_app.dart';

/// US-11: the price on screen is the price of the person's tier, and a
/// booking keeps the tier it was made with (spec US6; BR-15 – BR-18;
/// FR-026, FR-027).
void main() {
  final pool = SeedIds.poolFacility;
  final futsal = SeedIds.futsalFacility;

  ScheduleSelection poolLane(int hour) => ScheduleSelection(
    day: DateTime(2026, 11, 15),
    unitId: SeedIds.pool5,
    startMinutes: hour * 60,
    endMinutes: (hour + 1) * 60,
  );

  Future<void> summaryAs(
    WidgetTester tester,
    String user, {
    String facility = '',
    required ScheduleSelection selection,
    int? shown,
  }) async {
    final f = facility.isEmpty ? pool : facility;
    await openSchedule(tester, f, signInAs: user);
    routerOf(tester).go(AppPaths.bookingSummary(f, selection, shown: shown));
    await tester.pumpAndSettle();
  }

  group('the schedule', () {
    testWidgets(
      'the internal booker sees only their own price, marked as theirs',
      (tester) async {
        await openSchedule(
          tester,
          pool,
          selection: ScheduleSelection(
            day: DateTime(2026, 11, 15),
            unitId: SeedIds.pool5,
          ),
          signInAs: SeedIds.bookerInternal,
        );
        expect(
          find.textContaining(
            '${ar.cataloguePriceYours} · ${ar.cataloguePriceInternalLabel}',
          ),
          findsOneWidget,
        );
        expect(find.textContaining('20 ج.م'), findsOneWidget);
        expect(find.textContaining('40 ج.م'), findsNothing);
        expect(
          find.textContaining(ar.cataloguePriceExternalLabel),
          findsNothing,
        );
      },
    );

    testWidgets('the external booker sees the full price', (tester) async {
      await openSchedule(
        tester,
        pool,
        selection: ScheduleSelection(
          day: DateTime(2026, 11, 15),
          unitId: SeedIds.pool5,
        ),
        signInAs: SeedIds.bookerExternal,
      );
      expect(
        find.textContaining(ar.cataloguePriceExternalLabel),
        findsOneWidget,
      );
      expect(find.textContaining('40 ج.م'), findsOneWidget);
      expect(find.textContaining('20 ج.م'), findsNothing);
    });

    testWidgets('a guest sees both tiers', (tester) async {
      await openSchedule(tester, pool);
      expect(find.textContaining('20 ج.م'), findsOneWidget);
      expect(find.textContaining('40 ج.م'), findsOneWidget);
    });

    testWidgets(
      'an exclusive pitch is priced for the whole booking, on the booker\'s tier',
      (tester) async {
        await openSchedule(
          tester,
          futsal,
          selection: ScheduleSelection(
            day: DateTime(2026, 11, 15),
            unitId: SeedIds.futsal2,
          ),
          signInAs: SeedIds.bookerInternal,
        );
        expect(
          find.textContaining('140 ج.م ${ar.cataloguePriceBasisExclusive}'),
          findsOneWidget,
        );
      },
    );

    testWidgets('the selection bar shows the person\'s own price', (
      tester,
    ) async {
      await openSchedule(
        tester,
        pool,
        selection: ScheduleSelection(
          day: DateTime(2026, 11, 15),
          unitId: SeedIds.pool5,
        ),
        signInAs: SeedIds.bookerInternal,
      );
      final Key slot = ValueKey('slot-${SeedIds.pool5}-${9 * 60}');
      await tester.ensureVisible(find.byKey(slot));
      await tester.tap(find.byKey(slot));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byKey(SelectionBar.barKey),
          matching: find.text('20 ج.م'),
        ),
        findsOneWidget,
      );
    });
  });

  group('the summary', () {
    testWidgets('internal: the internal price, no verification hint', (
      tester,
    ) async {
      await summaryAs(
        tester,
        SeedIds.bookerInternal,
        selection: poolLane(9),
        shown: 20,
      );
      expect(find.text(ar.cataloguePriceInternalLabel), findsOneWidget);
      expect(
        find.text('20 ج.م ${ar.cataloguePriceBasisShared}'),
        findsOneWidget,
      );
      expect(find.byKey(BookingSummaryScreen.verifyKey), findsNothing);
      expect(find.text(ar.bookingVerifyHint), findsNothing);
    });

    testWidgets('external: the full price and a pointer to verification', (
      tester,
    ) async {
      await summaryAs(
        tester,
        SeedIds.bookerExternal,
        selection: poolLane(9),
        shown: 40,
      );
      expect(find.text(ar.cataloguePriceExternalLabel), findsOneWidget);
      expect(
        find.text('40 ج.م ${ar.cataloguePriceBasisShared}'),
        findsOneWidget,
      );
      expect(find.text(ar.bookingVerifyHint), findsOneWidget);
      // It never blocks the booking (BR-21).
      expect(find.byKey(BookingSummaryScreen.actionKey), findsOneWidget);
      await tester.tap(find.byKey(BookingSummaryScreen.verifyKey));
      await tester.pumpAndSettle();
      expect(currentUri(tester).path, AppPaths.profileVerification);
    });

    testWidgets('a pending request: the full price and "under review"', (
      tester,
    ) async {
      await summaryAs(
        tester,
        SeedIds.userEngPending,
        selection: poolLane(9),
        shown: 40,
      );
      expect(
        find.text('40 ج.م ${ar.cataloguePriceBasisShared}'),
        findsOneWidget,
      );
      expect(find.text(ar.bookingVerifyPending), findsOneWidget);
      expect(find.byKey(BookingSummaryScreen.verifyKey), findsNothing);
      expect(find.byKey(BookingSummaryScreen.actionKey), findsOneWidget);
    });

    testWidgets('a price that changed since the schedule says so', (
      tester,
    ) async {
      await summaryAs(
        tester,
        SeedIds.bookerInternal,
        selection: poolLane(9),
        shown: 40,
      );
      expect(find.byKey(BookingSummaryScreen.priceChangedKey), findsOneWidget);
      expect(find.text(ar.bookingPriceChanged), findsOneWidget);
      expect(
        find.text('20 ج.م ${ar.cataloguePriceBasisShared}'),
        findsOneWidget,
      );
    });

    testWidgets('no seeded offer discounts any price (decisions 2026-11-17)', (
      tester,
    ) async {
      // The pool has 20% off for the internal tier on Thursday afternoons:
      // 2026-11-19 at 15:00 is day +5.
      await openSchedule(tester, pool, signInAs: SeedIds.bookerInternal);
      final thursday = ScheduleSelection(
        day: DateTime(2026, 11, 19),
        unitId: SeedIds.pool5,
        startMinutes: 15 * 60,
        endMinutes: 16 * 60,
      );
      routerOf(tester).go(AppPaths.bookingSummary(pool, thursday, shown: 20));
      await tester.pumpAndSettle();
      expect(
        find.text('20 ج.م ${ar.cataloguePriceBasisShared}'),
        findsOneWidget,
      );
      expect(find.byKey(BookingSummaryScreen.priceChangedKey), findsNothing);
    });
  });

  group('a booking keeps its tier (BR-17)', () {
    test(
      'verifying later changes the next quote, never the stored booking',
      () async {
        final layer = InMemoryDataLayer.create(
          clock: clockAt(satMorning),
          paymentDelay: Duration.zero,
        );
        final request = BookingRequest(
          userId: SeedIds.userUnverified,
          unitId: SeedIds.hall2,
          start: cairoAt(1, 10),
          end: cairoAt(1, 11),
        );
        final made =
            (await layer.bookings.create(request) as Ok<Booking>).value;
        expect(made.tierAtBooking, PriceTier.external);

        final approved = await layer.verification.approve(
          SeedIds.verifier,
          SeedIds.verUnverified,
        );
        expect(approved.isOk, isTrue);

        final stored = (await layer.bookings.get(made.id) as Ok<Booking>).value;
        expect(stored.tierAtBooking, PriceTier.external);
        expect(stored.priceAtBooking, 0);

        final next = (await layer.bookings.quote(
          BookingRequest(
            userId: SeedIds.userUnverified,
            unitId: SeedIds.hall2,
            start: cairoAt(2, 10),
            end: cairoAt(2, 11),
          ),
        ) as Ok<BookingQuote>).value;
        expect(next.tier, PriceTier.internal);
      },
    );
  });
}
