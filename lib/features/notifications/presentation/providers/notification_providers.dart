import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/features/notifications/domain/notification.dart';

part 'notification_providers.g.dart';

/// The most the badge shows before "99+" (presentation constant, data-model).
const int notificationBadgeCap = 99;

/// The signed-in person's notifications, newest first, reloaded on every
/// write to the repository. Empty for a guest.
@riverpod
Future<List<Notification>> notificationsList(Ref ref) async {
  final user = ref.watch(currentSessionProvider).user;
  if (user == null) return const [];
  final repo = ref.watch(notificationRepositoryProvider);
  final sub = repo.changes.listen((_) => ref.invalidateSelf());
  ref.onDispose(sub.cancel);
  return repo.list(user.id);
}

/// Records not read yet; null while loading (the bell shows no badge then).
/// The "cancelled by me" record is written already read, so it never counts.
@riverpod
int? unreadCount(Ref ref) {
  final list = ref.watch(notificationsListProvider).value;
  if (list == null) return null;
  return list.where((n) => n.readAt == null).length;
}

/// What the badge draws for [count]: nothing at zero, "99+" past the cap.
String? badgeLabel(int? count) {
  if (count == null || count <= 0) return null;
  return count > notificationBadgeCap ? '$notificationBadgeCap+' : '$count';
}
