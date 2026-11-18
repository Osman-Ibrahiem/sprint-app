import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/data/in_memory_data_layer.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/features/attendance/domain/attendance.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/booking_repository.dart';
import 'package:sprint/features/booking/presentation/providers/checkout_providers.dart';

/// BR-37 through the keepAlive housekeeping timer: a confirmed booking past
/// its end becomes a no-show with an automatic Attendance row, and an attended
/// one is untouched.
void main() {
  CairoTime.ensureInitialized();

  test('the timer marks a finished confirmed booking as a no-show', () {
    fakeAsync((async) {
      var now = CairoTime.atWallClock(2026, 11, 14, 8);
      final layer = InMemoryDataLayer.create(
        clock: Clock(() => now),
        paymentDelay: Duration.zero,
      );
      final c = ProviderContainer(
        overrides: [
          dataLayerProvider.overrideWithValue(layer),
          appClockProvider.overrideWithValue(Clock(() => now)),
        ],
      );
      addTearDown(c.dispose);

      late Booking attended;
      c.read(sessionProvider.notifier).actAs(SeedIds.bookerInternal);
      async.elapse(Duration.zero);

      // Created inside the fake zone so every repository future completes
      // with fake microtasks.
      final start = CairoTime.atWallClock(2026, 11, 14, 12);
      Booking? created;
      layer.bookings
          .create(
            BookingRequest(
              userId: SeedIds.bookerInternal,
              unitId: SeedIds.hall2,
              start: start,
              end: start.add(const Duration(hours: 1)),
            ),
          )
          .then((r) => created = (r as Ok<Booking>).value);
      async.elapse(Duration.zero);
      final b = created!;
      expect(b.status, BookingStatus.confirmed);

      attended = layer.bookings.allBookings.firstWhere(
        (x) =>
            x.userId == SeedIds.bookerInternal &&
            x.status == BookingStatus.attended,
      );

      expect(c.read(holdHousekeepingProvider), isTrue);
      async.elapse(Duration.zero);

      // The clock reaches the end; the arm timer was set for it.
      now = CairoTime.atWallClock(2026, 11, 14, 13);
      async.elapse(const Duration(hours: 5, seconds: 1));
      async.elapse(Duration.zero);

      Booking? after;
      layer.bookings.get(b.id).then((r) => after = (r as Ok<Booking>).value);
      Attendance? row;
      layer.attendance.forBooking(b.id).then((r) => row = r);
      Booking? attendedAfter;
      layer.bookings
          .get(attended.id)
          .then((r) => attendedAfter = (r as Ok<Booking>).value);
      async.elapse(Duration.zero);

      expect(after!.status, BookingStatus.noShow);
      expect(after!.priceAtBooking, 0);
      expect(after!.tierAtBooking, b.tierAtBooking);

      expect(row, isNotNull);
      expect(row!.status, AttendanceStatus.noShow);
      expect(row!.method, AttendanceMethod.auto);
      expect(row!.markedBy, 'system');

      expect(attendedAfter!.status, BookingStatus.attended);
    });
  });
}
