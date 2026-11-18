import 'package:sprint/features/notifications/domain/notification.dart';

abstract interface class NotificationRepository {
  /// Fires after each successful write.
  Stream<void> get changes;

  /// Newest first.
  Future<List<Notification>> list(String userId);
  Future<void> markRead(String id, DateTime at);

  /// Marks every unread record of [userId] read at [at]; other people and
  /// already-read records keep their state.
  Future<void> markAllRead(String userId, DateTime at);

  /// Adds a record, or replaces the one with the same id (reminders are
  /// deterministic, so pushing twice is one record). The first read state is
  /// kept.
  Future<void> push(Notification notification);
}
