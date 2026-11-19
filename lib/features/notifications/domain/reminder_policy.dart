import 'package:sprint/features/booking/domain/booking.dart';

/// BR-39: which bookings are due a reminder right now. Pure, so the scheduler
/// and the tests share the one rule.
class ReminderPolicy {
  const ReminderPolicy();

  static const String reminderPrefix = 'rem-';

  /// The deterministic id of a booking's reminder; also its idempotence key.
  static String reminderId(Booking booking) => '$reminderPrefix${booking.id}';

  /// A confirmed booking is due when `start - lead <= now < end` and no
  /// record with its id exists. A lead change after the record exists never
  /// brings it back.
  List<Booking> due({
    required List<Booking> bookings,
    required Set<String> existingReminderIds,
    required DateTime now,
    required int Function(Booking) leadMinutesFor,
  }) =>
      [
        for (final b in bookings)
          if (b.status == BookingStatus.confirmed &&
              !existingReminderIds.contains(reminderId(b)) &&
              !now.isBefore(
                b.start.subtract(Duration(minutes: leadMinutesFor(b))),
              ) &&
              now.isBefore(b.end))
            b,
      ];
}
