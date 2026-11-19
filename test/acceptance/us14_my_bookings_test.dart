import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/widgets/booking_row/booking_row.dart';
import 'package:sprint/core/widgets/segmented_control/segmented_control.dart';
import 'package:sprint/features/booking/presentation/bookings/my_bookings_screen.dart';
import 'package:sprint/features/booking/presentation/cancel/cancel_dialog.dart';
import 'package:sprint/features/booking/presentation/details/booking_details_screen.dart';
import 'package:sprint/features/booking/presentation/details/details_actions.dart';
import 'package:sprint/core/widgets/wide_dialog/wide_dialog.dart';

import '../helpers/pump_app.dart';

/// US-14 and US-13 (T044 to T056, condensed): list, details, cancel.
void main() {
  Future<void> open(WidgetTester t, {Size size = const Size(400, 900)}) async {
    await pumpSprintApp(t, size: size);
    await containerOf(t)
        .read(sessionProvider.notifier)
        .actAs(SeedIds.bookerInternal);
    routerOf(t).go(AppPaths.bookings);
    await t.pumpAndSettle();
  }

  testWidgets('upcoming rows carry a status word; past is switchable',
      (t) async {
    await open(t);
    expect(find.byType(BookingRow), findsWidgets);
    expect(find.text(ar.statusConfirmed), findsWidgets);
    await t.tap(find.byKey(SegmentedControl.segmentKey(1)));
    await t.pumpAndSettle();
    expect(find.text(ar.statusAttended), findsWidgets);
  });

  testWidgets('a guest still gets the account gate', (t) async {
    await pumpSprintApp(t);
    routerOf(t).go(AppPaths.bookings);
    await t.pumpAndSettle();
    expect(find.byType(BookingRow), findsNothing);
  });

  testWidgets('a row opens the details; wide shows it beside the list',
      (t) async {
    await open(t);
    await t.tap(find.byType(BookingRow).first);
    await t.pumpAndSettle();
    expect(find.byType(BookingDetailsScreen), findsOneWidget);

    await open(t, size: const Size(900, 900));
    expect(find.byKey(MyBookingsScreen.detailPaneKey), findsOneWidget);
    expect(find.byType(BookingDetailsView), findsOneWidget);
  });

  testWidgets("another user's booking shows nothing of it", (t) async {
    await open(t);
    routerOf(t).go(AppPaths.bookingDetails('bk-10'));
    await t.pumpAndSettle();
    expect(find.text('SP-1010'), findsNothing);
  });

  testWidgets('cancel: dialog with computed text, confirm leads to the result',
      (t) async {
    await open(t);
    routerOf(t).go(AppPaths.bookingDetails('bk-09'));
    await t.pumpAndSettle();
    await t.ensureVisible(find.byKey(DetailsActions.cancelKey));
    await t.pumpAndSettle();
    await t.tap(find.byKey(DetailsActions.cancelKey));
    await t.pumpAndSettle();
    expect(find.text(ar.cancelDialogTitle), findsOneWidget);
    await t.tap(find.text(ar.cancelActionConfirm).last);
    await t.pumpAndSettle();
    expect(currentPath(t), AppPaths.bookingCancelled('bk-09'));
    expect(find.text(ar.cancelResultTitle), findsOneWidget);
  });

  testWidgets('inside the cutoff there is no cancel action', (t) async {
    await open(t);
    routerOf(t).go(AppPaths.bookingDetails('bk-y01'));
    await t.pumpAndSettle();
    expect(find.byKey(DetailsActions.cancelKey), findsNothing);
  });

  testWidgets('wide cancel uses the wide dialog', (t) async {
    await open(t, size: const Size(900, 900));
    routerOf(t).go(AppPaths.bookingDetails('bk-09'));
    await t.pumpAndSettle();
    await t.ensureVisible(find.byKey(DetailsActions.cancelKey));
    await t.pumpAndSettle();
    await t.tap(find.byKey(DetailsActions.cancelKey));
    await t.pumpAndSettle();
    expect(find.byType(WideDialog), findsOneWidget);
    expect(runCancelFlow, isNotNull);
  });
}
