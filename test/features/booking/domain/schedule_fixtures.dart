import 'package:sprint/features/booking/domain/facility_schedule.dart';
import 'package:sprint/features/booking/domain/slot.dart';
import 'package:sprint/features/booking/domain/unit_settings.dart';
import 'package:sprint/features/catalogue/domain/bookable_unit.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/domain/price.dart';

import '../../../helpers/domain_builders.dart';

/// "Now" for the schedule rule tests: Saturday 2026-11-14, 08:00 in Cairo.
final fixtureNow = cairo(2026, 11, 14, 8);
final fixtureToday = DateTime(2026, 11, 14);

DateTime dayPlus(int n) => DateTime(2026, 11, 14 + n);

/// A one-hour (or [minutes]-long) slot on day +[day] at [hour].
Slot slotAt(
  int day,
  int hour, {
  SlotState state = SlotState.available,
  int remaining = 5,
  int capacity = 6,
  int minutes = 60,
}) {
  final start = cairo(2026, 11, 14 + day, hour);
  return Slot(
    start: start,
    end: start.add(Duration(minutes: minutes)),
    state: state,
    remaining: state == SlotState.available || state == SlotState.fewLeft
        ? remaining
        : 0,
    capacity: capacity,
  );
}

ScheduleSlot gridSlot(Slot s, {String unitId = 'u1'}) =>
    ScheduleSlot(unitId: unitId, unitName: 'وحدة', slot: s);

FacilitySchedule buildSchedule({
  bool isFree = false,
  bool requiresTrainer = false,
  Map<String, List<Slot>> slots = const {},
  List<String> unitIds = const ['u1'],
  Map<String, UnitSettings>? settingsByUnit,
  Map<String, List<Price>> prices = const {},
  List<ScheduleTrainer> trainers = const [],
  ScheduleTrainer? trainer,
  int fallbackWindowDays = 7,
}) {
  final Facility f = facility(isFree: isFree, requiresTrainer: requiresTrainer);
  final units = <BookableUnit>[for (final id in unitIds) unit(id: id)];
  return ScheduleBuilder.build(
    facility: f,
    units: units,
    settingsByUnit: settingsByUnit ??
        {for (final id in unitIds) id: settings(mode: BookingMode.shared, capacity: 6)},
    fewLeftByUnit: {for (final id in unitIds) id: 2},
    slotsByUnit: slots,
    pricesByUnit: prices,
    fallbackWindowDays: fallbackWindowDays,
    trainers: trainers,
    trainer: trainer,
    now: fixtureNow,
  );
}

const trainerA = ScheduleTrainer(
  id: 't1',
  name: 'مدرب',
  bio: 'نبذة',
  capacity: 3,
  hasSessionsInWindow: true,
);
