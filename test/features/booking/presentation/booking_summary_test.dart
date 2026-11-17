import 'package:flutter/widgets.dart' show Key, Size, ValueKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/data/in_memory_data_layer.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/features/booking/domain/booking_repository.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';
import 'package:sprint/features/booking/presentation/checkout/checkout_coming_soon_screen.dart';
import 'package:sprint/features/booking/presentation/schedule/schedule_notice_view.dart';
import 'package:sprint/features/booking/presentation/schedule/schedule_screen.dart';
import 'package:sprint/features/booking/presentation/schedule/selection_bar.dart';
import 'package:sprint/features/booking/presentation/summary/booking_summary_screen.dart';
import 'package:sprint/features/settings/domain/setting_definition.dart';
import 'package:sprint/features/settings/domain/setting_registry.dart';

import '../../../helpers/pump_app.dart';
import 'schedule_harness.dart';

/// The summary and the checkout hand-off (spec US2 scenarios 3, 4, 8; FR-024,
/// FR-025, FR-028, FR-031).
void main() {
  ScheduleSelection pick(int day, String unit, int hour) => ScheduleSelection(
    day: DateTime(2026, 11, 14 + day),
    unitId: unit,
    startMinutes: hour * 60,
    endMinutes: (hour + 1) * 60,
  );

  Future<void> openSummary(
    WidgetTester tester,
    String facility,
    ScheduleSelection selection, {
    int? shown,
    String user = SeedIds.bookerInternal,
    Future<void> Function(InMemoryDataLayer layer)? arrange,
  }) async {
    await openSchedule(tester, facility, signInAs: user, arrange: arrange);
    routerOf(tester)
        .go(AppPaths.bookingSummary(facility, selection, shown: shown));
    await tester.pumpAndSettle();
  }

  int bookingCount(WidgetTester tester) =>
      containerOf(tester).read(dataLayerProvider).bookings.allBookings.length;

  group('what it says', () {
    testWidgets('an exclusive pitch as the internal booker', (tester) async {
      await openSummary(
        tester,
        SeedIds.futsalFacility,
        pick(1, SeedIds.futsal2, 18),
        shown: 140,
      );
      expect(find.text(ar.bookingSummaryTitle), findsWidgets);
      expect(find.text('ملعب كرة القدم الخماسي'), findsWidgets);
      expect(find.text('ملعب ب'), findsWidgets);
      expect(find.text('الأحد 15 نوفمبر'), findsOneWidget);
      expect(find.text('6:00 م – 7:00 م'), findsOneWidget);
      expect(find.text(ar.bookingLengthHours(1)), findsOneWidget);
      expect(find.text(ar.bookingCoverageWholeMax(22)), findsOneWidget);
      expect(find.text(ar.cataloguePriceInternalLabel), findsOneWidget);
      expect(
        find.text('140 ج.م ${ar.cataloguePriceBasisExclusive}'),
        findsOneWidget,
      );
      expect(find.textContaining('ساعتين قبل الميعاد'), findsOneWidget);
      expect(
        find.text(ar.bookingPolicyRefundFull),
        findsNothing,
        reason: 'the sentence is one text with the cutoff',
      );
      expect(find.textContaining(ar.bookingPolicyRefundFull), findsOneWidget);
      expect(find.byKey(BookingSummaryScreen.actionKey), findsOneWidget);
      expect(find.text(ar.bookingPayAction), findsOneWidget);
      expect(find.byKey(BookingSummaryScreen.verifyKey), findsNothing);
      expect(find.byKey(BookingSummaryScreen.priceChangedKey), findsNothing);
    });

    testWidgets(
      'a shared lane: one place, per-place price, the facility cutoff',
      (tester) async {
        await openSummary(
          tester,
          SeedIds.poolFacility,
          pick(1, SeedIds.pool5, 9),
          shown: 20,
        );
        expect(find.text(ar.bookingCoverageOnePlace), findsOneWidget);
        expect(
          find.text('20 ج.م ${ar.cataloguePriceBasisShared}'),
          findsOneWidget,
        );
        expect(find.textContaining(ar.bookingPolicyCutoff(4)), findsOneWidget);
      },
    );

    testWidgets('a partial refund is stated with its percent', (tester) async {
      await openSummary(
        tester,
        SeedIds.gymFacility,
        pick(1, SeedIds.gym1, 9),
        shown: 25,
      );
      expect(
        find.textContaining(ar.bookingPolicyRefundPartial(50)),
        findsOneWidget,
      );
    });

    testWidgets('no refund has its own wording', (tester) async {
      await openSummary(
        tester,
        SeedIds.futsalFacility,
        pick(1, SeedIds.futsal2, 18),
        shown: 140,
        arrange: (l) async {
          await l.settings.set(
            SettingKeys.refundPercent,
            0,
            const SettingScope.university(),
            actorId: SeedIds.superAdmin,
          );
        },
      );
      expect(find.textContaining(ar.bookingPolicyRefundNone), findsOneWidget);
    });
  });

  group('payment hand-off', () {
    testWidgets('"متابعة للدفع" opens the placeholder and stores nothing', (
      tester,
    ) async {
      await openSummary(
        tester,
        SeedIds.futsalFacility,
        pick(1, SeedIds.futsal2, 18),
        shown: 140,
      );
      final before = bookingCount(tester);
      await tester.tap(find.byKey(BookingSummaryScreen.actionKey));
      await tester.pumpAndSettle();
      expect(find.byType(CheckoutComingSoonScreen), findsOneWidget);
      expect(find.text(ar.bookingCheckoutSoonTitle), findsWidgets);
      expect(bookingCount(tester), before);

      await tester.tap(find.byKey(CheckoutComingSoonScreen.backKey));
      await tester.pumpAndSettle();
      expect(find.byType(BookingSummaryScreen), findsOneWidget);
    });

    testWidgets(
      'a slot taken before the tap sends the person back with the reason',
      (tester) async {
        await openSummary(
          tester,
          SeedIds.futsalFacility,
          pick(1, SeedIds.futsal2, 18),
          shown: 140,
        );
        await containerOf(tester)
            .read(bookingRepositoryProvider)
            .create(
              BookingRequest(
                userId: SeedIds.bookerExternal,
                unitId: SeedIds.futsal2,
                start: cairoAt(1, 18),
                end: cairoAt(1, 19),
              ),
            );
        await tester.tap(find.byKey(BookingSummaryScreen.actionKey));
        await tester.pumpAndSettle();
        expect(find.byType(ScheduleScreen), findsOneWidget);
        expect(find.text(ar.bookingFailSlotTaken), findsOneWidget);
        expect(
          currentUri(tester).queryParameters.containsKey('start'),
          isFalse,
        );
        expect(chipAtHour(tester, 18)!.state.name, 'full');
      },
    );
  });

  testWidgets('signing out on the summary opens sign-in and comes back to it', (
    tester,
  ) async {
    final selection = pick(1, SeedIds.futsal2, 18);
    await openSummary(tester, SeedIds.futsalFacility, selection, shown: 140);
    final summary = AppPaths.bookingSummary(
      SeedIds.futsalFacility,
      selection,
      shown: 140,
    );

    await containerOf(tester).read(sessionProvider.notifier).actAs(null);
    await tester.pumpAndSettle();
    expect(currentUri(tester).path, AppPaths.signIn);
    expect(currentUri(tester).queryParameters['from'], summary);

    await containerOf(tester)
        .read(sessionProvider.notifier)
        .actAs(SeedIds.bookerInternal);
    await tester.pumpAndSettle();
    expect(find.byType(BookingSummaryScreen), findsOneWidget);
  });

  testWidgets('a dismissed refusal does not come back after a resize', (
    tester,
  ) async {
    await openSummary(
      tester,
      SeedIds.futsalFacility,
      pick(1, SeedIds.futsal2, 18),
      shown: 140,
    );
    await containerOf(tester)
        .read(bookingRepositoryProvider)
        .create(
          BookingRequest(
            userId: SeedIds.bookerExternal,
            unitId: SeedIds.futsal2,
            start: cairoAt(1, 18),
            end: cairoAt(1, 19),
          ),
        );
    await tester.tap(find.byKey(BookingSummaryScreen.actionKey));
    await tester.pumpAndSettle();
    expect(find.text(ar.bookingFailSlotTaken), findsOneWidget);

    await tester.tap(find.byKey(ScheduleNoticeView.dismissKey));
    await tester.pumpAndSettle();
    expect(find.text(ar.bookingFailSlotTaken), findsNothing);

    // The screen is rebuilt for another width class: the notice stays gone.
    setWindow(tester, size: const Size(700, 1400));
    await tester.pumpAndSettle();
    setWindow(tester, size: const Size(400, 1400));
    await tester.pumpAndSettle();
    expect(find.text(ar.bookingFailSlotTaken), findsNothing);
  });

  group('back (FR-031)', () {
    testWidgets(
      'from the summary the schedule has the same selection; from checkout the summary',
      (tester) async {
        await openSchedule(
          tester,
          SeedIds.futsalFacility,
          selection: ScheduleSelection(
            day: DateTime(2026, 11, 15),
            unitId: SeedIds.futsal2,
          ),
          signInAs: SeedIds.bookerInternal,
        );
        final Key slot = ValueKey('slot-${SeedIds.futsal2}-${18 * 60}');
        await tester.ensureVisible(find.byKey(slot));
        await tester.tap(find.byKey(slot));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(SelectionBar.actionKey));
        await tester.pumpAndSettle();
        expect(find.byType(BookingSummaryScreen), findsOneWidget);

        await tester.tap(find.byKey(BookingSummaryScreen.actionKey));
        await tester.pumpAndSettle();
        expect(find.byType(CheckoutComingSoonScreen), findsOneWidget);

        routerOf(tester).pop();
        await tester.pumpAndSettle();
        expect(find.byType(BookingSummaryScreen), findsOneWidget);

        routerOf(tester).pop();
        await tester.pumpAndSettle();
        expect(find.byType(ScheduleScreen), findsOneWidget);
        expect(chipAtHour(tester, 18)!.state.name, 'selected');
        expect(find.byKey(SelectionBar.barKey), findsOneWidget);
        expect(
          currentUri(tester).queryParameters,
          containsPair('start', '1800'),
        );
      },
    );
  });
}
