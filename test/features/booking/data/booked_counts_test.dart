import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/features/attendance/domain/attendance.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/booking_repository.dart';
import 'package:sprint/features/payments/data/fake_gateway_controller.dart';

import '../../../helpers/data_env.dart';

/// `bookedCounts` feeds the "most booked" suggestions (data-model): only
/// confirmed and attended bookings that have not started yet count, across
/// every user of the facility.
void main() {
  late DataEnv env;
  late FakeGatewayController gateway;

  setUp(() {
    env = DataEnv();
    gateway = env.layer.paymentProvider.gateway;
  });

  T ok<T>(Result<T> r) => (r as Ok<T>).value;

  BookingRequest req(String user, String unit, DateTime start) =>
      BookingRequest(
        userId: user,
        unitId: unit,
        start: start,
        end: start.add(const Duration(hours: 1)),
      );

  Future<Booking> create(String user, String unit, DateTime start) async {
    final r = await env.layer.bookings.create(req(user, unit, start));
    expect(
      r,
      isA<Ok<Booking>>(),
      reason: r is Err<Booking> ? '${r.failure.runtimeType}' : null,
    );
    return (r as Ok<Booking>).value;
  }

  Future<void> pay(Booking b) async {
    final s = ok(await env.layer.bookings.startPayment(b.id, b.userId));
    gateway.confirm(s.id, cardLast4: '4242');
    await Future<void>.delayed(const Duration(milliseconds: 60));
  }

  test('counts confirmed and attended starts since a date, per facility, all '
      'users', () async {
    final since = env.at(-30, 0);
    final before = await env.layer.bookings.bookedCounts(since: since);

    // Confirmed, free, by another user.
    await create(Ids.bookerExternal, Ids.hall2, env.at(2, 10));
    // Confirmed, paid.
    final paid = await create(Ids.bookerInternal, Ids.futsal2, env.at(2, 18));
    await pay(paid);
    // Attended.
    final attended = await create(Ids.bookerExternal, Ids.hall2, env.at(0, 12));
    env.setNow(env.at(0, 11, 50));
    ok(
      await env.layer.bookings.markAttendance(
        attended.id,
        AttendanceMethod.qr,
        Ids.hallManager,
      ),
    );
    // Cancelled.
    final cancelled = await create(
      Ids.bookerExternal,
      Ids.hall2,
      env.at(2, 14),
    );
    ok(await env.layer.bookings.cancel(cancelled.id, Ids.bookerExternal));
    // Pending, then expired.
    final pending = await create(
      Ids.bookerInternal,
      Ids.futsal2,
      env.at(4, 18),
    );
    env.advance(const Duration(minutes: 11));
    expect(await env.layer.bookings.expireHolds(), isPositive);

    final after = await env.layer.bookings.bookedCounts(since: since);
    expect(
      (after[Ids.hallFacility] ?? 0) - (before[Ids.hallFacility] ?? 0),
      2,
      reason: 'one confirmed and one attended in the hall',
    );
    expect(
      (after[Ids.futsalFacility] ?? 0) - (before[Ids.futsalFacility] ?? 0),
      1,
      reason: 'the cancelled and expired football bookings are ignored',
    );
    expect(
      ok(await env.layer.bookings.get(pending.id)).status,
      BookingStatus.expired,
    );
    expect(
      ok(await env.layer.bookings.get(cancelled.id)).status,
      BookingStatus.cancelled,
    );
  });

  test('a later since excludes older starts', () async {
    final since = env.at(3, 0);
    final baseline = await env.layer.bookings.bookedCounts(since: since);

    final b = await create(Ids.bookerExternal, Ids.hall2, env.at(2, 10));
    expect(b.start.isBefore(since), isTrue);

    expect(await env.layer.bookings.bookedCounts(since: since), baseline);
  });
}
