import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprint/core/data/demo_snapshot_store.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/result/result.dart';

part 'profile_photo_provider.g.dart';

/// Profile photos in the one photo store the demo snapshot already keeps
/// (research R7). The key is derived from the person, so a save replaces the
/// old photo and a delete leaves the initial in its place.
class ProfilePhotoStore {
  const ProfilePhotoStore(this._store);

  final DemoSnapshotStore _store;

  static String avatarIdFor(String userId) => 'avatar-$userId';

  /// Stores [jpeg] as the person's avatar and returns its key.
  Future<Result<String>> save(String userId, Uint8List jpeg) async {
    final id = avatarIdFor(userId);
    final saved = await _store.savePhoto(id, jpeg);
    return switch (saved) {
      Ok() => Ok(id),
      Err(:final failure) => Err(failure),
    };
  }

  Future<Uint8List?> load(String avatarId) => _store.loadPhoto(avatarId);

  Future<void> delete(String avatarId) => _store.deletePhoto(avatarId);
}

@Riverpod(keepAlive: true)
ProfilePhotoStore profilePhotoStore(Ref ref) =>
    ProfilePhotoStore(ref.watch(dataLayerProvider).photos);

/// The stored photo of [userId], or null for the initial.
@riverpod
Future<Uint8List?> profilePhoto(Ref ref, String userId) async {
  final user = await ref.watch(identityRepositoryProvider).getUser(userId);
  final avatarId = user?.avatarId;
  if (avatarId == null) return null;
  return ref.watch(profilePhotoStoreProvider).load(avatarId);
}
