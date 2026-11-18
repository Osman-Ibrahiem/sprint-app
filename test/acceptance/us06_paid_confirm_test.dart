import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/widgets/slot_chip/slot_state.dart' as chip;
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/booking_repository.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';
import 'package:sprint/features/booking/presentation/checkout/checkout_screen.dart';
import 'package:sprint/features/booking/presentation/confirmed/booking_confirmed_screen.dart';
import 'package:sprint/features/booking/presentation/schedule/selection_bar.dart';
import 'package:sprint/features/booking/presentation/summary/booking_summary_screen.dart';
import 'package:sprint/features/payments/domain/payment.dart';
import 'package:sprint/features/payments/presentation/fake_gateway_screen.dart';

import '../features/booking/presentation/schedule_harness.dart';
import '../helpers/pump_app.dart';

/// US-06 paid, end to end (BR-12, BR-28, BR-33): a paid pitch slot from the
/// facility's schedule to the confirmed ticket, paid through the provider
/// page; then the place is taken for everyone else.
void main() {
  final futsal = SeedIds.futsalFacility;
  final Key eighteen = ValueKey('slot-${SeedIds.futsal2}-${18 * 60}');
  final selection = ScheduleSelection(
    day: DateTime(2026, 11, 15),
    unitId: SeedIds.futsal2,
  );

  Future<void> payWithTestCard(WidgetTester tester) async {
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '4242 4242 4242 4242');
    await tester.enterText(fields.at(1), '12/30');
    await tester.enterText(fields.at(2), '123');
    await tester.enterText(fields.at(3), 'منى عبد الله');
    await tester.pump();
    await tester.ensureVisible(find.text(ar.gatewayConfirm('140 ج.م')));
    await tester.tap(find.text(ar.gatewayConfirm('140 ج.م')));
    await tester.pumpAndSettle();
    // The provider answers a moment later (its base delay), while the
    // processing screen waits.
    expect(find.byType(CheckoutScreen), findsOneWidget);
    expect(find.text(ar.processingTitle), findsWidgets);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  }

  testWidgets('summary, hold, payment page, processing, ticket; the place is '
      'taken for another account', (tester) async {
    await openSchedule(
      tester,
      futsal,
      selection: selection,
      signInAs: SeedIds.bookerInternal,
      size: const Size(400, 1600),
    );
    await tester.ensureVisible(find.byKey(eighteen));
    await tester.tap(find.byKey(eighteen));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(SelectionBar.actionKey));
    await tester.pumpAndSettle();
    expect(find.byType(BookingSummaryScreen), findsOneWidget);

    // "متابعة للدفع": the booking exists on hold.
    await tester.tap(find.byKey(BookingSummaryScreen.actionKey));
    await tester.pumpAndSettle();
    expect(find.byType(CheckoutScreen), findsOneWidget);
    final layer = containerOf(tester).read(dataLayerProvider);
    final b = layer.bookings.allBookings
        .firstWhere((x) => x.id.startsWith('bk-new-'));
    expect(b.status, BookingStatus.pendingPayment);
    expect(b.holdExpiresAt, isNotNull);

    // Another account cannot take the held place.
    expect(
      (await layer.bookings.quote(BookingRequest(
        userId: SeedIds.bookerExternal,
        unitId: SeedIds.futsal2,
        start: cairoAt(1, 18),
        end: cairoAt(1, 19),
      ))).isOk,
      isFalse,
    );

    // Pay on the provider's page.
    await tester.tap(find.byKey(CheckoutScreen.payKey));
    await tester.pumpAndSettle();
    expect(find.byType(FakeGatewayScreen), findsOneWidget);
    await payWithTestCard(tester);

    // The provider confirmed: the ticket.
    expect(find.byType(BookingConfirmedScreen), findsOneWidget);
    final done = layer.bookings.allBookings.firstWhere((x) => x.id == b.id);
    expect(done.status, BookingStatus.confirmed);
    final p = (await layer.payments.latestPayment(b.id))!;
    expect(p.status, PaymentStatus.succeeded);
    expect(p.owningUnitId, SeedIds.ouCentral); // BR-33
    expect(
      layer.notifications.all
          .where((n) => n.type == 'booking.confirmed' && n.payload['code'] == b.code),
      hasLength(1),
    );

    // For everyone else the place is gone.
    await containerOf(tester)
        .read(sessionProvider.notifier)
        .actAs(SeedIds.bookerExternal);
    await tester.pumpAndSettle();
    routerOf(tester).go(AppPaths.facilitySchedule(futsal, selection));
    await tester.pumpAndSettle();
    expect(chipAtHour(tester, 18)!.state, chip.SlotState.full);
  });
}
