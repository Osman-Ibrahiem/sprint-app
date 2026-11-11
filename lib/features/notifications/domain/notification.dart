import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';

/// Push only in P1 (BR-39); SMS joins in P2.
enum NotificationChannel { push }

@freezed
abstract class Notification with _$Notification {
  const factory Notification({
    required String id,
    required String userId,
    required String type,
    @Default(NotificationChannel.push) NotificationChannel channel,
    @Default(<String, String>{}) Map<String, String> payload,
    required DateTime sentAt,
    DateTime? readAt,
  }) = _Notification;
}
