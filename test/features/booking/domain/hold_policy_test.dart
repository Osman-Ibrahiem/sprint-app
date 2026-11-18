import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/hold_policy.dart';

import '../../../helpers/domain_builders.dart';

/// BR-12 and BR-46, pure.
void main() {
  const policy = HoldPolicy();
  final now = cairo(2026, 11, 18, 10);
  final start = cairo(2026, 11, 20, 17);

  Booking pending({
    required DateTime expires,
    DateTime? max,
    DateTime? extendedAt,
    BookingStatus status = BookingStatus.pendingPayment,
  }) => booking(
    start: start,
    status: status,
    holdStartedAt: now,
    holdExpiresAt: expires,
    holdMaxExpiresAt: max ?? expires,
  ).copyWith(holdExtendedAt: extendedAt);

  group('creation', () {
    test('expiry is now + holdMinutes, capped at the start', () {
      expect(
        policy.expiryFrom(now, holdMinutes: 10, start: start),
        now.add(const Duration(minutes: 10)),
      );
      final soon = now.add(const Duration(minutes: 4));
      expect(policy.expiryFrom(now, holdMinutes: 10, start: soon), soon);
    });

    test('maximum is now + holdMaxMinutes, capped at the start', () {
      expect(
        policy.maxExpiryFrom(
          now,
          holdMinutes: 10,
          holdMaxMinutes: 20,
          start: start,
        ),
        now.add(const Duration(minutes: 20)),
      );
      final soon = now.add(const Duration(minutes: 15));
      expect(
        policy.maxExpiryFrom(
          now,
          holdMinutes: 10,
          holdMaxMinutes: 20,
          start: soon,
        ),
        soon,
      );
    });

    test('holdMaxMinutes below holdMinutes gives no extension', () {
      expect(
        policy.maxExpiryFrom(
          now,
          holdMinutes: 10,
          holdMaxMinutes: 5,
          start: start,
        ),
        now.add(const Duration(minutes: 10)),
      );
    });
  });

  group('nextExpiry', () {
    final expires = now.add(const Duration(minutes: 10));
    final max = now.add(const Duration(minutes: 20));
    final b = pending(expires: expires, max: max);

    test('unchanged before the expiry', () {
      final d = policy.nextExpiry(
        b,
        expires.subtract(const Duration(seconds: 1)),
        hasPendingPayment: true,
      );
      expect(d, isA<HoldKeep>());
    });

    test('extends to the maximum at expiry with a pending payment', () {
      final d = policy.nextExpiry(b, expires, hasPendingPayment: true);
      expect(d, isA<HoldExtend>());
      expect((d as HoldExtend).to, max);
    });

    test('expires at expiry with no pending payment', () {
      expect(
        policy.nextExpiry(b, expires, hasPendingPayment: false),
        isA<HoldExpire>(),
      );
    });

    test('expires at or after the maximum even with a pending payment', () {
      final extended = pending(expires: max, max: max, extendedAt: expires);
      expect(
        policy.nextExpiry(extended, max, hasPendingPayment: true),
        isA<HoldExpire>(),
      );
      expect(
        policy.nextExpiry(
          b,
          max.add(const Duration(minutes: 1)),
          hasPendingPayment: true,
        ),
        isA<HoldExpire>(),
      );
    });

    test('no extension when the maximum equals the normal expiry', () {
      final flat = pending(expires: expires);
      expect(
        policy.nextExpiry(flat, expires, hasPendingPayment: true),
        isA<HoldExpire>(),
      );
    });

    test('a booking that is not pending is left alone', () {
      final done = pending(
        expires: expires,
        max: max,
        status: BookingStatus.confirmed,
      );
      expect(
        policy.nextExpiry(done, max, hasPendingPayment: true),
        isA<HoldKeep>(),
      );
    });
  });

  group('expiresOnAnswer (a failed or cancelled answer)', () {
    final expires = now.add(const Duration(minutes: 10));
    final max = now.add(const Duration(minutes: 20));

    test('false for a Hold that was never extended', () {
      final b = pending(expires: expires, max: max);
      expect(
        policy.expiresOnAnswer(b, expires.subtract(const Duration(seconds: 1))),
        isFalse,
      );
      final flat = pending(expires: expires);
      expect(policy.expiresOnAnswer(flat, now), isFalse);
    });

    test('true once extended, from the normal expiry on', () {
      final b = pending(expires: max, max: max, extendedAt: expires);
      expect(policy.expiresOnAnswer(b, expires), isTrue);
      expect(
        policy.expiresOnAnswer(b, max.subtract(const Duration(seconds: 1))),
        isTrue,
      );
    });
  });

  group('Booking.extendHoldTo', () {
    final expires = now.add(const Duration(minutes: 10));
    final max = now.add(const Duration(minutes: 20));

    test('moves the expiry once, up to the maximum', () {
      final b = pending(expires: expires, max: max);
      final r = b.extendHoldTo(max);
      expect(r, isA<Ok<Booking>>());
      final next = (r as Ok<Booking>).value;
      expect(next.holdExpiresAt, max);
      expect(next.holdExtendedAt, expires);
    });

    test('refuses beyond the maximum and when not pending', () {
      final b = pending(expires: expires, max: max);
      expect(
        b.extendHoldTo(max.add(const Duration(seconds: 1))),
        isA<Err<Booking>>(),
      );
      final done = pending(
        expires: expires,
        max: max,
        status: BookingStatus.confirmed,
      );
      expect(done.extendHoldTo(max), isA<Err<Booking>>());
    });
  });
}
