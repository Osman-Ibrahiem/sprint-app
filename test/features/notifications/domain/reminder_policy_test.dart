import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/notifications/domain/reminder_policy.dart';

import '../../../helpers/domain_builders.dart';

/// BR-39: one reminder per confirmed booking, when its lead time is reached,
/// until its end, and never again once its deterministic record exists.
void main() {
  const policy = ReminderPolicy();
  final start = cairo(2026, 11, 18, 18);
  final end = start.add(const Duration(hours: 1));

  List<Booking> due({
    required DateTime now,
    List<Booking>? bookings,
    Set<String> existing = const {},
    int lead = 180,
    BookingStatus status = BookingStatus.confirmed,
  }) =>
      policy.due(
        bookings: bookings ??
            [booking(id: 'b1', start: start, status: status)],
        existingReminderIds: existing,
        now: now,
        leadMinutesFor: (_) => lead,
      );

  test('due exactly at the lead time, not one minute before', () {
    expect(due(now: start.subtract(const Duration(minutes: 180))), hasLength(1));
    expect(
      due(now: start.subtract(const Duration(minutes: 181))),
      isEmpty,
    );
  });

  test('still due until the end, never after it', () {
    expect(due(now: start.subtract(const Duration(minutes: 1))), hasLength(1));
    expect(due(now: start), hasLength(1));
    expect(due(now: end.subtract(const Duration(minutes: 1))), hasLength(1));
    expect(due(now: end), isEmpty);
    expect(due(now: end.add(const Duration(minutes: 1))), isEmpty);
  });

  test('an existing deterministic id is never re-created, even if the lead '
      'changes afterwards', () {
    expect(
      due(
        now: start.subtract(const Duration(minutes: 180)),
        existing: {'rem-b1'},
      ),
      isEmpty,
    );
    expect(
      due(
        now: start.subtract(const Duration(minutes: 240)),
        existing: {'rem-b1'},
        lead: 240,
      ),
      isEmpty,
    );
  });

  test('only confirmed bookings are reminded', () {
    for (final status in [
      BookingStatus.pendingPayment,
      BookingStatus.cancelled,
      BookingStatus.attended,
      BookingStatus.noShow,
      BookingStatus.expired,
    ]) {
      expect(
        due(
          now: start.subtract(const Duration(minutes: 60)),
          status: status,
        ),
        isEmpty,
        reason: '$status',
      );
    }
  });

  test('each booking uses its own lead', () {
    final a = booking(id: 'a', start: start);
    final b = booking(id: 'b', start: start.add(const Duration(hours: 2)));
    final found = policy.due(
      bookings: [a, b],
      existingReminderIds: const {},
      now: start.subtract(const Duration(minutes: 60)),
      leadMinutesFor: (x) => x.id == 'a' ? 60 : 180,
    );
    expect(found.map((x) => x.id), ['a', 'b']);
  });
}
