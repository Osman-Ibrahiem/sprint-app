import 'dart:typed_data';

import 'package:sprint/core/result/result.dart';

/// Where the demo data survives a restart (research R1). The P1 store is local
/// preferences; the backend replaces the whole data layer, so presentation
/// never sees this.
abstract interface class DemoSnapshotStore {
  /// The saved snapshot, or null when it is missing or unreadable.
  Future<Map<String, Object?>?> load();

  /// Replaces the saved snapshot. The caller debounces.
  Future<void> save(Map<String, Object?> snapshot);

  /// A saved ID card photo, or null when missing or unreadable.
  Future<Uint8List?> loadPhoto(String id);

  /// Saves a photo under its own key. Fails with `StorageFull` when the device
  /// has no room, without touching the snapshot.
  Future<Result<void>> savePhoto(String id, Uint8List bytes);

  /// Removes one photo; a missing key is not an error.
  Future<void> deletePhoto(String id);

  /// Removes the snapshot and every photo. Theme and language stay.
  Future<void> clear();
}
