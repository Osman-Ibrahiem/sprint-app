import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/features/booking/domain/pricing_service.dart';
import 'package:sprint/features/booking/domain/unit_settings.dart';
import 'package:sprint/features/catalogue/domain/offer.dart';
import 'package:sprint/features/catalogue/domain/price.dart';

import '../../helpers/domain_builders.dart';

void main() {
  const service = PricingService();
  final f = facility();
  final slot = cairo(2026, 11, 14, 9); // Saturday 9:00

  const prices = [
    Price(unitId: 'u1', tier: PriceTier.external, amount: 120),
    Price(unitId: 'u1', tier: PriceTier.internal, amount: 50),
  ];

  PriceQuote quote({
    PriceTier tier = PriceTier.external,
    int seats = 1,
    BookingMode mode = BookingMode.exclusive,
    List<Offer> offers = const [],
    bool free = false,
    List<Price> table = prices,
    DateTime? at,
  }) {
    final r = service.quote(
      facility: free ? facility(isFree: true) : f,
      prices: table,
      tier: tier,
      mode: mode,
      start: at ?? slot,
      seats: seats,
      offers: offers,
    );
    return (r as Ok<PriceQuote>).value;
  }

  Offer offer({
    String id = 'o',
    int percent = 10,
    Set<int> days = const {1, 2, 3, 4, 5, 6, 7},
    int from = 0,
    int to = 1440,
    PriceTier? tier,
    DateTime? validFrom,
    DateTime? validTo,
  }) =>
      Offer(
        id: id,
        scope: OfferScope.facility,
        scopeId: 'f1',
        discountPercent: percent,
        days: days,
        fromMinutes: from,
        toMinutes: to,
        tier: tier,
        validFrom: validFrom ?? cairo(2026, 1, 1),
        validTo: validTo ?? cairo(2026, 12, 31),
      );

  group('tiers (BR-15, BR-16)', () {
    test('each tier gets its own price', () {
      expect(quote(tier: PriceTier.external).amount, 120);
      expect(quote(tier: PriceTier.internal).amount, 50);
      expect(quote(tier: PriceTier.internal).tier, PriceTier.internal);
    });

    test('shared: the price is per place', () {
      expect(quote(mode: BookingMode.shared, seats: 3).amount, 360);
    });

    test('exclusive: one price for the whole slot whatever the seats', () {
      expect(quote(mode: BookingMode.exclusive, seats: 4).amount, 120);
    });

    test('a missing price for the tier is an error', () {
      final r = service.quote(
        facility: f,
        prices: const [Price(unitId: 'u1', tier: PriceTier.external, amount: 10)],
        tier: PriceTier.internal,
        mode: BookingMode.exclusive,
        start: slot,
        seats: 1,
        offers: const [],
      );
      expect((r as Err<PriceQuote>).failure, isA<NotFound>());
    });
  });

  group('free facility (BR-19)', () {
    test('costs nothing and needs no payment', () {
      final q = quote(free: true, table: const []);
      expect(q.amount, 0);
      expect(q.requiresPayment, isFalse);
    });

    test('a paid facility requires payment', () {
      expect(quote().requiresPayment, isTrue);
    });
  });

  group('offers (BR-20)', () {
    test('the best applicable offer wins', () {
      final q = quote(offers: [
        offer(id: 'a', percent: 10),
        offer(id: 'b', percent: 25),
        offer(id: 'c', percent: 15),
      ]);
      expect(q.discountPercent, 25);
      expect(q.appliedOfferId, 'b');
      expect(q.baseAmount, 120);
      expect(q.amount, 90);
    });

    test('a tier-limited offer applies only to that tier', () {
      final o = offer(percent: 50, tier: PriceTier.internal);
      expect(quote(offers: [o]).amount, 120);
      expect(quote(tier: PriceTier.internal, offers: [o]).amount, 25);
    });

    test('the day and the time window must match', () {
      // 2026-11-14 is a Saturday (DateTime.saturday == 6).
      expect(quote(offers: [offer(days: {1, 2})]).amount, 120);
      expect(quote(offers: [offer(days: {6})]).amount, 108);
      expect(quote(offers: [offer(from: 600, to: 720)]).amount, 120); // 10-12
      expect(quote(offers: [offer(from: 480, to: 600)]).amount, 108); // 8-10
      // The slot's own start is what counts: 10:00 is outside 8-10.
      expect(
        quote(offers: [offer(from: 480, to: 600)], at: cairo(2026, 11, 14, 10))
            .amount,
        120,
      );
    });

    test('an offer outside its validity dates does not apply', () {
      expect(
        quote(offers: [offer(validTo: cairo(2026, 11, 1))]).amount,
        120,
      );
      expect(
        quote(offers: [offer(validFrom: cairo(2026, 12, 1))]).amount,
        120,
      );
    });

    test('a discount is rounded to whole pounds', () {
      expect(quote(offers: [offer(percent: 15)]).amount, 102); // 120 x 0.85
      final q = quote(
        table: const [Price(unitId: 'u1', tier: PriceTier.external, amount: 45)],
        offers: [offer(percent: 10)],
      );
      expect(q.amount, 41); // 40.5 rounds to 41 (half up)
    });

    test('a 100% offer makes it free but the facility is still paid-type', () {
      final q = quote(offers: [offer(percent: 100)]);
      expect(q.amount, 0);
    });
  });
}
