import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';

/// Walk 2026-11-18 (design QA H5): the payment flow's own screens hide the tab
/// bar on compact, so the only ways out are the screen's own (BR-47).
void main() {
  test('checkout, the ticket and the receipt are the payment flow', () {
    expect(
      AppPaths.isPaymentFlow(AppPaths.bookingCheckoutFor('f-pool', 'bk-1')),
      isTrue,
    );
    expect(AppPaths.isPaymentFlow(AppPaths.bookingConfirmed('bk-1')), isTrue);
    expect(AppPaths.isPaymentFlow(AppPaths.bookingReceipt('bk-1')), isTrue);
  });

  test('the schedule, the summary and the bookings list keep the tab bar', () {
    expect(AppPaths.isPaymentFlow('/facilities/f-pool/schedule'), isFalse);
    expect(AppPaths.isPaymentFlow('/facilities/f-pool/schedule/summary'), isFalse);
    expect(AppPaths.isPaymentFlow(AppPaths.bookings), isFalse);
    expect(AppPaths.isPaymentFlow(AppPaths.home), isFalse);
  });
}
