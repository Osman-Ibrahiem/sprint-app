import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/widgets/facility_card/facility_card_data.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/domain/facility_summary.dart';
import 'package:sprint/features/catalogue/domain/today_availability.dart';

Facility facility({
  bool isFree = false,
  bool requiresTrainer = false,
}) =>
    Facility(
      id: 'f1',
      owningUnitId: 'ou1',
      name: 'منشأة',
      type: FacilityType.gym,
      description: 'وصف',
      location: 'الموقع',
      isFree: isFree,
      requiresTrainer: requiresTrainer,
    );

FacilitySummary summary(Facility f) => FacilitySummary(
      facility: f,
      owningUnitName: 'وحدة',
      activeUnitCount: 1,
      today: TodayAvailability.noneToday,
    );

void main() {
  group('FacilitySummary.kind', () {
    test('a free facility is free', () {
      expect(summary(facility(isFree: true)).kind, FacilityKind.free);
    });

    test('a trainer facility is withTrainer', () {
      expect(
        summary(facility(requiresTrainer: true)).kind,
        FacilityKind.withTrainer,
      );
    });

    test('anything else is paid', () {
      expect(summary(facility()).kind, FacilityKind.paid);
    });

    test('free wins over trainer', () {
      expect(
        summary(facility(isFree: true, requiresTrainer: true)).kind,
        FacilityKind.free,
      );
    });
  });

  group('TierPriceRange', () {
    test('equal amounts are single', () {
      const range = TierPriceRange(min: 40, max: 40);
      expect(range.isSingle, isTrue);
    });

    test('different amounts are a range', () {
      const range = TierPriceRange(min: 40, max: 60);
      expect(range.isSingle, isFalse);
      expect(range.min, 40);
      expect(range.max, 60);
    });
  });

  test('price fields are null for a free facility', () {
    final s = summary(facility(isFree: true));
    expect(s.priceInternal, isNull);
    expect(s.priceExternal, isNull);
  });
}
