import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/notifications/domain/notification.dart';
import 'package:sprint/features/notifications/domain/notification_kind.dart';

/// The closed set of notification kinds and their stable wire strings
/// (contracts/repositories.md, data-model): unknown values never throw, and
/// the wire string survives a JSON round-trip.
void main() {
  const wires = {
    'booking.confirmed': NotificationKind.bookingConfirmed,
    'booking.reminder': NotificationKind.bookingReminder,
    'booking.cancelled_by_admin': NotificationKind.bookingCancelledByAdmin,
    'booking.cancelled_by_owner': NotificationKind.bookingCancelledByOwner,
    'payment.refunded_auto': NotificationKind.paymentRefundedAuto,
    'verification.pending': NotificationKind.verificationPending,
    'verification.approved': NotificationKind.verificationApproved,
    'verification.rejected': NotificationKind.verificationRejected,
  };

  test('every wire value has one kind and back', () {
    expect(
      NotificationKind.values.where((k) => k != NotificationKind.unknown),
      hasLength(wires.length),
    );
    for (final entry in wires.entries) {
      expect(NotificationKind.fromWire(entry.key), entry.value);
      expect(entry.value.wire, entry.key);
    }
  });

  test('anything else is unknown, never a throw', () {
    for (final value in ['', 'booking', 'BOOKING.CONFIRMED', 'nope']) {
      expect(NotificationKind.fromWire(value), NotificationKind.unknown);
    }
  });

  test('a notification reads its kind from type and keeps the wire string in '
      'JSON', () {
    final n = Notification(
      id: 'n1',
      userId: 'u1',
      type: 'booking.reminder',
      payload: const {'bookingId': 'b1', 'code': 'SP-1001'},
      sentAt: DateTime.utc(2026, 11, 18, 9),
    );
    expect(n.kind, NotificationKind.bookingReminder);

    final decoded = Notification.fromJson(n.toJson());
    expect(decoded, n);
    expect(decoded.type, 'booking.reminder');
    expect(decoded.kind, NotificationKind.bookingReminder);
  });
}
