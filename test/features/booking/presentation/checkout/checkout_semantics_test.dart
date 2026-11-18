import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/adaptive/adaptive_back_button.dart';
import 'package:sprint/features/booking/presentation/checkout/checkout_screen.dart';
import 'package:sprint/features/booking/presentation/checkout/expired_view.dart';
import 'package:sprint/features/booking/presentation/checkout/hold_banner.dart';
import 'package:sprint/features/payments/data/fake_gateway_controller.dart';

import '../../../../helpers/pump_app.dart';
import 'checkout_harness.dart';

/// Screen readers, keyboard and reduced motion on checkout (US-9, FR-031,
/// NFR accessibility).
void main() {
  bool focusIn(Key key) {
    var found = false;
    FocusManager.instance.primaryFocus?.context?.visitAncestorElements((e) {
      if (e.widget.key == key) {
        found = true;
        return false;
      }
      return true;
    });
    return found;
  }

  testWidgets('the countdown is spoken every 30 seconds and once at the last '
      'minute, not every second', (tester) async {
    final handle = tester.ensureSemantics();
    final env = await CheckoutEnv.open(tester);
    String spoken() =>
        tester.getSemantics(find.byKey(HoldBanner.liveRegionKey)).label;
    final labels = <String>[spoken()];
    for (var i = 0; i < 595; i += 1) {
      await env.advance(const Duration(seconds: 1));
      if (spoken() != labels.last) labels.add(spoken());
    }
    // Ten minutes: about twenty 30-second windows plus the last minute, never
    // 600 announcements.
    expect(labels.length, lessThanOrEqualTo(22));
    expect(labels.length, greaterThan(15));
    expect(
      labels.where((l) => l.contains(ar.checkoutLastMinuteTitle)),
      hasLength(1),
    );
    handle.dispose();
  });

  testWidgets('the expiry title is announced once', (tester) async {
    final handle = tester.ensureSemantics();
    final env = await CheckoutEnv.open(tester);
    await env.advance(const Duration(minutes: 11));
    await tester.pumpAndSettle();
    final node = tester.getSemantics(find.byKey(ExpiredView.titleKey));
    expect(node.label, ar.holdExpiredTitle);
    expect(node.flagsCollection.isLiveRegion, isTrue);
    handle.dispose();
  });

  testWidgets('the pay button reads with the full amount', (tester) async {
    final handle = tester.ensureSemantics();
    await CheckoutEnv.open(tester);
    final node = tester.getSemantics(find.byKey(CheckoutScreen.payKey));
    expect(node.label, ar.checkoutPaySpoken(140));
    expect(node.flagsCollection.isButton, isTrue);
    handle.dispose();
  });

  testWidgets('the booking code is read character by character and the QR '
      'has a label', (tester) async {
    final handle = tester.ensureSemantics();
    final env = await CheckoutEnv.open(
      tester,
      outcome: const FakeOutcome.succeed(),
    );
    await env.payOnPage();
    final spacedCode = env.booking.code.split('').join(' ');
    expect(
      find.bySemanticsLabel(RegExp(RegExp.escape(spacedCode))),
      findsWidgets,
    );
    expect(
      find.bySemanticsLabel(RegExp(RegExp.escape(ar.ticketQrLabel))),
      findsWidgets,
    );
    handle.dispose();
  });

  testWidgets('keyboard: Tab reaches the back button, then the pay button', (
    tester,
  ) async {
    await CheckoutEnv.open(tester);
    final order = <String>[];
    for (var i = 0; i < 30 && !order.contains('pay'); i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final back =
          FocusManager.instance.primaryFocus?.context != null &&
          _inside(AdaptiveBackButton);
      if (back && !order.contains('back')) order.add('back');
      if (focusIn(CheckoutScreen.payKey) && !order.contains('pay')) {
        order.add('pay');
      }
    }
    expect(order, ['back', 'pay']);
    expect(FocusManager.instance.highlightMode, FocusHighlightMode.traditional);
    // Enter on the focused pay button starts the payment.
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
  });

  testWidgets('reduced motion: nothing animates and the numbers still update', (
    tester,
  ) async {
    final env = await CheckoutEnv.open(tester);
    expect(tester.hasRunningAnimations, isFalse);
    expect(find.text(ar.checkoutHoldRemaining('10:00')), findsOneWidget);
    await env.advance(const Duration(seconds: 30));
    expect(find.text(ar.checkoutHoldRemaining('9:30')), findsOneWidget);
    expect(tester.hasRunningAnimations, isFalse);
  });
}

bool _inside(Type type) {
  var found = false;
  FocusManager.instance.primaryFocus?.context?.visitAncestorElements((e) {
    if (e.widget.runtimeType == type) {
      found = true;
      return false;
    }
    return true;
  });
  return found;
}
