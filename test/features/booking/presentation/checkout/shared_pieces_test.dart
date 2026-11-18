import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/theme/sprint_theme.dart';
import 'package:sprint/core/tokens/sprint_colors.g.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/features/booking/presentation/checkout/checkout_layout.dart';
import 'package:sprint/features/booking/presentation/checkout/checkout_policy_card.dart';
import 'package:sprint/features/booking/presentation/checkout/countdown_text.dart';
import 'package:sprint/features/booking/presentation/checkout/hold_banner.dart';
import 'package:sprint/features/booking/presentation/checkout/moment_placeholder.dart';
import 'package:sprint/features/booking/presentation/checkout/payment_method_card.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

import '../../../../helpers/pump_app.dart' show ar;
import '../../../../helpers/widget_harness.dart';

void main() {
  // Walk 2026-11-18 D5: a booking made after its cutoff must not name a time
  // that has already passed.
  testWidgets('the policy names the last moment to cancel, or says '
      'cancellation is not available once it has passed', (tester) async {
    CairoTime.ensureInitialized();
    final start = CairoTime.atWallClock(2026, 11, 18, 11);
    Widget card(DateTime now) => CheckoutPolicyCard(
          start: start,
          cutoffHours: 4,
          refundPercent: 100,
          now: now,
        );
    await pumpWidgetUnder(
        tester, card(CairoTime.atWallClock(2026, 11, 18, 6, 59)));
    expect(find.textContaining('الإلغاء متاح لحد'), findsOneWidget);
    expect(find.text(ar.ticketCancelUnavailable), findsNothing);

    await pumpWidgetUnder(
        tester, card(CairoTime.atWallClock(2026, 11, 18, 10, 38)));
    expect(find.text(ar.ticketCancelUnavailable), findsOneWidget);
    expect(find.textContaining('الإلغاء متاح لحد'), findsNothing);
  });

  testWidgets('the banner is warning-soft with the time, then danger-soft in '
      'the last minute with seconds', (tester) async {
    await pumpWidgetUnder(
        tester, const HoldBanner(remaining: Duration(minutes: 9, seconds: 42)));
    expect(find.text(ar.checkoutHoldTitle), findsOneWidget);
    expect(find.text(ar.checkoutHoldRemaining('9:42')), findsOneWidget);
    Color? bannerColor() => (tester
            .widget<Container>(find
                .descendant(
                    of: find.byType(HoldBanner), matching: find.byType(Container))
                .first)
            .decoration! as BoxDecoration)
        .color;
    expect(bannerColor(), SprintColors.light.warningSoft);

    await pumpWidgetUnder(
        tester, const HoldBanner(remaining: Duration(seconds: 45)));
    expect(find.text(ar.checkoutLastMinuteTitle), findsOneWidget);
    expect(find.text(ar.checkoutLastMinuteBody(45)), findsOneWidget);
    expect(bannerColor(), SprintColors.light.dangerSoft);
  });

  testWidgets('the gateway kind says the place is held', (tester) async {
    await pumpWidgetUnder(
        tester,
        const HoldBanner(
            remaining: Duration(minutes: 8), kind: HoldBannerKind.gateway));
    expect(find.text(ar.gatewayHoldTitle), findsOneWidget);
    expect(find.text(ar.gatewayHoldBody('8:00')), findsOneWidget);
  });

  testWidgets('the live region speaks every 30 seconds and once at the last '
      'minute, not every second', (tester) async {
    final spoken = <String>[];
    Future<void> show(Duration d) async {
      await pumpWidgetUnder(tester, HoldBanner(remaining: d));
      final node = tester.getSemantics(find.byKey(HoldBanner.liveRegionKey));
      spoken.add(node.label);
    }

    await show(const Duration(minutes: 5, seconds: 1));
    final first = spoken.last;
    expect(first, contains(ar.checkoutHoldTitle));

    // The same widget, one second later: nothing new is spoken.
    Future<void> tick(Duration d) async {
      await tester.pumpWidget(MaterialApp(
        theme: SprintTheme.light,
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(body: HoldBanner(remaining: d)),
      ));
      spoken.add(tester.getSemantics(find.byKey(HoldBanner.liveRegionKey)).label);
    }

    await tick(const Duration(minutes: 5, seconds: 1));
    final base = spoken.last;
    await tick(const Duration(minutes: 5));
    expect(spoken.last, base, reason: 'same 30-second window');
    await tick(const Duration(minutes: 4, seconds: 58));
    expect(spoken.last, isNot(base), reason: 'a new 30-second window');
    final window = spoken.last;
    await tick(const Duration(minutes: 4, seconds: 57));
    expect(spoken.last, window);

    await tick(const Duration(seconds: 59));
    expect(spoken.last, contains(ar.checkoutLastMinuteTitle));
    final last = spoken.last;
    await tick(const Duration(seconds: 58));
    expect(spoken.last, last, reason: 'the last minute is announced once');
  });

  test('countdown text is m:ss with Western digits', () {
    expect(countdownText(const Duration(minutes: 9, seconds: 42)), '9:42');
    expect(countdownText(const Duration(seconds: 5)), '0:05');
    expect(countdownText(const Duration(minutes: 20)), '20:00');
    expect(countdownText(const Duration(seconds: -3)), '0:00');
  });

  testWidgets('the moment placeholder carries its words and no animation',
      (tester) async {
    await pumpWidgetUnder(
        tester,
        const MomentPlaceholder(
            kind: MomentKind.failure, title: 'عنوان', body: 'نص', announce: true));
    expect(find.text('عنوان'), findsOneWidget);
    expect(find.text('نص'), findsOneWidget);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('the method card shows the test tag only when asked',
      (tester) async {
    await pumpWidgetUnder(tester, const PaymentMethodCard(showTestTag: true));
    expect(find.byKey(PaymentMethodCard.testTagKey), findsOneWidget);
    expect(find.text(ar.checkoutSandboxTag), findsOneWidget);
    await pumpWidgetUnder(tester, const PaymentMethodCard(showTestTag: false));
    expect(find.byKey(PaymentMethodCard.testTagKey), findsNothing);
    expect(find.text(ar.checkoutMethodTitle), findsOneWidget);
  });

  Widget layout() => const CheckoutLayout(
        title: 'PAY',
        summaryTitle: 'SUM',
        banner: Text('banner'),
        summary: Text('summary'),
        method: Text('method'),
        action: Text('action'),
      );

  testWidgets('compact: one column with the action in a fixed bar',
      (tester) async {
    await pumpWidgetUnder(tester, SizedBox(height: 700, child: layout()));
    expect(find.byKey(CheckoutLayout.barKey), findsOneWidget);
    expect(find.byKey(CheckoutLayout.paymentColumnKey), findsNothing);
    expect(find.text('PAY'), findsNothing);
  });

  testWidgets('from 600: two columns, no bar, the action ends the payment '
      'column', (tester) async {
    await pumpWidgetUnder(tester, SizedBox(height: 700, child: layout()),
        size: const Size(700, 900));
    expect(find.byKey(CheckoutLayout.barKey), findsNothing);
    expect(find.byKey(CheckoutLayout.paymentColumnKey), findsOneWidget);
    expect(find.byKey(CheckoutLayout.summaryColumnKey), findsOneWidget);
    final payment = tester.getRect(find.byKey(CheckoutLayout.paymentColumnKey));
    final summary = tester.getRect(find.byKey(CheckoutLayout.summaryColumnKey));
    expect(payment.overlaps(summary), isFalse);
    expect(payment.width, lessThanOrEqualTo(372));
    // Arabic: the payment column starts at the right.
    expect(payment.center.dx, greaterThan(summary.center.dx));
    final action = tester.getRect(find.text('action'));
    expect(action.bottom, greaterThan(tester.getRect(find.text('method')).bottom));
  });
}
