import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/seed/seed_booking_extras.dart';
import 'package:sprint/features/booking/domain/slot.dart';

import '../../helpers/data_env.dart';

/// The booking seed extras (feature 005 research R12, FR-037).
void main() {
  late DataEnv env;
  setUp(() => env = DataEnv());

  Future<Slot> slotAt(
    String unitId,
    int day,
    int hour, {
    String? trainerId,
  }) async {
    final when = env.at(day, hour);
    final slots = await env.layer.availability.slots(
      unitId,
      when,
      when,
      trainerId: trainerId,
    );
    return slots.singleWhere((s) => s.start == when);
  }

  test('lane 2 has one place left in the few-left slot (BR-45)', () async {
    final s = await slotAt(Ids.pool2, seedFewLeftDayOffset, seedFewLeftHour);
    expect(s.remaining, 1);
    expect(s.state, SlotState.fewLeft);
  });

  test('trainer 1 is at capacity while the room has places (BR-09)', () async {
    final day = seedTrainerFullDayOffset(env.now);
    final withTrainer = await slotAt(
      Ids.room1,
      day,
      seedTrainerFullHour,
      trainerId: Ids.trainerRecord1,
    );
    expect(withTrainer.state, SlotState.full);

    final when = env.at(day, seedTrainerFullHour);
    final inRoom = (await env.layer.bookings.bookingsForUnit(Ids.room1))
        .where((b) => b.start == when)
        .length;
    expect(inRoom, 3); // room capacity is 6
  });

  test('the trainer day is always a day trainer 1 works', () {
    for (var d = 0; d < 7; d++) {
      final now = env.now.add(Duration(days: d));
      final offset = seedTrainerFullDayOffset(now);
      final day = env.now.add(Duration(days: d + offset));
      expect({6, 7, 1, 2, 3}, contains(day.weekday), reason: 'from day +$d');
    }
  });

  test('no seeded user holds two overlapping bookings (BR-13)', () {
    final all = env.layer.bookings.allBookings
        .where((b) => b.holdsPlace(env.now))
        .toList();
    for (var i = 0; i < all.length; i++) {
      for (var j = i + 1; j < all.length; j++) {
        final a = all[i], b = all[j];
        if (a.userId != b.userId) continue;
        expect(
          a.overlaps(b.start, b.end),
          isFalse,
          reason: '${a.id} and ${b.id} of ${a.userId}',
        );
      }
    }
  });
}
