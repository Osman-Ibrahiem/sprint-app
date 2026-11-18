import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sprint/features/notifications/domain/notification_kind.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

/// Push only in P1 (BR-39); SMS joins in P2.
enum NotificationChannel { push }

/// A notification. [type] is the wire string of a [NotificationKind].
///
/// Payload keys, read by the notification centre:
/// - `bookingId` and `code` on every booking record (confirmed, reminder,
///   both cancels);
/// - `amount` on a refund, the whole pounds given back;
/// - `verificationId` and `reason` on a verification record.
@freezed
abstract class Notification with _$Notification {
  const Notification._();

  const factory Notification({
    required String id,
    required String userId,
    required String type,
    @Default(NotificationChannel.push) NotificationChannel channel,
    @Default(<String, String>{}) Map<String, String> payload,
    required DateTime sentAt,
    DateTime? readAt,
  }) = _Notification;

  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);

  NotificationKind get kind => NotificationKind.fromWire(type);
}

