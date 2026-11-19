import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/widgets/facility_card/facility_card_data.dart';
import 'package:sprint/features/catalogue/domain/arabic_normalizer.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/domain/facility_search.dart';
import 'package:sprint/features/catalogue/domain/facility_summary.dart';
import 'package:sprint/features/catalogue/domain/search_suggestions.dart';
import 'package:sprint/features/catalogue/domain/today_availability.dart';

import '../../../helpers/domain_builders.dart';

/// FR-014: normalised Arabic and Latin search over the name, type label and
/// owning unit, open facilities first, then the fullest.
void main() {
  FacilitySummary summary({
    String id = 'f',
    String name = 'منشأة',
    FacilityType type = FacilityType.gym,
    String owning = 'وحدة',
    int count = 0,
    bool closed = false,
  }) =>
      FacilitySummary(
        facility: facility(id: id, type: type).copyWith(name: name),
        owningUnitName: owning,
        activeUnitCount: 1,
        today: TodayAvailability(
          level: count == 0 ? AvailabilityLevel.none : AvailabilityLevel.plenty,
          count: count,
          closedToday: closed,
        ),
      );

  const labels = {
    FacilityType.swimming: 'سباحة',
    FacilityType.football: 'كرة قدم',
    FacilityType.gym: 'جيم',
    FacilityType.tennis: 'تنس',
    FacilityType.hall: 'قاعة',
    FacilityType.training: 'تدريب',
  };
  String labelOf(FacilityType t) => labels[t]!;

  group('ArabicNormalizer', () {
    test('drops tashkeel and unifies the letters', () {
      expect(ArabicNormalizer.normalize('أَحْمَد'), 'احمد');
      expect(ArabicNormalizer.normalize('إسلام'), 'اسلام');
      expect(ArabicNormalizer.normalize('آية'), 'ايه');
      expect(ArabicNormalizer.normalize('مدرسة'), 'مدرسه');
      expect(ArabicNormalizer.normalize('مصطفى'), 'مصطفي');
    });

    test('lowercases Latin and collapses spaces', () {
      expect(ArabicNormalizer.normalize('  SPORT   Club '), 'sport club');
    });
  });

  test('matches name, type label and owning unit name', () {
    final all = [
      summary(
        id: 'pool',
        name: 'مسبح النيل',
        type: FacilityType.swimming,
        owning: 'نادي الجامعة',
        count: 4,
      ),
      summary(id: 'gym', name: 'صالة الألعاب', type: FacilityType.gym, count: 4),
      summary(id: 'tennis', name: 'ملعب التنس', type: FacilityType.tennis, count: 4),
    ];

    List<String> ids(String q) => FacilitySearch.filter(all, q, typeLabelOf: labelOf)
        .map((s) => s.facility.id)
        .toList();

    expect(ids('مسبح'), ['pool']);
    expect(ids('نادي'), ['pool']); // owning unit
    expect(ids('جيم'), ['gym']); // type label
    expect(ids('إسلام'), isEmpty);
  });

  test('open today by count descending, then closed, ties by name', () {
    final all = [
      summary(id: 'small', name: 'بي', count: 3),
      summary(id: 'big', name: 'جيم', count: 10),
      summary(id: 'closed', name: 'ألف', closed: true),
      summary(id: 'tieA', name: 'تنس', count: 3),
    ];
    final order = FacilitySearch.filter(all, '', typeLabelOf: labelOf)
        .map((s) => s.facility.id)
        .toList();
    expect(order, ['big', 'small', 'tieA', 'closed']);
  });

  test('an empty or spaces-only query returns all', () {
    final all = [summary(id: 'a'), summary(id: 'b', closed: true)];
    expect(FacilitySearch.filter(all, ''), hasLength(2));
    expect(FacilitySearch.filter(all, '   '), hasLength(2));
  });

  test('very long mixed text never throws', () {
    final all = [summary(id: 'a', name: 'منشأة')];
    final query = '${'ا' * 5000} SPORT ١٢٣';
    expect(() => FacilitySearch.filter(all, query), returnsNormally);
  });

  group('SearchSuggestions', () {
    test('most booked takes two ids, ties by name', () {
      final all = [
        summary(id: 'a', name: 'ب', count: 0),
        summary(id: 'b', name: 'أ', count: 0),
        summary(id: 'c', name: 'ج', count: 9),
      ];
      expect(
        SearchSuggestions.mostBookedFrom(all, {'c': 9}),
        ['c', 'b'],
      );
    });
  });
}
