import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/widgets/booking_ticket/booking_ticket.dart';
import 'package:sprint/features/booking/presentation/bookings/my_bookings_screen.dart';
import 'package:sprint/features/booking/presentation/details/booking_details_screen.dart';

import '../../../../helpers/pump_app.dart';

/// The wide detail pane keeps its heading fixed above a separate scroll
/// area: scrolled content never paints or hit-tests over the heading.
void main() {
  testWidgets('scrolled details stay below the heading', (t) async {
    await pumpSprintApp(t, size: const Size(1024, 500));
    await containerOf(t)
        .read(sessionProvider.notifier)
        .actAs(SeedIds.bookerInternal);
    routerOf(t).go(AppPaths.bookingDetails('bk-09'));
    await t.pumpAndSettle();
    final heading = find.descendant(
      of: find.byKey(MyBookingsScreen.detailPaneKey),
      matching: find.text(ar.bookingDetailsTitle),
    );
    final headingRect = t.getRect(heading);
    // The viewport starts below the heading.
    final view = find.byType(BookingDetailsView);
    expect(t.getTopLeft(view).dy, greaterThanOrEqualTo(headingRect.bottom));

    await t.drag(
      find.descendant(of: view, matching: find.byType(SingleChildScrollView)),
      const Offset(0, -300),
    );
    await t.pumpAndSettle();

    // Whatever scrolled up, nothing of the content is hit at the heading.
    final hit = HitTestResult();
    t.binding.hitTestInView(hit, headingRect.center, t.view.viewId);
    final types = hit.path.map((e) => e.target.runtimeType.toString());
    expect(
      hit.path.any((e) => e.target is RenderObject &&
          find.byType(BookingTicket).evaluate().any(
            (el) => el.renderObject == e.target,
          )),
      isFalse,
      reason: types.join(','),
    );
  });
}
