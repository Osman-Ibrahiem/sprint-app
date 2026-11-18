import 'dart:typed_data';

import 'package:sprint/core/data/demo_snapshot_store.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';

/// A [DemoSnapshotStore] that keeps everything in memory. The default in
/// tests; the counters and `photoQuotaBytes` let tests check saves and the
/// storage-full path.
class InMemorySnapshotStore implements DemoSnapshotStore {
  InMemorySnapshotStore({this.photoQuotaBytes});

  /// Total photo bytes allowed; null for unlimited.
  int? photoQuotaBytes;

  Map<String, Object?>? snapshot;
  final Map<String, Uint8List> photos = {};
  int saveCount = 0;

  @override
  Future<Map<String, Object?>?> load() async => snapshot;

  @override
  Future<void> save(Map<String, Object?> value) async {
    saveCount++;
    snapshot = value;
  }

  @override
  Future<Uint8List?> loadPhoto(String id) async => photos[id];

  @override
  Future<Result<void>> savePhoto(String id, Uint8List bytes) async {
    final quota = photoQuotaBytes;
    if (quota != null) {
      final others = photos.entries
          .where((e) => e.key != id)
          .fold<int>(0, (n, e) => n + e.value.length);
      if (others + bytes.length > quota) return const Err(StorageFull());
    }
    photos[id] = bytes;
    return const Ok<void>(null);
  }

  @override
  Future<void> deletePhoto(String id) async {
    photos.remove(id);
  }

  @override
  Future<void> clear() async {
    snapshot = null;
    photos.clear();
  }
}
