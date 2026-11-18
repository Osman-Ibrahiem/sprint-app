import 'package:sprint/core/seed/seed_bookings.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/features/attendance/domain/attendance.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/qr_token.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/payments/domain/payment.dart';
import 'package:sprint/features/payments/domain/refund.dart';

// Seed additions of feature 007 (data-model "Seed additions"): so every
// details variant, the cancel cases and "most booked" can be shown. All
// fictional and relative to "now".

/// The demo booker's confirmed, paid booking that starts within the
/// cancellation cutoff, so the cancel is already closed (BR-30) and a reminder
/// after the cutoff shows no action (BR-40).
const seedInsideCutoffBookingId = 'bk-y01';

/// The demo booker's own cancel, with its refund (US-13).
const seedOwnerCancelledBookingId = 'bk-y02';

SeedBookingSet seedBooking007(DateTime now) {
  final today = CairoTime.toCairo(now);
  DateTime at(int days, int hour) =>
      CairoTime.atWallClock(today.year, today.month, today.day + days, hour);

  const facilityOfUnit = {
    SeedIds.pool4: SeedIds.poolFacility,
    SeedIds.pool1: SeedIds.poolFacility,
    SeedIds.futsal1: SeedIds.futsalFacility,
    SeedIds.tennis1: SeedIds.tennisFacility,
  };
  const ownerOfFacility = {
    SeedIds.poolFacility: SeedIds.ouPe,
    SeedIds.futsalFacility: SeedIds.ouCentral,
    SeedIds.tennisFacility: SeedIds.ouEng,
  };

  final bookings = <Booking>[];
  final payments = <Payment>[];
  final refunds = <Refund>[];
  final attendance = <Attendance>[];
  var n = 0;

  void add(
    String unit,
    DateTime start,
    DateTime end,
    BookingStatus status,
    int price, {
    String user = SeedIds.bookerInternal,
    CancelledBy? cancelledBy,
  }) {
    n++;
    final id = 'bk-y${n.toString().padLeft(2, '0')}';
    final code = 'SP-${1200 + n}';
    final facility = facilityOfUnit[unit]!;
    bookings.add(
      Booking(
        id: id,
        code: code,
        userId: user,
        facilityId: facility,
        unitId: unit,
        start: start,
        end: end,
        seats: 1,
        tierAtBooking: PriceTier.internal,
        priceAtBooking: price,
        status: status,
        qrToken: qrTokenFor(id, code),
        cancelledBy: cancelledBy,
        cancelledAt: cancelledBy == null
            ? null
            : start.subtract(const Duration(days: 2)),
      ),
    );
    final paidAt = start.subtract(const Duration(days: 1));
    if (price > 0) {
      payments.add(
        Payment(
          id: 'pay-$id',
          bookingId: id,
          provider: 'FAKE',
          providerRef: 'fake-$id',
          amount: price,
          status: PaymentStatus.succeeded,
          startedAt: paidAt,
          paidAt: paidAt,
          cardLast4: '4242',
          receiptNumber: seedReceiptNumber(paidAt, 600 + n),
          owningUnitId: ownerOfFacility[facility]!,
        ),
      );
      if (status == BookingStatus.cancelled) {
        refunds.add(
          Refund(
            id: 'rf-$id',
            paymentId: 'pay-$id',
            amount: price,
            reason: 'إلغاء من الحاجز',
            status: RefundStatus.succeeded,
          ),
        );
      }
    }
    if (status == BookingStatus.attended) {
      attendance.add(
        Attendance(
          bookingId: id,
          status: AttendanceStatus.present,
          method: AttendanceMethod.qr,
          markedBy: SeedIds.hallManager,
          markedAt: start,
        ),
      );
    }
  }

  // bk-y01: starts in an hour, inside any cutoff.
  add(
    SeedIds.tennis1,
    now.add(const Duration(hours: 1)),
    now.add(const Duration(hours: 2)),
    BookingStatus.confirmed,
    55,
  );
  // bk-y02: the booker cancelled it, money back in full.
  add(
    SeedIds.pool4,
    at(-6, 9),
    at(-6, 10),
    BookingStatus.cancelled,
    20,
    cancelledBy: CancelledBy.owner,
  );
  // Attended bookings of the last 30 days across facilities ("most booked").
  add(SeedIds.futsal1, at(-7, 20), at(-7, 21), BookingStatus.attended, 140);
  add(SeedIds.futsal1, at(-9, 19), at(-9, 20), BookingStatus.attended, 140);
  add(SeedIds.tennis1, at(-10, 17), at(-10, 18), BookingStatus.attended, 55);
  add(SeedIds.pool1, at(-12, 9), at(-12, 10), BookingStatus.attended, 20);

  return SeedBookingSet(
    bookings: bookings,
    payments: payments,
    refunds: refunds,
    attendance: attendance,
  );
}
