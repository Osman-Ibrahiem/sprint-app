import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/booking_path.dart';
import 'package:sprint/features/booking/domain/facility_schedule.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';
import 'package:sprint/features/booking/domain/slot.dart';
import 'package:sprint/features/booking/domain/unit_settings.dart';
import 'package:sprint/features/catalogue/domain/bookable_unit.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/catalogue/domain/trainer.dart';
import 'package:sprint/features/identity/domain/identity_repository.dart';
import 'package:sprint/features/settings/domain/setting_registry.dart';

part 'booking_providers.g.dart';

/// The longest single wait for the "slot turns past" timer. A capped timer
/// that fires early just reloads and sets the rest (web `setTimeout` wraps
/// long delays).
const _maxFlipWait = Duration(hours: 12);

/// The schedule of one facility over the whole booking window, loaded in one
/// parallel pass (feature 005 research R4). `null` means missing or
/// unpublished. [trainerId] is the chosen trainer in the trainer path.
///
/// Reloads when a booking is written, when the session changes and when the
/// next slot turns past, so the screen is right without a tap. Auto-dispose:
/// it is rebuilt each time its screen is shown again.
@riverpod
Future<FacilitySchedule?> facilitySchedule(
  Ref ref,
  String facilityId,
  String? trainerId,
) async {
  final catalogue = ref.watch(catalogueRepositoryProvider);
  final availability = ref.watch(availabilityRepositoryProvider);
  final settings = ref.watch(settingsRepositoryProvider);
  final identity = ref.watch(identityRepositoryProvider);
  final bookings = ref.watch(bookingRepositoryProvider);
  final now = ref.watch(appClockProvider).now();
  // The price and tier shown follow the session.
  ref.watch(currentSessionProvider);

  final changes = bookings.changes.listen((_) => ref.invalidateSelf());
  ref.onDispose(changes.cancel);

  final facility = await catalogue.getFacility(facilityId);
  if (facility == null || !facility.isPublished) return null;
  final path = BookingPath.of(facility);

  final units = (await catalogue.listUnits(
    facilityId,
  )).where((u) => u.isActive).toList();

  final settingsByUnit = <String, UnitSettings>{};
  final fewLeftByUnit = <String, int>{};
  await Future.wait([
    for (final u in units)
      () async {
        settingsByUnit[u.id] = await UnitSettings.resolve(
          settings,
          unitId: u.id,
          facilityId: facilityId,
        );
        fewLeftByUnit[u.id] = await settings.resolve(
          SettingKeys.fewLeftThreshold,
          unitId: u.id,
          facilityId: facilityId,
        );
      }(),
  ]);

  final fallbackWindow = await settings.resolve(
    SettingKeys.bookingWindowDays,
    facilityId: facilityId,
  );
  var window = fallbackWindow;
  for (final u in units) {
    final w = settingsByUnit[u.id]!.bookingWindowDays;
    if (w > window) window = w;
  }
  final today = cairoDayOf(now);
  final lastDay = CairoTime.atWallClock(
    today.year,
    today.month,
    today.day + window - 1,
  );

  final pricesByUnit = <String, List<Price>>{};
  await Future.wait([
    for (final u in units)
      () async {
        pricesByUnit[u.id] = await catalogue.prices(u.id);
      }(),
  ]);

  final slotsByUnit = <String, List<Slot>>{};
  var trainers = <ScheduleTrainer>[];
  ScheduleTrainer? chosen;

  if (path == BookingPath.trainer) {
    final records = await catalogue.trainers(facilityId);
    // trainer id -> unit id -> slots.
    final byTrainer = <String, Map<String, List<Slot>>>{};
    await Future.wait([
      for (final t in records)
        () async {
          final perUnit = <String, List<Slot>>{};
          await Future.wait([
            for (final u in units)
              () async {
                perUnit[u.id] = await availability.slots(
                  u.id,
                  now,
                  lastDay,
                  trainerId: t.id,
                );
              }(),
          ]);
          byTrainer[t.id] = perUnit;
        }(),
    ]);
    trainers = [
      for (final t in records)
        await _trainerView(
          t,
          identity: identity,
          hasSessions: (byTrainer[t.id] ?? const {}).values.any(
            (list) => list.any((s) => s.state != SlotState.closed),
          ),
        ),
    ];
    for (final t in trainers) {
      if (t.id == trainerId) chosen = t;
    }
    if (chosen != null) {
      slotsByUnit.addAll(byTrainer[chosen.id] ?? const {});
    }
  } else {
    await Future.wait([
      for (final u in units)
        () async {
          slotsByUnit[u.id] = await availability.slots(u.id, now, lastDay);
        }(),
    ]);
  }

  final schedule = ScheduleBuilder.build(
    facility: facility,
    units: List<BookableUnit>.of(units),
    settingsByUnit: settingsByUnit,
    fewLeftByUnit: fewLeftByUnit,
    slotsByUnit: slotsByUnit,
    pricesByUnit: pricesByUnit,
    fallbackWindowDays: fallbackWindow,
    trainers: trainers,
    trainer: chosen,
    now: now,
  );

  // A slot turns past at its start minus the minimum lead (BR-07).
  var lead = Duration.zero;
  for (final cfg in settingsByUnit.values) {
    final l = Duration(minutes: cfg.minLeadMinutes);
    if (l > lead) lead = l;
  }
  final flip = schedule.nextFlipAfter(now, lead: lead);
  if (flip != null) {
    final wait = flip.difference(now);
    final timer = Timer(
      wait < _maxFlipWait ? wait : _maxFlipWait,
      ref.invalidateSelf,
    );
    ref.onDispose(timer.cancel);
  }
  return schedule;
}

Future<ScheduleTrainer> _trainerView(
  Trainer t, {
  required IdentityRepository identity,
  required bool hasSessions,
}) async {
  final user = await identity.getUser(t.userId);
  return ScheduleTrainer(
    id: t.id,
    name: user?.name,
    bio: t.bio,
    capacity: t.trainerCapacity,
    hasSessionsInWindow: hasSessions,
  );
}

/// The signed-in person's bookings that have not ended, for the tap-time
/// overlap hint (clarify Q2, FR-033). Empty for a guest.
@riverpod
Future<List<Booking>> myUpcomingBookings(Ref ref) async {
  final session = ref.watch(currentSessionProvider);
  final bookings = ref.watch(bookingRepositoryProvider);
  final changes = bookings.changes.listen((_) => ref.invalidateSelf());
  ref.onDispose(changes.cancel);
  final user = session.user;
  if (user == null) return const [];
  return bookings.listForUser(user.id, upcoming: true);
}
