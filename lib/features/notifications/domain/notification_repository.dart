import 'package:sprint/features/notifications/domain/notification.dart';

abstract interface class NotificationRepository {
  /// Newest first.
  Future<List<Notification>> list(String userId);
  Future<void> markRead(String id, DateTime at);
  Future<void> push(Notification notification);
}
