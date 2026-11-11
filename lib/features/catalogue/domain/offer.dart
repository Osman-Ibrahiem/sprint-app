import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sprint/features/catalogue/domain/price.dart';

part 'offer.freezed.dart';

enum OfferScope { university, facility, unit }

/// A percentage off slots on given days and hours, for one tier or all (BR-20).
/// [days] are 1 (Monday) to 7 (Sunday); times are Cairo wall-clock minutes;
/// [validFrom] and [validTo] are UTC instants.
@freezed
abstract class Offer with _$Offer {
  const factory Offer({
    required String id,
    required OfferScope scope,
    String? scopeId,
    required int discountPercent,
    required Set<int> days,
    required int fromMinutes,
    required int toMinutes,
    PriceTier? tier,
    required DateTime validFrom,
    required DateTime validTo,
  }) = _Offer;
}
