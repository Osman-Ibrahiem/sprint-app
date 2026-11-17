import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/booking_path.dart';
import 'package:sprint/features/booking/domain/booking_quote.dart';
import 'package:sprint/features/booking/domain/booking_summary_view.dart';
import 'package:sprint/features/booking/domain/facility_schedule.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';
import 'package:sprint/features/booking/domain/slot.dart';
import 'package:sprint/features/booking/domain/unit_settings.dart';
import 'package:sprint/features/catalogue/domain/bookable_unit.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/catalogue/domain/trainer.dart';
import 'package:sprint/features/identity/domain/identity_repository.dart';
import 'package:sprint/features/identity/domain/verification.dart';
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

/// The checked quote and names for the summary (FR-024 – FR-028). Re-runs when
/// the session changes, so a verification that was just approved shows the new
/// price and says so (FR-026). The repository's answer is binding; a refusal
/// comes back as `Err` for the screen to explain.
@riverpod
Future<Result<BookingSummaryView>> bookingSummary(
  Ref ref,
  String facilityId,
  ScheduleSelection selection,
  int? shown,
) async {
  final session = ref.watch(currentSessionProvider);
  final bookings = ref.watch(bookingRepositoryProvider);
  final catalogue = ref.watch(catalogueRepositoryProvider);
  final identity = ref.watch(identityRepositoryProvider);

  final user = session.user;
  if (user == null) return const Err(NotPermitted());
  final request = selection.toRequest(user.id);
  if (request == null) return const Err(NotFound('unit'));

  final quoted = await bookings.quote(request);
  if (quoted is Err<BookingQuote>) return Err(quoted.failure);
  final quote = (quoted as Ok<BookingQuote>).value;

  final facility = await catalogue.getFacility(quote.facilityId);
  final unit = await catalogue.getUnit(quote.unitId);
  String? trainerName;
  if (quote.trainerId != null) {
    for (final t in await catalogue.trainers(quote.facilityId)) {
      if (t.id == quote.trainerId) {
        trainerName = (await identity.getUser(t.userId))?.name;
      }
    }
  }

  final pending = session.verification?.status == VerificationStatus.pending;
  final hint = pending
      ? VerificationHint.underReview
      : quote.tier == PriceTier.external
      ? VerificationHint.canVerify
      : VerificationHint.none;

  return Ok(
    BookingSummaryView.from(
      quote: quote,
      facilityName: facility?.name ?? '',
      unitName: unit?.name ?? '',
      trainerName: trainerName,
      verificationHint: hint,
      shown: shown,
    ),
  );
}

/// A confirmed booking with the names the success screen shows.
class BookingDoneView {
  const BookingDoneView({
    required this.booking,
    required this.facilityName,
    required this.unitName,
  });

  final Booking booking;
  final String facilityName;
  final String unitName;
}

/// The booking behind the success screen, or null when it is missing or not
/// the signed-in person's (FR-030). Never shows someone else's booking.
@riverpod
Future<BookingDoneView?> bookingDone(Ref ref, String bookingId) async {
  final session = ref.watch(currentSessionProvider);
  final bookings = ref.watch(bookingRepositoryProvider);
  final catalogue = ref.watch(catalogueRepositoryProvider);
  final user = session.user;
  if (user == null) return null;
  final result = await bookings.get(bookingId);
  if (result is! Ok<Booking> || result.value.userId != user.id) return null;
  final booking = result.value;
  return BookingDoneView(
    booking: booking,
    facilityName: (await catalogue.getFacility(booking.facilityId))?.name ?? '',
    unitName: (await catalogue.getUnit(booking.unitId))?.name ?? '',
  );
}
