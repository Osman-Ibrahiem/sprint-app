import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/domain/facility_filter.dart';

void main() {
  group('FacilityFilter', () {
    test('defaults are inactive', () {
      const filter = FacilityFilter();
      expect(filter.isActive, isFalse);
      expect(filter.activeCount, 0);
      expect(filter.type, isNull);
      expect(filter.owningUnitId, isNull);
      expect(filter.free, isNull);
    });

    test('each field sets isActive', () {
      expect(const FacilityFilter(type: FacilityType.gym).isActive, isTrue);
      expect(const FacilityFilter(owningUnitId: 'ou-1').isActive, isTrue);
      expect(const FacilityFilter(free: true).isActive, isTrue);
      expect(const FacilityFilter(free: false).isActive, isTrue);
    });

    test('activeCount counts the set fields', () {
      expect(const FacilityFilter(type: FacilityType.gym).activeCount, 1);
      expect(
        const FacilityFilter(type: FacilityType.gym, free: false).activeCount,
        2,
      );
      expect(
        const FacilityFilter(
          type: FacilityType.swimming,
          owningUnitId: 'ou-1',
          free: true,
        ).activeCount,
        3,
      );
    });

    test('a filter maps one to one onto the repository parameters', () {
      const filter = FacilityFilter(
        type: FacilityType.tennis,
        owningUnitId: 'ou-eng',
        free: false,
      );
      expect(filter.type, FacilityType.tennis);
      expect(filter.owningUnitId, 'ou-eng');
      expect(filter.free, isFalse);
    });

    test('copyWith clears a single field without touching the others', () {
      const filter = FacilityFilter(type: FacilityType.gym, free: true);
      final cleared = filter.copyWith(type: null);
      expect(cleared.type, isNull);
      expect(cleared.free, isTrue);
      expect(cleared.activeCount, 1);
    });
  });
}
