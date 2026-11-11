import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/features/booking/domain/unit_settings.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/domain/offer.dart';
import 'package:sprint/features/catalogue/domain/price.dart';

class PriceQuote {
  const PriceQuote({
    required this.tier,
    required this.baseAmount,
    required this.discountPercent,
    required this.amount,
    this.appliedOfferId,
  });

  final PriceTier tier;
  final int baseAmount;
  final int discountPercent;

  /// Whole Egyptian pounds, after the best offer.
  final int amount;
  final String? appliedOfferId;

  /// Free facilities, and anything that comes to zero, skip payment (BR-19).
  bool get requiresPayment => amount > 0;
}

/// Tier prices, per-place pricing in shared units and the best offer (BR-15 –
/// BR-20). Pure. The caller passes only offers that are in scope.
class PricingService {
  const PricingService();

  Result<PriceQuote> quote({
    required Facility facility,
    required List<Price> prices,
    required PriceTier tier,
    required BookingMode mode,
    required DateTime start,
    required int seats,
    required List<Offer> offers,
  }) {
    if (facility.isFree) {
      return Ok(PriceQuote(
        tier: tier,
        baseAmount: 0,
        discountPercent: 0,
        amount: 0,
      ));
    }
    Price? row;
    for (final p in prices) {
      if (p.tier == tier) row = p;
    }
    if (row == null) return const Err(NotFound('price'));

    // BR-16: exclusive prices the whole slot, shared prices each place.
    final base = mode == BookingMode.shared ? row.amount * seats : row.amount;

    final cairo = CairoTime.toCairo(start);
    final minutes = cairo.hour * 60 + cairo.minute;
    Offer? best;
    for (final o in offers) {
      final applies = (o.tier == null || o.tier == tier) &&
          o.days.contains(cairo.weekday) &&
          minutes >= o.fromMinutes &&
          minutes < o.toMinutes &&
          !start.isBefore(o.validFrom) &&
          !start.isAfter(o.validTo);
      if (applies && (best == null || o.discountPercent > best.discountPercent)) {
        best = o;
      }
    }
    final discount = best?.discountPercent ?? 0;
    // Half up, in whole pounds.
    final amount = (base * (100 - discount) + 50) ~/ 100;
    return Ok(PriceQuote(
      tier: tier,
      baseAmount: base,
      discountPercent: discount,
      amount: amount,
      appliedOfferId: best?.id,
    ));
  }
}
