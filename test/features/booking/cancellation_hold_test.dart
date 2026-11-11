import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/cancellation_policy.dart';
import 'package:sprint/features/booking/domain/hold_policy.dart';

import '../../helpers/domain_builders.dart';

void main() {
  const hold = HoldPolicy();
  const cancel = CancellationPolicy();
  final start = cairo(2026, 11, 14, 18); // slot 6 pm - 7 pm

  group('hold (BR-12)', () {
    final now = cairo(2026, 11, 14, 12);

    test('expiry is holdMinutes after now', () {
      expect(hold.expiryFrom(now, holdMinutes: 10),
          now.add(const Duration(minutes: 10)));
    });

    test('a pending booking expires once its hold elapses', () {
      final b = booking(
        start: start,
        status: BookingStatus.pendingPayment,
        holdExpiresAt: now.add(const Duration(minutes: 10)),
      );
      expect(hold.isExpired(b, now), isFalse);
      expect(hold.isExpired(b, now.add(const Duration(minutes: 9, seconds: 59))),
          isFalse);
      expect(hold.isExpired(b, now.add(const Duration(minutes: 10))), isTrue);
    });

    test('only pending bookings can expire', () {
      final b = booking(start: start, holdExpiresAt: now);
      expect(hold.isExpired(b, now.add(const Duration(hours: 1))), isFalse);
    });

    test('expiring moves PENDING_PAYMENT to EXPIRED', () {
      final b = booking(
        start: start,
        status: BookingStatus.pendingPayment,
        holdExpiresAt: now,
      );
      final r = b.expire();
      expect((r as Ok<Booking>).value.status, BookingStatus.expired);
    });
  });

  group('state machine (BRD §5)', () {
    test('pending -> confirmed on payment', () {
      final b = booking(start: start, status: BookingStatus.pendingPayment);
      expect((b.confirm() as Ok<Booking>).value.status, BookingStatus.confirmed);
      expect((b.confirm() as Ok<Booking>).value.holdExpiresAt, isNull);
    });

    test('every other transition is rejected with a typed error', () {
      const terminal = [
        BookingStatus.expired,
        BookingStatus.cancelled,
        BookingStatus.attended,
        BookingStatus.noShow,
      ];
      for (final s in terminal) {
        final b = booking(start: start, status: s);
        expect((b.confirm() as Err<Booking>).failure, isA<InvalidTransition>());
        expect((b.expire() as Err<Booking>).failure, isA<InvalidTransition>());
        expect(
          (b.attend() as Err<Booking>).failure,
          isA<InvalidTransition>(),
          reason: '$s',
        );
        expect(
          (b.cancel(CancelledBy.admin) as Err<Booking>).failure,
          isA<InvalidTransition>(),
        );
        expect(
          (b.markNoShow(start.add(const Duration(days: 1))) as Err<Booking>)
              .failure,
          isA<InvalidTransition>(),
        );
      }
      final pending = booking(start: start, status: BookingStatus.pendingPayment);
      expect((pending.attend() as Err<Booking>).failure, isA<InvalidTransition>());
      expect((pending.cancel(CancelledBy.owner) as Err<Booking>).failure,
          isA<InvalidTransition>());
      final confirmed = booking(start: start);
      expect((confirmed.confirm() as Err<Booking>).failure,
          isA<InvalidTransition>());
      expect((confirmed.expire() as Err<Booking>).failure,
          isA<InvalidTransition>());
    });

    test('confirmed -> attended', () {
      expect((booking(start: start).attend() as Ok<Booking>).value.status,
          BookingStatus.attended);
    });

    test('confirmed -> no-show only after the slot ends (BR-37)', () {
      final b = booking(start: start);
      expect((b.markNoShow(start) as Err<Booking>).failure,
          isA<InvalidTransition>());
      final r = b.markNoShow(b.end);
      expect((r as Ok<Booking>).value.status, BookingStatus.noShow);
    });

    test('a no-show carries no penalty: it changes only the status', () {
      final b = booking(start: start, price: 120);
      final after = (b.markNoShow(b.end) as Ok<Booking>).value;
      expect(after.copyWith(status: BookingStatus.confirmed), b);
    });
  });

  group('cancellation and refund (BR-30 – BR-32)', () {
    final b = booking(start: start, price: 200);
    final cutoff2h = settings(cancellationCutoffHours: 2, refundPercent: 100);

    CancellationDecision decide(
      DateTime now, {
      CancelledBy by = CancelledBy.owner,
      int refundPercent = 100,
      int cutoff = 2,
      Booking? booking_,
    }) {
      final r = cancel.decide(
        booking: booking_ ?? b,
        now: now,
        by: by,
        cutoffHours: cutoff,
        refundPercent: refundPercent,
        paidAmount: 200,
      );
      return (r as Ok<CancellationDecision>).value;
    }

    Failure? refused(DateTime now,
        {CancelledBy by = CancelledBy.owner, Booking? booking_}) {
      final r = cancel.decide(
        booking: booking_ ?? b,
        now: now,
        by: by,
        cutoffHours: cutoff2h.cancellationCutoffHours,
        refundPercent: cutoff2h.refundPercent,
        paidAmount: 200,
      );
      return r is Err<CancellationDecision> ? r.failure : null;
    }

    test('before the cutoff the owner gets refundPercent of the amount', () {
      final now = start.subtract(const Duration(hours: 3));
      expect(decide(now).refundAmount, 200);
      expect(decide(now, refundPercent: 50).refundAmount, 100);
      expect(decide(now, refundPercent: 0).refundAmount, 0);
    });

    test('exactly at the cutoff is still allowed', () {
      expect(
        decide(start.subtract(const Duration(hours: 2))).refundAmount,
        200,
      );
    });

    test('after the cutoff the owner cannot cancel', () {
      expect(refused(start.subtract(const Duration(hours: 1, minutes: 59))),
          isA<CancellationClosed>());
      expect(refused(start.add(const Duration(minutes: 5))),
          isA<CancellationClosed>());
    });

    test('a different cutoff setting moves the line', () {
      final now = start.subtract(const Duration(hours: 3));
      final r = cancel.decide(
        booking: b,
        now: now,
        by: CancelledBy.owner,
        cutoffHours: 4,
        refundPercent: 100,
        paidAmount: 200,
      );
      expect((r as Err<CancellationDecision>).failure, isA<CancellationClosed>());
    });

    test('an admin cancel always refunds 100%, whatever the settings', () {
      final late = start.subtract(const Duration(minutes: 10));
      expect(decide(late, by: CancelledBy.admin, refundPercent: 50).refundAmount,
          200);
      expect(decide(late, by: CancelledBy.admin, refundPercent: 0).refundAmount,
          200);
    });

    test('an admin cannot cancel after the slot has ended', () {
      expect(refused(b.end, by: CancelledBy.admin), isA<InvalidTransition>());
    });

    test('only a confirmed booking can be cancelled', () {
      final now = start.subtract(const Duration(hours: 5));
      for (final s in [
        BookingStatus.pendingPayment,
        BookingStatus.attended,
        BookingStatus.noShow,
        BookingStatus.expired,
        BookingStatus.cancelled,
      ]) {
        expect(
          refused(now, booking_: booking(start: start, status: s)),
          isA<InvalidTransition>(),
          reason: '$s',
        );
      }
    });

    test('a free booking refunds nothing', () {
      final r = cancel.decide(
        booking: booking(start: start, price: 0),
        now: start.subtract(const Duration(hours: 5)),
        by: CancelledBy.owner,
        cutoffHours: 2,
        refundPercent: 100,
        paidAmount: 0,
      );
      expect((r as Ok<CancellationDecision>).value.refundAmount, 0);
    });
  });

  group('reminder cancel button (BR-40)', () {
    test('offered only while still before the cutoff', () {
      final b = booking(start: start);
      // Cutoff 2 h, so the line is at 16:00.
      expect(
        cancel.canOfferCancel(b, cairo(2026, 11, 14, 15, 59), cutoffHours: 2),
        isTrue,
      );
      expect(
        cancel.canOfferCancel(b, cairo(2026, 11, 14, 16, 1), cutoffHours: 2),
        isFalse,
      );
    });

    test('BRD defaults: a 60-minute reminder falls after a 2-hour cutoff, so '
        'it never offers cancel (open BRD §11 item, kept as written)', () {
      final d = settings();
      final b = booking(start: start);
      final reminderAt = b.start.subtract(Duration(minutes: d.reminderLeadMinutes));
      expect(
        cancel.canOfferCancel(b, reminderAt, cutoffHours: d.cancellationCutoffHours),
        isFalse,
      );
    });
  });
}
