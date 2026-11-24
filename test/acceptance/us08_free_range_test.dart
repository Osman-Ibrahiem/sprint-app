import 'package:clock/clock.dart';
import 'package:flutter/widgets.dart' show Key, ValueKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/data/in_memory_data_layer.dart';
import 'package:sprint/core/l10n/ltr_isolate.dart';
import 'package:sprint/app/shell/placeholders/no_access_screen.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/widgets/booking_ticket/booking_ticket.dart';
import 'package:sprint/core/widgets/slot_chip/slot_state.dart' as chip;
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/booking_repository.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';
import 'package:sprint/features/booking/presentation/confirmed/booking_confirmed_screen.dart';
import 'package:sprint/features/booking/presentation/schedule/schedule_screen.dart';
import 'package:sprint/features/booking/presentation/schedule/selection_bar.dart';
import 'package:sprint/features/booking/presentation/summary/booking_summary_screen.dart';
import 'package:sprint/features/catalogue/presentation/home/home_screen.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/settings/domain/setting_definition.dart';
import 'package:sprint/features/settings/domain/setting_registry.dart';

import '../features/booking/presentation/schedule_harness.dart';
import '../helpers/pump_app.dart';

/// US-08: a range of hours in a free facility, confirmed at once (spec US4;
/// BR-08, BR-19; FR-015, FR-016, FR-029, FR-030, FR-034, FR-038).
void main() {
  final hall = SeedIds.hallFacility;

  ScheduleSelection onDay(int day, [String unit = SeedIds.hall2]) =>
      ScheduleSelection(day: DateTime(2026, 11, 14 + day), unitId: unit);
  Key slot(String unit, int hour) => ValueKey('slot-$unit-${hour * 60}');

  Future<void> tapHour(
    WidgetTester tester,
    int hour, [
    String unit = SeedIds.hall2,
  ]) async {
    await tester.ensureVisible(find.byKey(slot(unit, hour)));
    await tester.tap(find.byKey(slot(unit, hour)));
    await tester.pumpAndSettle();
  }

  Future<void> openHall(
    WidgetTester tester, {
    int day = 1,
    String unit = SeedIds.hall2,
    String user = SeedIds.bookerExternal,
    Future<void> Function(InMemoryDataLayer layer)? arrange,
  }) => openSchedule(
    tester,
    hall,
    selection: onDay(day, unit),
    signInAs: user,
    arrange: arrange,
  );

  Future<void> pickFourToSeven(WidgetTester tester) async {
    await tapHour(tester, 16);
    await tapHour(tester, 18);
  }

  Finder inBar(Finder f) =>
      find.descendant(of: find.byKey(SelectionBar.barKey), matching: f);

  int bookingCount(WidgetTester tester) =>
      containerOf(tester).read(dataLayerProvider).bookings.allBookings.length;

  group('choosing the range', () {
    testWidgets(
      'the schedule explains the rule with the maximum from the setting',
      (tester) async {
        await openHall(tester);
        expect(find.text(ar.bookingRangeHint(3)), findsOneWidget);
      },
    );

    testWidgets('4:00 to 6:00 is one range of three hours, in words', (
      tester,
    ) async {
      await openHall(tester);
      await pickFourToSeven(tester);
      expect(chipAtHour(tester, 16)!.state, chip.SlotState.selected);
      expect(chipAtHour(tester, 18)!.state, chip.SlotState.selected);
      expect(chipAtHour(tester, 17)!.state, chip.SlotState.inRange);
      expect(inBar(find.textContaining('4:00\u00A0م\u00A0–\u00A07:00\u00A0م')), findsOneWidget);
      expect(
        inBar(find.textContaining(ar.bookingLengthHours(3))),
        findsOneWidget,
      );
      expect(find.text(ar.bookingFree), findsWidgets);
      expect(currentUri(tester).queryParameters, containsPair('start', '1600'));
      expect(currentUri(tester).queryParameters, containsPair('end', '1900'));
    });

    testWidgets('one slot alone is a range of one hour', (tester) async {
      await openHall(tester);
      await tapHour(tester, 10);
      expect(
        inBar(find.textContaining(ar.bookingLengthHours(1))),
        findsOneWidget,
      );
    });

    testWidgets('a range longer than the maximum is refused, stating it', (
      tester,
    ) async {
      await openHall(tester);
      await tapHour(tester, 9);
      await tapHour(tester, 12);
      expect(find.text(ar.bookingFailRangeTooLong(3)), findsOneWidget);
      expect(chipAtHour(tester, 9)!.state, chip.SlotState.selected);
      expect(chipAtHour(tester, 12)!.state, isNot(chip.SlotState.selected));
    });

    testWidgets('the maximum is the setting: 2 hours changes the limit', (
      tester,
    ) async {
      await openHall(
        tester,
        arrange: (l) async => l.settings.set(
          SettingKeys.maxRangeHours,
          2,
          const SettingScope.university(),
          actorId: SeedIds.superAdmin,
        ),
      );
      expect(find.text(ar.bookingRangeHint(2)), findsOneWidget);
      await tapHour(tester, 9);
      await tapHour(tester, 11);
      expect(find.text(ar.bookingFailRangeTooLong(2)), findsOneWidget);
      await tapHour(tester, 10);
      expect(
        inBar(find.textContaining(ar.bookingLengthHours(2))),
        findsOneWidget,
      );
    });

    testWidgets('a taken hour inside the range is named', (tester) async {
      // Hall 1, day +4: 10:00 and 11:00 are booked.
      await openHall(
        tester,
        day: 4,
        unit: SeedIds.hall1,
        arrange: (l) async => l.settings.set(
          SettingKeys.maxRangeHours,
          5,
          const SettingScope.university(),
          actorId: SeedIds.superAdmin,
        ),
      );
      await tapHour(tester, 9, SeedIds.hall1);
      await tapHour(tester, 12, SeedIds.hall1);
      expect(find.text(ar.bookingFailSlotTakenAt('10:00\u00A0ص')), findsOneWidget);
      expect(chipAtHour(tester, 12)!.state, isNot(chip.SlotState.selected));
    });
  });

  group('summary and confirming', () {
    Future<void> toSummary(WidgetTester tester) async {
      await pickFourToSeven(tester);
      await tester.tap(find.byKey(SelectionBar.actionKey));
      await tester.pumpAndSettle();
    }

    testWidgets(
      'the summary says free, with no tier price and no payment step',
      (tester) async {
        await openHall(tester);
        await toSummary(tester);
        expect(find.byType(BookingSummaryScreen), findsOneWidget);
        expect(find.text(ar.bookingFree), findsOneWidget);
        expect(find.text(ar.bookingRowTier), findsNothing);
        expect(find.textContaining('ج.م'), findsNothing);
        expect(find.text(ar.bookingFreeNoPayment), findsOneWidget);
        expect(find.text(ar.bookingConfirmAction), findsOneWidget);
        expect(find.text(ar.bookingPayAction), findsNothing);
        expect(find.byKey(BookingSummaryScreen.actionKey), findsOneWidget);
      },
    );

    testWidgets(
      'confirming creates exactly one CONFIRMED booking, even tapped twice',
      (tester) async {
        await openHall(tester);
        await toSummary(tester);
        final before = bookingCount(tester);

        await tester.tap(find.byKey(BookingSummaryScreen.actionKey));
        await tester.tap(
          find.byKey(BookingSummaryScreen.actionKey),
          warnIfMissed: false,
        );
        await tester.pumpAndSettle();

        expect(bookingCount(tester), before + 1);
        final b = containerOf(tester)
            .read(dataLayerProvider)
            .bookings
            .allBookings
            .firstWhere((x) => x.id.startsWith('bk-new-'));
        expect(b.status, BookingStatus.confirmed);
        expect(b.priceAtBooking, 0);
        expect(b.tierAtBooking, PriceTier.external);
        expect((b.unitId, b.seats), (SeedIds.hall2, 1));
        expect(b.start, cairoAt(1, 16));
        expect(b.end, cairoAt(1, 19));
      },
    );

    testWidgets('the success screen is the ticket: QR, code, "مجاني", no '
        'receipt row (US-12, BR-19)', (tester) async {
      await openHall(tester);
      await toSummary(tester);
      await tester.tap(find.byKey(BookingSummaryScreen.actionKey));
      await tester.pumpAndSettle();

      expect(find.byType(BookingConfirmedScreen), findsOneWidget);
      expect(find.text(ar.confirmedTitle), findsWidgets);
      final code = containerOf(tester)
          .read(dataLayerProvider)
          .bookings
          .allBookings
          .firstWhere((x) => x.id.startsWith('bk-new-'))
          .code;
      expect(find.text(code), findsOneWidget);
      expect(
        find.ancestor(
          of: find.byKey(BookingTicket.codeKey),
          matching: find.byType(LtrIsolate),
        ),
        findsOneWidget,
      );
      expect(find.text('الصالة المغطاة متعددة الأغراض'), findsOneWidget);
      expect(find.text('قاعة 2'), findsOneWidget);
      expect(find.byType(BookingTicket), findsOneWidget);
      expect(find.byKey(BookingTicket.qrKey), findsOneWidget);
      expect(find.text(ar.bookingRowPrice), findsWidgets);
      expect(find.text(ar.bookingFree), findsWidgets);
      expect(find.byKey(BookingConfirmedScreen.receiptKey), findsNothing);
      expect(find.byKey(BookingConfirmedScreen.homeKey), findsOneWidget);
    });

    testWidgets(
      'the success screen cannot be left back to the summary',
      (tester) async {
        await openHall(tester);
        await toSummary(tester);
        await tester.tap(find.byKey(BookingSummaryScreen.actionKey));
        await tester.pumpAndSettle();

        // Reached with `go`: the summary is gone, so it cannot confirm the
        // booking a second time.
        expect(find.byType(BookingSummaryScreen), findsNothing);
        if (routerOf(tester).canPop()) {
          routerOf(tester).pop();
          await tester.pumpAndSettle();
        }
        expect(find.byType(BookingSummaryScreen), findsNothing);
        // The hours are taken for everyone.
        routerOf(tester).go(AppPaths.facilitySchedule(hall, onDay(1)));
        await tester.pumpAndSettle();
        for (final h in [16, 17, 18]) {
          expect(
            chipAtHour(tester, h)!.state,
            chip.SlotState.full,
            reason: '$h:00',
          );
        }
      },
    );

    testWidgets('"الرجوع للرئيسية" shows the booking under upcoming', (
      tester,
    ) async {
      await openHall(tester);
      await toSummary(tester);
      await tester.tap(find.byKey(BookingSummaryScreen.actionKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(BookingConfirmedScreen.homeKey));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(
        find.textContaining('الصالة المغطاة متعددة الأغراض'),
        findsWidgets,
      );
      expect(find.text(ar.catalogueUpcomingTitle), findsWidgets);
    });

    testWidgets(
      'hours taken by someone else before confirming: said, nothing created',
      (tester) async {
        await openHall(tester);
        await toSummary(tester);
        await containerOf(tester)
            .read(bookingRepositoryProvider)
            .create(
              BookingRequest(
                userId: SeedIds.bookerInternal,
                unitId: SeedIds.hall2,
                start: cairoAt(1, 17),
                end: cairoAt(1, 18),
              ),
            );
        final before = bookingCount(tester);
        await tester.tap(find.byKey(BookingSummaryScreen.actionKey));
        await tester.pumpAndSettle();
        expect(bookingCount(tester), before);
        expect(find.byType(ScheduleScreen), findsOneWidget);
        expect(
          find.textContaining(ar.bookingFailSlotTakenAt('5:00\u00A0م')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'two people confirming overlapping ranges together: one booking',
      (tester) async {
        await openHall(tester);
        final repo = containerOf(tester).read(bookingRepositoryProvider);
        BookingRequest range(String user, int from, int to) => BookingRequest(
          userId: user,
          unitId: SeedIds.hall2,
          start: cairoAt(1, from),
          end: cairoAt(1, to),
        );
        final results = await Future.wait([
          repo.create(range(SeedIds.bookerExternal, 16, 19)),
          repo.create(range(SeedIds.bookerInternal, 17, 20)),
        ]);
        expect(results.whereType<Ok<Booking>>(), hasLength(1));
        expect(results.whereType<Err<Booking>>(), hasLength(1));
      },
    );

    testWidgets('someone else\'s booking is not shown on the success route', (
      tester,
    ) async {
      await openHall(tester);
      final other = await containerOf(tester)
          .read(bookingRepositoryProvider)
          .create(
            BookingRequest(
              userId: SeedIds.bookerInternal,
              unitId: SeedIds.hall2,
              start: cairoAt(2, 10),
              end: cairoAt(2, 11),
            ),
          );
      final id = (other as Ok<Booking>).value.id;
      await containerOf(tester)
          .read(sessionProvider.notifier)
          .actAs(SeedIds.bookerExternal);
      await tester.pumpAndSettle();
      routerOf(tester).go(AppPaths.bookingConfirmed(id));
      await tester.pumpAndSettle();
      expect(find.byType(NoAccessScreen), findsOneWidget);
      expect(find.byType(BookingTicket), findsNothing);
    });
  });

  group('kept with the demo data (FR-038)', () {
    test(
      'a free booking survives the snapshot and the reset removes it',
      () async {
        final now = satMorning;
        final layer = InMemoryDataLayer.create(
          clock: Clock(() => now),
          paymentDelay: Duration.zero,
        );
        final created = await layer.bookings.create(
          BookingRequest(
            userId: SeedIds.bookerExternal,
            unitId: SeedIds.hall2,
            start: cairoAt(1, 16),
            end: cairoAt(1, 19),
          ),
        );
        final id = (created as Ok<Booking>).value.id;

        final restored = InMemoryDataLayer.fromSnapshot(
          clock: Clock(() => now),
          snapshot: layer.toSnapshot(),
          paymentDelay: Duration.zero,
        );
        final again = await restored.bookings.get(id);
        expect(again, isA<Ok<Booking>>());
        expect((again as Ok<Booking>).value.status, BookingStatus.confirmed);

        await restored.reset();
        final fresh = InMemoryDataLayer.fromSnapshot(
          clock: Clock(() => now),
          paymentDelay: Duration.zero,
        );
        expect(await fresh.bookings.get(id), isA<Err<Booking>>());
      },
    );
  });
}
