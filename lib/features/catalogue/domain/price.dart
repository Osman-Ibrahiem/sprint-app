import 'package:freezed_annotation/freezed_annotation.dart';

part 'price.freezed.dart';

/// Two tiers only (BR-15). The tier comes from verification at booking time
/// and is frozen on the booking (BR-17).
enum PriceTier { internal, external }

/// One row per unit x tier (BR-16). Whole Egyptian pounds.
@freezed
abstract class Price with _$Price {
  const factory Price({
    required String unitId,
    required PriceTier tier,
    required int amount,
    @Default('EGP') String currency,
  }) = _Price;
}
