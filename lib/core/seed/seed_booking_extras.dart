import 'package:sprint/core/seed/seed_bookings.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/qr_token.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/payments/domain/payment.dart';

// Booking-only extras the Foundation's seed lacks, so every state of the
// schedule can be shown (feature 005 research R12, FR-037). Placeholders until
// Dr. Sara's real data arrives; all fictional and relative to "now".

/// Trainer 1 gives sessions in room 1 on these weekdays (see `seed_users.dart`).
const _trainer1Days = {6, 7, 1, 2, 3};

/// How many days from today the "trainer at capacity" session is: the first
/// coming day trainer 1 works. Tests and the quickstart read it from here.
int seedTrainerFullDayOffset(DateTime now) {
  final today = CairoTime.toCairo(now);
  for (var offset = 1; offset <= 7; offset++) {
    final day = DateTime(today.year, today.month, today.day + offset);
    if (_trainer1Days.contains(day.weekday)) return offset;
  }
  return 1;
}

/// The hour (Cairo) of the full trainer session and of the few-left lane slot.
const seedTrainerFullHour = 11;
const seedFewLeftDayOffset = 2;
const seedFewLeftHour = 12;

/// * Lane 2 (capacity 3) on day +2 at 12:00 has two bookings: one place left,
///   so the slot shows as few-left (BR-45).
/// * Trainer 1 (capacity 3) has three bookings for one session in room 1
///   (capacity 6): the session is full while the room has places (BR-09).
SeedBookingSet seedBookingExtras(DateTime now) {
  final today = CairoTime.toCairo(now);
  DateTime at(int days, int hour) =>
      CairoTime.atWallClock(today.year, today.month, today.day + days, hour);

  final bookings = <Booking>[];
  final payments = <Payment>[];
  var n = 0;

  void add({
    required String user,
    required String unit,
    required String facility,
    required int days,
    required int hour,
    required int price,
    String? trainerId,
  }) {
    n++;
    final id = 'bk-x${n.toString().padLeft(2, '0')}';
    final code = 'SP-${1100 + n}';
    final start = at(days, hour);
    bookings.add(Booking(
      id: id,
      code: code,
      userId: user,
      facilityId: facility,
      unitId: unit,
      trainerId: trainerId,
      start: start,
      end: at(days, hour + 1),
      seats: 1,
      tierAtBooking: PriceTier.external,
      priceAtBooking: price,
      status: BookingStatus.confirmed,
      qrToken: qrTokenFor(id, code),
    ));
    payments.add(Payment(
      id: 'pay-$id',
      bookingId: id,
      provider: 'FAKE',
      providerRef: 'fake-$id',
      amount: price,
      status: PaymentStatus.succeeded,
      startedAt: now.subtract(const Duration(days: 1)),
      paidAt: now.subtract(const Duration(days: 1)),
      cardLast4: '4242',
      owningUnitId: SeedIds.ouPe,
    ));
  }

  for (final user in [SeedIds.userEngPending, SeedIds.userRejected]) {
    add(
      user: user,
      unit: SeedIds.pool2,
      facility: SeedIds.poolFacility,
      days: seedFewLeftDayOffset,
      hour: seedFewLeftHour,
      price: 40,
    );
  }

  final trainerDay = seedTrainerFullDayOffset(now);
  for (final user in [
    SeedIds.userEngPending,
    SeedIds.userRejected,
    SeedIds.userUnverified,
  ]) {
    add(
      user: user,
      unit: SeedIds.room1,
      facility: SeedIds.academyFacility,
      days: trainerDay,
      hour: seedTrainerFullHour,
      price: 100,
      trainerId: SeedIds.trainerRecord1,
    );
  }

  return SeedBookingSet(
    bookings: bookings,
    payments: payments,
    refunds: const [],
    attendance: const [],
  );
}
