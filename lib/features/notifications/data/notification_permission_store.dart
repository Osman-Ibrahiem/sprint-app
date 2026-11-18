import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprint/core/storage/preferences_provider.dart';
import 'package:sprint/features/notifications/domain/notification_permission.dart';

part 'notification_permission_store.g.dart';

/// The simulated permission answer on the device (FR-021). Absent means never
/// asked; failures read as absent and writes are ignored (FR-010).
class NotificationPermissionStore {
  const NotificationPermissionStore(this._prefs);

  final SharedPreferences? _prefs;

  static const key = 'notifPermission';

  NotificationPermission? read() {
    try {
      return switch (_prefs?.getString(key)) {
        'granted' => NotificationPermission.granted,
        'denied' => NotificationPermission.denied,
        _ => null,
      };
    } on Object {
      return null;
    }
  }

  Future<void> write(NotificationPermission permission) async {
    try {
      await _prefs?.setString(key, permission.name);
    } on Object {
      // Keep the in-memory flow; the answer simply will not survive a relaunch.
    }
  }

  Future<void> clear() async {
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
