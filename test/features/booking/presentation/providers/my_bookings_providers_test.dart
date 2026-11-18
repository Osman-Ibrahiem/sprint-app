import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/data/in_memory_data_layer.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/cancel_preview.dart';
import 'package:sprint/features/booking/presentation/providers/my_bookings_providers.dart';

/// T029: the two lists and the details provider (US-14, FR-009).
void main() {
  CairoTime.ensureInitialized();
  final now = CairoTime.atWallClock(2026, 11, 14, 8);
  late InMemoryDataLayer layer;
  late ProviderContainer c;

  setUp(() async {
    layer = InMemoryDataLayer.create(
      clock: Clock(() => now),
      paymentDelay: Duration.zero,
    );
    c = ProviderContainer(
      overrides: [
        dataLayerProvider.overrideWithValue(layer),
        appClockProvider.overrideWithValue(Clock(() => now)),
      ],
    );
    addTearDown(c.dispose);
    await c.read(sessionProvider.notifier).actAs(SeedIds.bookerInternal);
  });

  test('upcoming: confirmed or holding, not ended, soonest first', () async {
    final list = await c.read(
      myBookingsProvider(BookingSegment.upcoming).future,
    );
    expect(list, isNotEmpty);
    for (final b in list) {
      expect(b.userId, SeedIds.bookerInternal);
      expect(
        b.status == BookingStatus.confirmed ||
            b.status == BookingStatus.pendingPayment,
        isTrue,
      );
      expect(b.end.isAfter(now), isTrue);
    }
    final starts = list.map((b) => b.start).toList();
    expect([...starts]..sort(), starts);
  });

  test('past: everything else, newest first', () async {
    final list = await c.read(myBookingsProvider(BookingSegment.past).future);
    expect(list, isNotEmpty);
    final statuses = list.map((b) => b.status).toSet();
    expect(
      statuses,
      containsAll([BookingStatus.attended, BookingStatus.cancelled]),
    );
    final starts = list.map((b) => b.start).toList();
    expect([...starts]..sort((a, b) => b.compareTo(a)), starts);
  });

  test('a guest has no bookings', () async {
    await c.read(sessionProvider.notifier).signOut();
    expect(
      await c.read(myBookingsProvider(BookingSegment.upcoming).future),
      isEmpty,
    );
  });

  test('the lists reload when a booking is cancelled', () async {
    final before = await c.read(
      myBookingsProvider(BookingSegment.upcoming).future,
    );
    final target = before.firstWhere((b) => b.id == 'bk-09');
    c.listen(myBookingsProvider(BookingSegment.upcoming), (_, _) {});
    final r = await layer.bookings.cancel(target.id, SeedIds.bookerInternal);
    expect(r, isA<Ok<Booking>>(), reason: '$r');
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final after = await c.read(
      myBookingsProvider(BookingSegment.upcoming).future,
    );
    expect(after.any((b) => b.id == target.id), isFalse);
  });

  test(
    'details: facility, unit, payment, settings and the cancel preview',
    () async {
      final upcoming = await c.read(
        myBookingsProvider(BookingSegment.upcoming).future,
      );
      final paid = upcoming.firstWhere(
        (b) => b.status == BookingStatus.confirmed && b.priceAtBooking > 0,
      );
      final d = (await c.read(bookingDetailsProvider(paid.id).future))!;
      expect(d.booking.id, paid.id);
      expect(d.facility.id, paid.facilityId);
      expect(d.paidAmount, paid.priceAtBooking);
      expect(d.latestPayment, isNotNull);
      expect(d.cancelPreview.kind, isNot(CancelKind.notAllowed));
      expect(d.settings.cancellationCutoffHours, greaterThan(0));
    },
  );

  test("details: someone else's or an unknown booking is null", () async {
    final other = layer.bookings.allBookings.firstWhere(
      (b) => b.userId == SeedIds.bookerExternal,
    );
    expect(await c.read(bookingDetailsProvider(other.id).future), isNull);
    expect(await c.read(bookingDetailsProvider('nope').future), isNull);
  });

  test('details: a refunded cancel carries the refund amount', () async {
    final y = layer.bookings.allBookings.firstWhere((b) => b.id == 'bk-y02');
    final d = (await c.read(bookingDetailsProvider(y.id).future))!;
    expect(d.refundAmount, y.priceAtBooking);
    expect(d.booking.cancelledBy, CancelledBy.owner);
  });
}
