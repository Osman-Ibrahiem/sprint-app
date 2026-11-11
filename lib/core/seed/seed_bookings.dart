import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/features/attendance/domain/attendance.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/qr_token.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/payments/domain/payment.dart';
import 'package:sprint/features/payments/domain/refund.dart';

/// Bookings, with their payments, refunds and attendance, covering every status
/// in BRD §5, in the past and the future. Everything is relative to [now].
class SeedBookingSet {
  const SeedBookingSet({
    required this.bookings,
    required this.payments,
    required this.refunds,
    required this.attendance,
  });

  final List<Booking> bookings;
  final List<Payment> payments;
  final List<Refund> refunds;
  final List<Attendance> attendance;
}

SeedBookingSet seedBookings(DateTime now) {
  final today = CairoTime.toCairo(now);
  DateTime at(int days, int hour) =>
      CairoTime.atWallClock(today.year, today.month, today.day + days, hour);

  const facilityOfUnit = {
    SeedIds.pool1: SeedIds.poolFacility,
    SeedIds.pool2: SeedIds.poolFacility,
    SeedIds.pool4: SeedIds.poolFacility,
    SeedIds.pool3: SeedIds.poolFacility,
    SeedIds.futsal1: SeedIds.futsalFacility,
    SeedIds.gym1: SeedIds.gymFacility,
    SeedIds.tennis1: SeedIds.tennisFacility,
    SeedIds.hall1: SeedIds.hallFacility,
    SeedIds.room1: SeedIds.academyFacility,
  };
  const ownerOfFacility = {
    SeedIds.poolFacility: SeedIds.ouPe,
    SeedIds.futsalFacility: SeedIds.ouCentral,
    SeedIds.gymFacility: SeedIds.ouPe,
    SeedIds.tennisFacility: SeedIds.ouEng,
    SeedIds.hallFacility: SeedIds.ouCentral,
    SeedIds.academyFacility: SeedIds.ouPe,
  };

  final bookings = <Booking>[];
  final payments = <Payment>[];
  final refunds = <Refund>[];
  final attendance = <Attendance>[];
  var n = 0;

  void add(
    String user,
    String unit,
    int days,
    int hour,
    BookingStatus status,
    PriceTier tier,
    int price, {
    int hours = 1,
    String? trainerId,
    DateTime? holdExpiresAt,
    CancelledBy? cancelledBy,
    String? cancelReason,
    bool paid = true,
  }) {
    n++;
    final id = 'bk-${n.toString().padLeft(2, '0')}';
    final code = 'SP-${1000 + n}';
    final facility = facilityOfUnit[unit]!;
    final start = at(days, hour);
    bookings.add(Booking(
      id: id,
      code: code,
      userId: user,
      facilityId: facility,
      unitId: unit,
      trainerId: trainerId,
      start: start,
      end: at(days, hour + hours),
      seats: 1,
      tierAtBooking: tier,
      priceAtBooking: price,
      status: status,
      qrToken: qrTokenFor(id, code),
      holdExpiresAt: holdExpiresAt,
      cancelledBy: cancelledBy,
      cancelReason: cancelReason,
    ));

    final paidStatuses = {
      BookingStatus.confirmed,
      BookingStatus.attended,
      BookingStatus.noShow,
      BookingStatus.cancelled,
    };
    if (price > 0 && paid && paidStatuses.contains(status)) {
      final payId = 'pay-$id';
      payments.add(Payment(
        id: payId,
        bookingId: id,
        provider: 'FAKE',
        providerRef: 'fake-$id',
        amount: price,
        status: PaymentStatus.succeeded,
        paidAt: start.subtract(const Duration(days: 1)),
        owningUnitId: ownerOfFacility[facility]!,
      ));
      if (status == BookingStatus.cancelled) {
        refunds.add(Refund(
          id: 'rf-$id',
          paymentId: payId,
          amount: price,
          reason: cancelReason ?? 'إلغاء من الحاجز',
          status: RefundStatus.succeeded,
        ));
      }
    }
    if (status == BookingStatus.attended) {
      attendance.add(Attendance(
        bookingId: id,
        status: AttendanceStatus.present,
        method: AttendanceMethod.qr,
        markedBy: SeedIds.hallManager,
        markedAt: start,
      ));
    } else if (status == BookingStatus.noShow) {
      attendance.add(Attendance(
        bookingId: id,
        status: AttendanceStatus.noShow,
        method: AttendanceMethod.auto,
        markedBy: 'system',
        markedAt: at(days, hour + hours),
      ));
    }
  }

  const tInt = PriceTier.internal;
  const tExt = PriceTier.external;
  const bi = SeedIds.bookerInternal;
  const be = SeedIds.bookerExternal;

  // Past.
  add(bi, SeedIds.gym1, -3, 18, BookingStatus.attended, tInt, 25);
  add(be, SeedIds.pool1, -2, 9, BookingStatus.attended, tExt, 40);
  add(bi, SeedIds.tennis1, -2, 17, BookingStatus.noShow, tInt, 55);
  add(be, SeedIds.futsal1, -1, 20, BookingStatus.cancelled, tExt, 300,
      cancelledBy: CancelledBy.owner);
  add(SeedIds.userUnverified, SeedIds.pool3, -1, 12, BookingStatus.expired, tExt, 40);
  add(SeedIds.userExpired, SeedIds.hall1, -4, 10, BookingStatus.attended, tExt, 0, hours: 2);
  add(be, SeedIds.gym1, -5, 8, BookingStatus.noShow, tExt, 60);
  add(bi, SeedIds.pool4, -3, 13, BookingStatus.expired, tInt, 20);

  // Future.
  add(bi, SeedIds.pool1, 3, 18, BookingStatus.confirmed, tInt, 20);
  add(be, SeedIds.futsal1, 3, 19, BookingStatus.confirmed, tExt, 300);
  add(SeedIds.userUnverified, SeedIds.tennis1, 3, 17, BookingStatus.pendingPayment, tExt, 120,
      holdExpiresAt: now.add(const Duration(minutes: 8)));
  add(SeedIds.userExpired, SeedIds.hall1, 4, 10, BookingStatus.confirmed, tExt, 0, hours: 2);
  add(bi, SeedIds.gym1, 4, 8, BookingStatus.confirmed, tInt, 25);
  add(be, SeedIds.room1, 4, 10, BookingStatus.confirmed, tExt, 100,
      trainerId: SeedIds.trainerRecord1);
  add(bi, SeedIds.futsal1, 2, 15, BookingStatus.cancelled, tInt, 140,
      cancelledBy: CancelledBy.admin, cancelReason: 'إغلاق طارئ');
  add(SeedIds.userUnverified, SeedIds.gym1, 5, 9, BookingStatus.confirmed, tExt, 60);

  // Lane 2 holds three places and three people booked it: this slot is full.
  add(bi, SeedIds.pool2, 3, 10, BookingStatus.confirmed, tInt, 20);
  add(be, SeedIds.pool2, 3, 10, BookingStatus.confirmed, tExt, 40);
  add(SeedIds.userExpired, SeedIds.pool2, 3, 10, BookingStatus.confirmed, tExt, 40);

  return SeedBookingSet(
    bookings: bookings,
    payments: payments,
    refunds: refunds,
    attendance: attendance,
  );
}
