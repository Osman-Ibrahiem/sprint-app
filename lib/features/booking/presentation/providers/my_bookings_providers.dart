import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/cancel_preview.dart';
import 'package:sprint/features/booking/domain/unit_settings.dart';
import 'package:sprint/features/booking/presentation/bookings/booking_row_data.dart';
import 'package:sprint/features/catalogue/domain/bookable_unit.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/domain/trainer.dart';
import 'package:sprint/features/identity/domain/user.dart';
import 'package:sprint/features/payments/domain/payment.dart';
import 'package:sprint/features/payments/domain/refund.dart';

part 'my_bookings_providers.g.dart';

/// The two lists of "حجوزاتي" (US-14).
enum BookingSegment { upcoming, past }

/// The signed-in person's bookings of one [segment]: upcoming is confirmed or
/// holding and not yet ended, soonest first; past is everything else, newest
/// first. Reloads on every booking write and when the session changes.
@riverpod
Future<List<Booking>> myBookings(Ref ref, BookingSegment segment) async {
  final user = ref.watch(currentSessionProvider).user;
  if (user == null) return const [];
  final repo = ref.watch(bookingRepositoryProvider);
  final now = ref.watch(appClockProvider).now();

  final sub = repo.changes.listen((_) => ref.invalidateSelf());
  ref.onDispose(sub.cancel);

  final mine = await repo.listForUser(user.id);
  bool isUpcoming(Booking b) =>
      (b.status == BookingStatus.confirmed ||
          b.status == BookingStatus.pendingPayment) &&
      b.end.isAfter(now);
  final picked = mine
      .where(
        (b) =>
            segment == BookingSegment.upcoming ? isUpcoming(b) : !isUpcoming(b),
      )
      .toList();
  picked.sort(
    (a, b) => segment == BookingSegment.upcoming
        ? a.start.compareTo(b.start)
        : b.start.compareTo(a.start),
  );
  return picked;
}

/// The same lists with the names each row shows: facility, unit and trainer.
@riverpod
Future<List<BookingRowInfo>> myBookingRows(
  Ref ref,
  BookingSegment segment,
) async {
  final list = await ref.watch(myBookingsProvider(segment).future);
  final catalogue = ref.watch(catalogueRepositoryProvider);
  final identity = ref.watch(identityRepositoryProvider);
  final facilities = <String, String>{};
  final units = <String, String>{};
  final trainerNames = <String, String?>{};
  final out = <BookingRowInfo>[];
  for (final b in list) {
    facilities[b.facilityId] ??=
        (await catalogue.getFacility(b.facilityId))?.name ?? '';
    units[b.unitId] ??= (await catalogue.getUnit(b.unitId))?.name ?? '';
    String? trainerName;
    if (b.trainerId != null) {
      if (!trainerNames.containsKey(b.trainerId)) {
        String? name;
        for (final t in await catalogue.trainers(b.facilityId)) {
          if (t.id == b.trainerId) name = (await identity.getUser(t.userId))?.name;
        }
        trainerNames[b.trainerId!] = name;
      }
      trainerName = trainerNames[b.trainerId];
    }
    out.add(BookingRowInfo(
      booking: b,
      facilityName: facilities[b.facilityId]!,
      unitName: units[b.unitId]!,
      trainerName: trainerName,
    ));
  }
  return out;
}

/// Everything the details screen shows about one booking.
class BookingDetails {
  const BookingDetails({
    required this.booking,
    required this.facility,
    required this.unit,
    required this.settings,
    required this.cancelPreview,
    this.latestPayment,
    this.paidAmount = 0,
    this.refundAmount = 0,
    this.trainer,
    this.trainerUser,
  });

  final Booking booking;
  final Facility facility;
  final BookableUnit unit;
  final UnitSettings settings;

  /// What an owner cancel would mean now (for the action and the dialog).
  final CancelPreview cancelPreview;
  final Payment? latestPayment;

  /// The sum of succeeded payments.
  final int paidAmount;

  /// The sum of succeeded refunds.
  final int refundAmount;
  final Trainer? trainer;
  final User? trainerUser;

  bool get hasSucceededPayment => paidAmount > 0;
}

/// The details of one booking of the signed-in person, or null when it does
/// not exist or is somebody else's (FR-009: nothing is revealed). Reloads when
/// bookings, payments or the minute change.
@riverpod
Future<BookingDetails?> bookingDetails(Ref ref, String bookingId) async {
  final user = ref.watch(currentSessionProvider).user;
  if (user == null) return null;
  final bookings = ref.watch(bookingRepositoryProvider);
  final payments = ref.watch(paymentRepositoryProvider);
  final catalogue = ref.watch(catalogueRepositoryProvider);
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  final identity = ref.watch(identityRepositoryProvider);

  final sub = bookings.changes.listen((_) => ref.invalidateSelf());
  ref.onDispose(sub.cancel);

  final got = await bookings.get(bookingId);
  if (got is! Ok<Booking>) return null;
  final b = got.value;
  if (b.userId != user.id) return null;

  final facility = await catalogue.getFacility(b.facilityId);
  final unit = await catalogue.getUnit(b.unitId);
  if (facility == null || unit == null) return null;

  final all = await payments.payments(bookingId);
  var paid = 0;
  var refunded = 0;
  for (final p in all) {
    if (p.status != PaymentStatus.succeeded) continue;
    paid += p.amount;
    for (final r in await payments.refunds(p.id)) {
      if (r.status == RefundStatus.succeeded) refunded += r.amount;
    }
  }

  Trainer? trainer;
  User? trainerUser;
  if (b.trainerId != null) {
    for (final t in await catalogue.trainers(b.facilityId)) {
      if (t.id == b.trainerId) trainer = t;
    }
    if (trainer != null) trainerUser = await identity.getUser(trainer.userId);
  }

  return BookingDetails(
    booking: b,
    facility: facility,
    unit: unit,
    settings: await UnitSettings.resolve(
      settingsRepo,
      unitId: b.unitId,
      facilityId: b.facilityId,
    ),
    cancelPreview: await bookings.previewCancel(bookingId, user.id),
    latestPayment: all.isEmpty ? null : all.last,
    paidAmount: paid,
    refundAmount: refunded,
    trainer: trainer,
    trainerUser: trainerUser,
  );
}
