import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/payments/domain/payment.dart';

import '../../helpers/data_env.dart';

/// Feature 006 seed: a paid confirmed booking with its receipt, and a free
/// confirmed one, both with ordinary `SP-1xxx` codes (T018, FR-025).
void main() {
  final env = DataEnv();
  final layer = env.layer;

  test('a paid confirmed booking has a succeeded payment and a receipt number',
      () async {
    final paid = layer.bookings.allBookings.singleWhere((b) =>
        b.userId == Ids.bookerInternal &&
        b.unitId == Ids.pool3 &&
        b.status == BookingStatus.confirmed);
    expect(paid.priceAtBooking, greaterThan(0));
    final p = (await layer.payments.latestPayment(paid.id))!;
    expect(p.status, PaymentStatus.succeeded);
    expect(p.cardLast4, '4242');
    expect(p.receiptNumber, matches(RegExp(r'^RC-\d{6}-\d{4}$')));
  });

  test('a free confirmed booking has no payment', () async {
    final free = layer.bookings.allBookings.singleWhere((b) =>
        b.userId == Ids.bookerInternal &&
        b.unitId == Ids.hall1 &&
        b.status == BookingStatus.confirmed);
    expect(free.priceAtBooking, 0);
    expect(await layer.payments.latestPayment(free.id), isNull);
  });

  test('every code is SP-1xxx, never SPR-…', () {
    for (final b in layer.bookings.allBookings) {
      expect(b.code, matches(RegExp(r'^SP-1\d{3}$')));
    }
  });

  test('every seeded succeeded payment has a unique receipt number', () {
    final numbers = [
      for (final p in layer.payments.allPayments)
        if (p.status == PaymentStatus.succeeded) p.receiptNumber,
    ];
    expect(numbers, everyElement(isNotNull));
    expect(numbers.toSet().length, numbers.length);
  });
}
