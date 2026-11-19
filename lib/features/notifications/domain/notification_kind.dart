/// The closed set of notification kinds (data-model, contracts). The stored
/// `type` stays a free string so an unknown value from an older or newer save
/// decodes safely as [unknown].
enum NotificationKind {
  bookingConfirmed('booking.confirmed'),
  bookingReminder('booking.reminder'),
  bookingCancelledByAdmin('booking.cancelled_by_admin'),
  bookingCancelledByOwner('booking.cancelled_by_owner'),
  paymentRefundedAuto('payment.refunded_auto'),
  verificationPending('verification.pending'),
  verificationApproved('verification.approved'),
  verificationRejected('verification.rejected'),
  unknown('unknown');

  const NotificationKind(this._wire);

  final String _wire;

  /// The stable string written to storage and the demo snapshot.
  String get wire => _wire;

  static NotificationKind fromWire(String value) {
    for (final kind in values) {
      if (kind != unknown && kind._wire == value) return kind;
    }
    return unknown;
  }
}
