import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/data/in_memory_data_layer.dart';
import 'package:sprint/core/l10n/locale_notifier.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/theme/theme_mode_notifier.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/core/tokens/sprint_colors.g.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/presentation/checkout/awaiting_view.dart';
import 'package:sprint/features/booking/presentation/checkout/checkout_layout.dart';
import 'package:sprint/features/booking/presentation/checkout/checkout_screen.dart';
import 'package:sprint/features/booking/presentation/checkout/expired_view.dart';
import 'package:sprint/features/booking/presentation/checkout/processing_view.dart';
import 'package:sprint/features/booking/presentation/confirmed/booking_confirmed_screen.dart';
import 'package:sprint/features/payments/data/fake_gateway_controller.dart';
import 'package:sprint/features/payments/presentation/fake_gateway_screen.dart';
import 'package:sprint/features/payments/presentation/receipt/receipt_screen.dart';

import '../../../../helpers/pump_app.dart';
import 'checkout_harness.dart';

/// Checkout, provider page, confirmation and receipt at four widths, in both
/// languages and themes, at 100% and 200% text (US-9, NFR): the column
/// structure of design-pack/adaptive.md and no overflow anywhere.
void main() {
  CairoTime.ensureInitialized();
  const widths = [390.0, 700.0, 1000.0, 1440.0];
  const looks = [
    (Locale('ar'), false, 'ar light'),
    (Locale('en'), true, 'en dark'),
  ];
  const scales = [1.0, 2.0];

  void noOverflow(WidgetTester tester, String where) {
    final e = tester.takeException();
    expect(e, isNull, reason: '$where: $e');
  }

  // The provider page and the confirmation are the same under every look, so
  // one pass per look and width covers them.
  for (final w in widths) {
    for (final (locale, dark, label) in looks) {
      for (final scale in scales) {
        final name = '$w $label x$scale';

        testWidgets('checkout states at $name', (tester) async {
          final size = Size(w, 3200);
          final env = await CheckoutEnv.open(
            tester,
            size: size,
            textScale: scale,
            locale: locale,
            dark: dark,
          );
          // Holding.
          noOverflow(tester, 'holding $name');
          expect(find.byKey(CheckoutLayout.barKey),
              w < 600 ? findsOneWidget : findsNothing);
          expect(find.byKey(CheckoutLayout.paymentColumnKey),
              w < 600 ? findsNothing : findsOneWidget);
          if (w >= 600) {
            final pay = tester.getRect(find.byKey(CheckoutLayout.paymentColumnKey));
            final sum = tester.getRect(find.byKey(CheckoutLayout.summaryColumnKey));
            expect(pay.overlaps(sum), isFalse);
            expect(pay.width, lessThanOrEqualTo(SprintExtras.checkoutPaymentColumn));
          }

          // The provider page.
          await tester.ensureVisible(find.byKey(CheckoutScreen.payKey));
          await tester.tap(find.byKey(CheckoutScreen.payKey));
          await tester.pumpAndSettle();
          expect(find.byType(FakeGatewayScreen), findsOneWidget);
          noOverflow(tester, 'gateway $name');
          if (w >= 600) {
            final column = tester.getSize(find.byType(ListView).first);
            expect(column.width, lessThanOrEqualTo(SprintExtras.centredColumn));
          }

          // Cancelled.
          await tester.scrollUntilVisible(
            find.byKey(cancelKey),
            300,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.ensureVisible(find.byKey(cancelKey));
          await tester.tap(find.byKey(cancelKey));
          await tester.pumpAndSettle();
          noOverflow(tester, 'cancelled $name');

          // Failed.
          env.gateway.outcome = const FakeOutcome.fail();
          await env.payOnPage();
          noOverflow(tester, 'failed $name');

          // Expired.
          await env.advance(const Duration(minutes: 11));
          await tester.pumpAndSettle();
          expect(find.byKey(ExpiredView.titleKey), findsOneWidget);
          noOverflow(tester, 'expired $name');
        });

        testWidgets('processing and awaiting at $name', (tester) async {
          final env = await CheckoutEnv.open(
            tester,
            size: Size(w, 3200),
            textScale: scale,
            locale: locale,
            dark: dark,
            outcome: const FakeOutcome.delay(Duration(seconds: 90)),
          );
          await env.payOnPage();
          expect(find.byType(ProcessingView), findsOneWidget);
          noOverflow(tester, 'processing $name');
          await env.advance(const Duration(seconds: 25));
          expect(find.byType(AwaitingView), findsOneWidget);
          noOverflow(tester, 'awaiting $name');
          // Let the provider answer so no timer is left.
          await env.advance(const Duration(seconds: 70));
          await tester.pumpAndSettle();
        });

        for (final free in [false, true]) {
          testWidgets('${free ? 'free' : 'paid'} ticket and receipt at $name',
              (tester) async {
            final seedNow = CairoTime.atWallClock(2026, 11, 14, 8);
            final layer = InMemoryDataLayer.create(
              clock: Clock(() => seedNow),
              paymentDelay: Duration.zero,
            );
            final b = layer.bookings.allBookings.firstWhere((x) =>
                x.userId == SeedIds.bookerInternal &&
                x.unitId == (free ? SeedIds.hall1 : SeedIds.pool3) &&
                x.status == BookingStatus.confirmed);
            await pumpSprintApp(
              tester,
              size: Size(w, 3200),
              textScale: scale,
              overrides: [
                dataLayerProvider.overrideWithValue(layer),
                appClockProvider.overrideWithValue(Clock(() => seedNow)),
              ],
            );
            final c = containerOf(tester);
            await c.read(sessionProvider.notifier).actAs(SeedIds.bookerInternal);
            await c.read(localeProvider.notifier).set(locale);
            if (dark) await c.read(themeModeProvider.notifier).set(ThemeMode.dark);
            await tester.pumpAndSettle();

            routerOf(tester).go(AppPaths.bookingConfirmed(b.id));
            await tester.pumpAndSettle();
            expect(find.byType(BookingConfirmedScreen), findsOneWidget);
            noOverflow(tester, 'ticket $name');
            final twoColumns = find.byWidgetPredicate((x) =>
                x is SizedBox && x.width == SprintExtras.confirmationColumn);
            // Two columns when the pane has room for both: the window minus the
            // sidebar (280) from the expanded class, the rail (88) before.
            final pane = w - (w >= 840 ? 280 : w >= 600 ? 88 : 0);
            expect(
              twoColumns,
              pane >= SprintExtras.confirmationTwoColumnsMinWidth
                  ? findsNWidgets(2)
                  : findsNothing,
            );

            if (!free) {
              routerOf(tester).go(AppPaths.bookingReceipt(b.id));
              await tester.pumpAndSettle();
              expect(find.byType(ReceiptScreen), findsOneWidget);
              noOverflow(tester, 'receipt $name');
            }
          });
        }
      }
    }
  }

  test('the QR is dark on white in both themes', () {
    for (final c in [SprintColors.light, SprintColors.dark]) {
      expect(c.qrGround, const Color(0xFFFFFFFF));
      expect(c.qrInk.computeLuminance(), lessThan(0.1));
    }
  });
}
