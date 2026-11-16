import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/domain/facility_summary.dart';
import 'package:sprint/features/catalogue/domain/home_content.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/catalogue/domain/suggestion_rule.dart';
import 'package:sprint/features/catalogue/domain/today_availability.dart';

FacilitySummary fac(String id, String name, FacilityType type) =>
    FacilitySummary(
      facility: Facility(
        id: id,
        owningUnitId: 'ou',
        name: name,
        type: type,
        description: '',
        location: '',
        isFree: false,
        requiresTrainer: false,
      ),
      owningUnitName: 'جهة',
      activeUnitCount: 1,
      today: TodayAvailability.noneToday,
    );

Booking booking(
  String facilityId, {
  BookingStatus status = BookingStatus.attended,
}) => Booking(
  id: 'b-$facilityId-${status.name}',
  code: 'C',
  userId: 'u',
  facilityId: facilityId,
  unitId: 'x',
  start: DateTime.utc(2026, 1, 1),
  end: DateTime.utc(2026, 1, 1, 1),
  seats: 1,
  tierAtBooking: PriceTier.internal,
  priceAtBooking: 10,
  status: status,
  qrToken: 'q',
);

void main() {
  final all = [
    fac('a', 'أ', FacilityType.swimming),
    fac('b', 'ب', FacilityType.gym),
    fac('c', 'ج', FacilityType.gym),
    fac('d', 'د', FacilityType.tennis),
    fac('e', 'هـ', FacilityType.hall),
    fac('f', 'و', FacilityType.football),
  ];

  test('no history gives no suggestions', () {
    expect(
      SuggestionRule.pick(
        facilities: all,
        pastBookings: [],
        upcomingFacilityIds: {},
      ),
      isEmpty,
    );
  });

  test('at most four; booked types first by frequency then name', () {
    final s = SuggestionRule.pick(
      facilities: all,
      pastBookings: [booking('b'), booking('b'), booking('a')],
      upcomingFacilityIds: {},
    );
    expect(s, hasLength(4));
    expect([for (final x in s) x.facility.facility.id].take(3), [
      'b',
      'c',
      'a',
    ]);
    expect(s.first.reason, isA<BookedTypeBefore>());
    expect((s.first.reason as BookedTypeBefore).type, FacilityType.gym);
    expect(s.last.reason, isA<OtherSuggestion>());
  });

  test(
    'never a facility with an upcoming booking; unbooked statuses ignored',
    () {
      final s = SuggestionRule.pick(
        facilities: all,
        pastBookings: [
          booking('b'),
          booking('a', status: BookingStatus.cancelled),
        ],
        upcomingFacilityIds: {'b'},
      );
      expect([for (final x in s) x.facility.facility.id], isNot(contains('b')));
      expect(s.first.facility.facility.id, 'c');
      // The cancelled swimming booking is not history.
      final swim = s.where((x) => x.facility.facility.id == 'a').single;
      expect(swim.reason, isA<OtherSuggestion>());
    },
  );

  test('deterministic for the same input', () {
    List<String> run() => [
      for (final x in SuggestionRule.pick(
        facilities: all,
        pastBookings: [booking('d')],
        upcomingFacilityIds: {},
      ))
        x.facility.facility.id,
    ];
    expect(run(), run());
  });
}
