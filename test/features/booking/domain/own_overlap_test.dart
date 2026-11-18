import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/own_overlap.dart';

import '../../../helpers/domain_builders.dart';

void main() {
  final now = cairo(2026, 11, 14, 8);
  final six = cairo(2026, 11, 17, 18);
  final seven = cairo(2026, 11, 17, 19);

  test(
    'finds a confirmed booking at the same time, in any facility (BR-13)',
    () {
      final mine = booking(
        id: 'pool',
        unitId: 'lane',
        facilityId: 'pool',
        start: six,
      );
      expect(OwnOverlap.find([mine], six, seven, now)?.id, 'pool');
    },
  );

  test('a partial overlap counts', () {
    final mine = booking(start: cairo(2026, 11, 17, 17, 30));
    expect(OwnOverlap.find([mine], six, seven, now), isNotNull);
  });

  test('touching times do not overlap', () {
    final before = booking(start: cairo(2026, 11, 17, 17));
    final after = booking(start: seven);
    expect(OwnOverlap.find([before, after], six, seven, now), isNull);
  });

  test('cancelled and expired bookings do not count', () {
    final gone = [
      booking(start: six, status: BookingStatus.cancelled),
      booking(start: six, status: BookingStatus.expired),
      booking(
        start: six,
        status: BookingStatus.pendingPayment,
        holdExpiresAt: now.subtract(const Duration(minutes: 1)),
      ),
    ];
    expect(OwnOverlap.find(gone, six, seven, now), isNull);
  });

  test('a live hold counts', () {
    final held = booking(
      start: six,
      status: BookingStatus.pendingPayment,
      holdExpiresAt: now.add(const Duration(minutes: 5)),
    );
    expect(OwnOverlap.find([held], six, seven, now), isNotNull);
  });
}
