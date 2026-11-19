import 'package:flutter/material.dart' hide Banner;
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/core/widgets/banner/banner.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/presentation/details/booking_details_screen.dart';
import 'package:sprint/features/booking/domain/booking_repository.dart';
import 'package:sprint/features/booking/presentation/details/details_actions.dart';
import 'package:sprint/features/booking/presentation/cancel/cancel_result_screen.dart';

import '../helpers/pump_app.dart';

/// US-13 pending cancel (T057, T059, T055): BR-48 and the facility view.
void main() {
  BookingRequest request(String user) {
    CairoTime.ensureInitialized();
    final today = CairoTime.toCairo(DateTime.now().toUtc());
    return BookingRequest(
      userId: user,
      unitId: SeedIds.futsal2,
      start: CairoTime.atWallClock(today.year, today.month, today.day + 2, 18),
      end: CairoTime.atWallClock(today.year, today.month, today.day + 2, 19),
    );
  }

  testWidgets('a holding booking is cancelled with a short dialog and the '
      'place is free at once', (t) async {
    await pumpSprintApp(t, size: const Size(400, 1400));
    final c = containerOf(t);
    await c.read(sessionProvider.notifier).actAs(SeedIds.bookerInternal);
    final repo = c.read(dataLayerProvider).bookings;
    final created = await t.runAsync(() => repo.create(request(SeedIds.bookerInternal)));
    final b = (created! as Ok<Booking>).value;
    expect(b.status, BookingStatus.pendingPayment);

    routerOf(t).go(AppPaths.bookingDetails(b.id));
    await t.pumpAndSettle();
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await t.pumpAndSettle();
    await t.ensureVisible(find.byKey(DetailsActions.cancelKey));
    await t.pumpAndSettle();
    await t.tap(find.byKey(DetailsActions.cancelKey));
    await t.pumpAndSettle();
    expect(find.text(ar.cancelMessagePending), findsOneWidget);
    await t.tap(find.text(ar.cancelActionConfirm).last);
    await t.pumpAndSettle();

    final after = (await t.runAsync(() => repo.get(b.id)))! as Ok<Booking>;
    expect(after.value.status, BookingStatus.cancelled);
    expect(find.byType(CancelResultScreen), findsOneWidget);
    final other = await t.runAsync(() => repo.create(request(SeedIds.bookerExternal)));
    expect(other, isA<Ok<Booking>>());
  });

  testWidgets('a facility cancel shows the cause, the reason and the refund',
      (t) async {
    await pumpSprintApp(t, size: const Size(400, 1400));
    await containerOf(t)
        .read(sessionProvider.notifier)
        .actAs(SeedIds.bookerInternal);
    routerOf(t).go(AppPaths.bookingDetails('bk-15')); // cancelled by admin
    await t.pumpAndSettle();
    expect(find.textContaining(ar.bookingDetailsCancelledByFacility), findsOneWidget);
    expect(find.byKey(DetailsActions.cancelKey), findsNothing);
  });

  testWidgets('M4: a refunded cancel has a "المسترد" row, the way line and '
      'banners without a final dot', (t) async {
    await pumpSprintApp(t, size: const Size(400, 1600));
    await containerOf(t)
        .read(sessionProvider.notifier)
        .actAs(SeedIds.bookerInternal);
    routerOf(t).go(AppPaths.bookingDetails('bk-y02'));
    await t.pumpAndSettle();
    expect(find.byKey(BookingDetailsView.refundedKey), findsOneWidget);
    expect(find.text(ar.bookingDetailsRefundWay), findsOneWidget);
    final banner = t.widget<Banner>(find.byType(Banner));
    expect(banner.text.endsWith('.'), isFalse);
    expect(banner.tone, BannerTone.success);
  });

  testWidgets('M5: a facility cancel is a success banner with the reason and '
      'the full refund, no "informed" phrase', (t) async {
    await pumpSprintApp(t, size: const Size(400, 1600));
    await containerOf(t)
        .read(sessionProvider.notifier)
        .actAs(SeedIds.bookerInternal);
    routerOf(t).go(AppPaths.bookingDetails('bk-15'));
    await t.pumpAndSettle();
    final banner = t.widget<Banner>(find.byType(Banner));
    expect(banner.tone, BannerTone.success);
    expect(banner.text, contains(ar.bookingDetailsCancelledByFacility));
    expect(banner.text, contains('إغلاق طارئ'));
    expect(banner.text.contains('واتبلّغت'), isFalse);
    expect(banner.text.endsWith('.'), isFalse);
  });
}
