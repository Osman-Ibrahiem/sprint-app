import 'package:sprint/features/notifications/domain/notification.dart';
import 'package:sprint/features/notifications/domain/notification_repository.dart';

class InMemoryNotificationRepository implements NotificationRepository {
  InMemoryNotificationRepository([Iterable<Notification> seed = const []])
      : _items = [...seed];

  final List<Notification> _items;

  @override
  Future<List<Notification>> list(String userId) async => _items
      .where((n) => n.userId == userId)
      .toList()
    ..sort((a, b) => b.sentAt.compareTo(a.sentAt));

  @override
  Future<void> markRead(String id, DateTime at) async {
    final i = _items.indexWhere((n) => n.id == id);
    if (i >= 0) _items[i] = _items[i].copyWith(readAt: at);
  }

  @override
  Future<void> push(Notification notification) async =>
      _items.add(notification);
}
