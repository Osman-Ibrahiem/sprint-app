import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/notifications/domain/notification_kind.dart';

import '../../helpers/data_env.dart';

/// Feature 007 seed (T028): every cancel case, every final status and every
/// notification kind exists for the demo booker, and "most booked" is no tie.
void main() {
  final env = DataEnv();
  final layer = env.layer;
  List<Booking> mine() => layer.bookings.allBookings
      .where((b) => b.userId == Ids.bookerInternal)
      .toList();

  test(
    'confirmed bookings: far (cancellable), inside the cutoff, paid, free',
    () async {
      final confirmed = mine().where(
        (b) => b.status == BookingStatus.confirmed,
      );
      expect(
        confirmed.where((b) => b.start.difference(env.now).inHours > 24),
        isNotEmpty,
      );
      expect(
        confirmed.where((b) => b.start.difference(env.now).inHours < 2),
        isNotEmpty,
      );
      expect(confirmed.where((b) => b.priceAtBooking > 0), isNotEmpty);
      expect(confirmed.where((b) => b.priceAtBooking == 0), isNotEmpty);
    },
  );

  test('past bookings exist in each final status', () {
    final statuses = mine().map((b) => b.status).toSet();
    for (final s in [
      BookingStatus.attended,
      BookingStatus.noShow,
      BookingStatus.cancelled,
      BookingStatus.expired,
    ]) {
      expect(statuses, contains(s));
    }
    final by = mine().map((b) => b.cancelledBy).toSet();
    expect(by, containsAll([CancelledBy.owner, CancelledBy.admin]));
  });

  test('"most booked" is not a tie', () async {
    final counts = await layer.bookings.bookedCounts(
      since: env.now.subtract(const Duration(days: 30)),
      until: env.now,
    );
    final sorted = counts.values.toList()..sort((a, b) => b.compareTo(a));
    expect(sorted.length, greaterThanOrEqualTo(4));
    expect(sorted[0], greaterThan(sorted[1]));
    expect(sorted[1], greaterThan(sorted[2]));
  });

  test(
    'notifications of every kind, some unread, some read on arrival',
    () async {
      final all = await layer.notifications.list(Ids.bookerInternal);
      all.addAll(await layer.notifications.list(Ids.userRejected));
      final kinds = all.map((n) => n.kind).toSet();
      for (final k in NotificationKind.values.where(
        (k) => k != NotificationKind.unknown,
      )) {
        if (k == NotificationKind.verificationPending) continue; // another user
        expect(kinds, contains(k), reason: '$k');
      }
      expect(all.where((n) => n.readAt == null), isNotEmpty);
      final own = all.firstWhere(
        (n) => n.kind == NotificationKind.bookingCancelledByOwner,
      );
      expect(own.readAt, own.sentAt);
      expect(
        all.any(
          (n) =>
              n.kind == NotificationKind.paymentRefundedAuto &&
              n.readAt == null,
        ),
        isTrue,
      );
    },
  );
}
