import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/booking/domain/booking_repository.dart';
import 'package:sprint/features/booking/domain/slot.dart';
import 'package:sprint/features/settings/domain/setting_definition.dart';
import 'package:sprint/features/settings/domain/setting_registry.dart';

import '../../../helpers/data_env.dart';

/// The few-left state follows the `fewLeftThreshold` setting with inheritance
/// (BR-45, feature 005 research R5).
void main() {
  late DataEnv env;
  setUp(() => env = DataEnv());

  // Lane 6 opens at 16:00 and has no seeded bookings.
  Future<Slot> lane6() async {
    final when = env.at(2, 17);
    final slots = await env.layer.availability.slots(Ids.pool6, when, when);
    return slots.singleWhere((s) => s.start == when);
  }

  Future<void> set(SettingScope scope, int value) => env.layer.settings.set(
        SettingKeys.fewLeftThreshold,
        value,
        scope,
        actorId: Ids.superAdmin,
      );

  setUp(() async {
    // Capacity 4 with one booking: three places left.
    await env.layer.settings.set(
      SettingKeys.capacity,
      4,
      const SettingScope.unit(Ids.pool6),
      actorId: Ids.superAdmin,
    );
    await env.layer.bookings.create(BookingRequest(
      userId: Ids.bookerExternal,
      unitId: Ids.pool6,
      start: env.at(2, 17),
      end: env.at(2, 18),
    ));
  });

  test('three places left is available with the default threshold of 2',
      () async {
    final s = await lane6();
    expect((s.remaining, s.state), (3, SlotState.available));
  });

  test('a unit-level threshold of 3 makes it few-left', () async {
    await set(const SettingScope.unit(Ids.pool6), 3);
    expect((await lane6()).state, SlotState.fewLeft);
  });

  test('a facility-level threshold applies when the unit has none', () async {
    await set(const SettingScope.facility(Ids.poolFacility), 3);
    expect((await lane6()).state, SlotState.fewLeft);
  });

  test('the unit value wins over the facility value', () async {
    await set(const SettingScope.facility(Ids.poolFacility), 3);
    await set(const SettingScope.unit(Ids.pool6), 1);
    expect((await lane6()).state, SlotState.available);
  });
}
