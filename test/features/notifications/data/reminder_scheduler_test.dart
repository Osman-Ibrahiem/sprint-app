import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/widgets.dart' show AppLifecycleState;
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/data/in_memory_data_layer.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/booking_repository.dart';
import 'package:sprint/features/notifications/data/reminder_scheduler.dart';
import 'package:sprint/features/notifications/domain/notification.dart';
import 'package:sprint/features/notifications/domain/notification_kind.dart';

import '../../../helpers/data_env.dart';

/// BR-39: the scheduler ticks every 60 seconds and on app resume, and writes
/// one deterministic record per booking.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  var now = CairoTime.atWallClock(2026, 11, 14, 8);
  late InMemoryDataLayer layer;

  setUp(() {
    now = CairoTime.atWallClock(2026, 11, 14, 8);
    layer = InMemoryDataLayer.create(
      clock: Clock(() => now),
      paymentDelay: Duration.zero,
    );
  });

  Future<Booking> create(DateTime start) async {
    final r = await layer.bookings.create(BookingRequest(
      userId: Ids.bookerInternal,
      unitId: Ids.hall2,
      start: start,
      end: start.add(const Duration(hours: 1)),
    ));
    expect(r, isA<Ok<Booking>>(),
        reason: r is Err<Booking> ? '${r.failure.runtimeType}' : null);
    return (r as Ok<Booking>).value;
  }

  ReminderScheduler scheduler() => ReminderScheduler(
        userId: Ids.bookerInternal,
        bookings: layer.bookings,
        notifications: layer.notifications,
        settings: layer.settings,
        clock: Clock(() => now),
        binding: TestWidgetsFlutterBinding.instance,
      );

  List<Notification> remindersFor(String bookingId, FakeAsync async) {
    List<Notification> notes = const [];
    layer.notifications.list(Ids.bookerInternal).then((r) => notes = r);
    async.elapse(Duration.zero);
    return notes
        .where((n) =>
            n.kind == NotificationKind.bookingReminder &&
            n.payload['bookingId'] == bookingId)
        .toList();
  }

  test('the 60-second tick writes the reminder once', () async {
    final b = await create(CairoTime.atWallClock(2026, 11, 16, 18));

    fakeAsync((async) {
      final s = scheduler();
      s.start();
      async.elapse(Duration.zero);
      expect(remindersFor(b.id, async), isEmpty);

      // 180 minutes before the start; the next tick is due.
      now = CairoTime.atWallClock(2026, 11, 16, 15);
      async.elapse(const Duration(seconds: 60));
      async.elapse(Duration.zero);
      final first = remindersFor(b.id, async);
      expect(first, hasLength(1));
      expect(first.single.id, 'rem-${b.id}');
      expect(first.single.payload['code'], b.code);

      // A later tick, after changing the lead, never re-creates it.
      now = CairoTime.atWallClock(2026, 11, 16, 14);
      async.elapse(const Duration(seconds: 60));
      async.elapse(Duration.zero);
      expect(remindersFor(b.id, async), hasLength(1));

      s.dispose();
    });
  });

  test('resuming the app runs the policy at once', () async {
    final b = await create(CairoTime.atWallClock(2026, 11, 17, 20));

    fakeAsync((async) {
      final s = scheduler();
      s.start();
      async.elapse(Duration.zero);
      expect(remindersFor(b.id, async), isEmpty);

      now = CairoTime.atWallClock(2026, 11, 17, 17);
      s.didChangeAppLifecycleState(AppLifecycleState.resumed);
      async.elapse(Duration.zero);
      expect(remindersFor(b.id, async), hasLength(1));

      s.dispose();
    });
  });
}
