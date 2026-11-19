import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprint/core/storage/preferences_provider.dart';
import 'package:sprint/features/notifications/domain/notification_permission.dart';

part 'notification_permission_store.g.dart';

/// The simulated permission answer on the device (FR-021). Absent means never
/// asked; failures read as absent and writes are ignored (FR-010).
class NotificationPermissionStore {
  NotificationPermissionStore(this._prefs);

  final SharedPreferences? _prefs;

  /// Kept while the app runs, so the answer holds even when the device store
  /// is missing or fails.
  NotificationPermission? _memory;

  static const key = 'notifPermission';

  NotificationPermission? read() {
    try {
      return switch (_prefs?.getString(key)) {
        'granted' => NotificationPermission.granted,
        'denied' => NotificationPermission.denied,
        _ => _memory,
      };
    } on Object {
      return _memory;
    }
  }

  Future<void> write(NotificationPermission permission) async {
    _memory = permission;
    try {
      await _prefs?.setString(key, permission.name);
    } on Object {
      // Keep the in-memory flow; the answer simply will not survive a relaunch.
    }
  }

  Future<void> clear() async {
    _memory = null;
    try {
      await _prefs?.remove(key);
    } on Object {
      // Nothing to clear.
    }
  }
}

@Riverpod(keepAlive: true)
NotificationPermissionStore notificationPermissionStore(Ref ref) =>
    NotificationPermissionStore(ref.watch(preferencesProvider));
