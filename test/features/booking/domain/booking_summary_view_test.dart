import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/booking/domain/booking_quote.dart';
import 'package:sprint/features/booking/domain/booking_summary_view.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/settings/domain/booking_mode.dart';

import '../../../helpers/domain_builders.dart';

BookingQuote quote({
  BookingMode mode = BookingMode.exclusive,
  int amount = 140,
  int? max = 22,
  PriceTier tier = PriceTier.internal,
}) => BookingQuote(
  facilityId: 'f',
  unitId: 'u',
  start: cairo(2026, 11, 17, 18),
  end: cairo(2026, 11, 17, 19, 30),
  tier: tier,
  amount: amount,
  mode: mode,
  maxParticipants: max,
  cancellationCutoffHours: 2,
  refundPercent: 100,
);

BookingSummaryView view(
  BookingQuote q, {
  VerificationHint hint = VerificationHint.canVerify,
  int? shown,
}) => BookingSummaryView.from(
  quote: q,
  facilityName: 'منشأة',
  unitName: 'وحدة',
  verificationHint: hint,
  shown: shown,
);

void main() {
  test(
    'an exclusive unit covers the whole unit with its participants (BR-02)',
    () {
      final v = view(quote());
      expect(v.coverage, isA<WholeUnit>());
      expect((v.coverage as WholeUnit).maxParticipants, 22);
      expect(v.isPerPlace, isFalse);
    },
  );

  test('a shared unit covers one place (BR-03)', () {
    final v = view(quote(mode: BookingMode.shared, max: null));
    expect(v.coverage, isA<OnePlace>());
    expect(v.isPerPlace, isTrue);
  });

  test('the length is the real difference', () {
    expect(view(quote()).lengthMinutes, 90);
  });

  test('the price-changed flag compares with what the schedule showed', () {
    expect(view(quote(), shown: 140).priceChanged, isFalse);
    expect(view(quote(), shown: 300).priceChanged, isTrue);
    expect(view(quote()).priceChanged, isFalse);
  });

  test('a free booking never shows a verification hint', () {
    final v = view(quote(amount: 0), hint: VerificationHint.canVerify);
    expect(v.isFree, isTrue);
    expect(v.verificationHint, VerificationHint.none);
  });

  test('a paid booking keeps the hint', () {
    expect(
      view(quote(), hint: VerificationHint.underReview).verificationHint,
      VerificationHint.underReview,
    );
  });
}
