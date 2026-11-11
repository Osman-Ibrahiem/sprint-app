import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/conflict_checker.dart';
import 'package:sprint/features/booking/domain/unit_settings.dart';

import '../../helpers/domain_builders.dart';

void main() {
  const checker = ConflictChecker();
  final now = cairo(2026, 11, 13, 6);
  final nine = cairo(2026, 11, 14, 9);
  final ten = cairo(2026, 11, 14, 10);

  BookingProposal proposal({
    String user = 'me',
    String unitId = 'u1',
    DateTime? start,
    DateTime? end,
    int seats = 1,
    String? trainerId,
  }) =>
      BookingProposal(
        userId: user,
        unitId: unitId,
        start: start ?? nine,
        end: end ?? (start ?? nine).add(const Duration(hours: 1)),
        seats: seats,
        trainerId: trainerId,
      );

  Failure? check(
    BookingProposal p,
    List<Booking> existing, {
    UnitSettings? s,
    int? trainerCapacity,
  }) =>
      checker.check(
        proposal: p,
        existing: existing,
        settings: s ?? settings(mode: BookingMode.exclusive),
        now: now,
        trainerCapacity: trainerCapacity,
      );

  group('exclusive (BR-02, BR-11)', () {
    test('a free slot is accepted', () {
      expect(check(proposal(), const []), isNull);
    });

    test('double booking the same slot is refused', () {
      expect(check(proposal(), [booking(userId: 'other', start: nine)]),
          isA<SlotTaken>());
    });

    test('an overlapping booking, even partly, is refused', () {
      final half = cairo(2026, 11, 14, 9, 30);
      expect(check(proposal(), [booking(userId: 'other', start: half)]),
          isA<SlotTaken>());
    });

    test('back-to-back slots do not conflict', () {
      expect(check(proposal(), [booking(userId: 'other', start: ten)]), isNull);
    });

    test('another unit does not conflict', () {
      expect(
        check(proposal(), [booking(userId: 'other', unitId: 'u2', start: nine)]),
        isNull,
      );
    });

    test('cancelled, expired and no-show bookings free the slot', () {
      for (final status in [
        BookingStatus.cancelled,
        BookingStatus.expired,
      ]) {
        expect(
          check(proposal(), [booking(userId: 'other', start: nine, status: status)]),
          isNull,
          reason: '$status',
        );
      }
    });
  });

  group('active holds (BR-12)', () {
    test('a live hold counts as taken', () {
      final held = booking(
        userId: 'other',
        start: nine,
        status: BookingStatus.pendingPayment,
        holdExpiresAt: now.add(const Duration(minutes: 5)),
      );
      expect(check(proposal(), [held]), isA<SlotTaken>());
    });

    test('an elapsed hold does not', () {
      final held = booking(
        userId: 'other',
        start: nine,
        status: BookingStatus.pendingPayment,
        holdExpiresAt: now.subtract(const Duration(minutes: 1)),
      );
      expect(check(proposal(), [held]), isNull);
    });
  });

  group('shared capacity (BR-03)', () {
    final shared = settings(mode: BookingMode.shared, capacity: 3);
    List<Booking> taken(int n) =>
        [for (var i = 0; i < n; i++) booking(userId: 'o$i', start: nine)];

    test('places left: accepted', () {
      expect(check(proposal(), taken(2), s: shared), isNull);
    });

    test('over capacity: refused', () {
      expect(check(proposal(), taken(3), s: shared), isA<SlotFull>());
    });

    test('asking for more seats than remain is refused', () {
      expect(check(proposal(seats: 2), taken(2), s: shared), isA<SlotFull>());
    });

    test('the trainer capacity limits a session', () {
      final withTrainer = [
        booking(userId: 'o1', start: nine, trainerId: 't1'),
        booking(userId: 'o2', start: nine, trainerId: 't1'),
      ];
      expect(
        check(proposal(trainerId: 't1'), withTrainer,
            s: settings(mode: BookingMode.shared, capacity: 8),
            trainerCapacity: 2),
        isA<SlotFull>(),
      );
      expect(
        check(proposal(trainerId: 't1'), withTrainer,
            s: settings(mode: BookingMode.shared, capacity: 8),
            trainerCapacity: 3),
        isNull,
      );
    });
  });

  group('same user overlap (BR-13)', () {
    test('overlapping bookings of the same user are refused, across facilities',
        () {
      final mine = booking(
        userId: 'me',
        facilityId: 'f2',
        unitId: 'u9',
        start: nine,
      );
      expect(check(proposal(unitId: 'u1'), [mine]), isA<OverlapsOwnBooking>());
    });

    test('adjacent bookings of the same user are fine', () {
      final mine = booking(userId: 'me', unitId: 'u9', start: ten);
      expect(check(proposal(), [mine]), isNull);
    });

    test('someone else overlapping on another unit is fine', () {
      expect(
        check(proposal(), [booking(userId: 'other', unitId: 'u9', start: nine)]),
        isNull,
      );
    });

    test('cancelled bookings of the same user do not block', () {
      final mine = booking(
        userId: 'me',
        unitId: 'u9',
        start: nine,
        status: BookingStatus.cancelled,
      );
      expect(check(proposal(), [mine]), isNull);
    });
  });

  group('max active bookings per user (BR-14)', () {
    List<Booking> active(int n) => [
          for (var i = 0; i < n; i++)
            booking(
              userId: 'me',
              unitId: 'x$i',
              start: cairo(2026, 11, 20 + i, 9),
            ),
        ];

    test('no limit by default', () {
      expect(check(proposal(), active(10)), isNull);
    });

    test('at the limit the next booking is refused', () {
      expect(check(proposal(), active(2), s: settings(maxActive: 2)),
          isA<TooManyActiveBookings>());
    });

    test('below the limit it is accepted', () {
      expect(check(proposal(), active(1), s: settings(maxActive: 2)), isNull);
    });

    test('finished and cancelled bookings do not count', () {
      final done = [
        booking(
          userId: 'me',
          unitId: 'p1',
          start: cairo(2026, 11, 1, 9),
          status: BookingStatus.attended,
        ),
        booking(
          userId: 'me',
          unitId: 'p2',
          start: cairo(2026, 11, 21, 9),
          status: BookingStatus.cancelled,
        ),
      ];
      expect(check(proposal(), done, s: settings(maxActive: 1)), isNull);
    });
  });
}
