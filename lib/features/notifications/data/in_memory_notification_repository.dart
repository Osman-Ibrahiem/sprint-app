import 'package:sprint/core/data/change_signal.dart';
import 'package:sprint/features/notifications/domain/notification.dart';
import 'package:sprint/features/notifications/domain/notification_repository.dart';

class InMemoryNotificationRepository
    with ChangeSignal
    implements NotificationRepository {
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
    if (i >= 0) {
      if (_items[i].readAt == null) {
        _items[i] = _items[i].copyWith(readAt: at);
        notifyChanged();
      }
    }
  }

  @override
  Future<void> markAllRead(String userId, DateTime at) async {
    var changed = false;
    for (var i = 0; i < _items.length; i++) {
      final n = _items[i];
      if (n.userId == userId && n.readAt == null) {
        _items[i] = n.copyWith(readAt: at);
        changed = true;
      }
    }
    if (changed) notifyChanged();
  }

  @override
  Future<void> push(Notification notification) async {
    final i = _items.indexWhere((n) => n.id == notification.id);
    if (i < 0) {
      _items.add(notification);
    } else {
      _items[i] = notification.copyWith(
        readAt: _items[i].readAt ?? notification.readAt,
      );
    }
    notifyChanged();
  }

  /// Everything, for the demo snapshot.
  List<Notification> get all => List.unmodifiable(_items);
}
