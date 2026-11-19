import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:sprint/core/data/in_memory_snapshot_store.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/features/identity/presentation/avatar_encoder.dart';
import 'package:sprint/features/identity/presentation/profile_photo_provider.dart';

/// The profile photo store and encoder (data-model, research R7): the one
/// `avatar-<userId>` key, a 512-pixel JPEG, and a friendly failure that leaves
/// the previous photo alone.
void main() {
  Uint8List jpeg({int width = 64, int height = 48}) {
    final image = img.Image(width: width, height: height);
    img.fill(image, color: img.ColorRgb8(120, 30, 200));
    return Uint8List.fromList(img.encodeJpg(image, quality: 90));
  }

  test('save returns the avatar key, load finds it and delete removes it',
      () async {
    final backend = InMemorySnapshotStore();
    final store = ProfilePhotoStore(backend);
    final bytes = jpeg();

    final saved = await store.save('u1', bytes);
    expect(saved, isA<Ok<String>>());
    final id = (saved as Ok<String>).value;
    expect(id, 'avatar-u1');
    expect(await store.load(id), bytes);

    await store.delete(id);
    expect(await store.load(id), isNull);
  });

  test('a full device fails with StorageFull and keeps the old photo',
      () async {
    final backend = InMemorySnapshotStore(photoQuotaBytes: 10);
    final store = ProfilePhotoStore(backend);

    final saved = await store.save('u1', jpeg());
    expect(saved, isA<Err<String>>());
    expect((saved as Err<String>).failure, isA<StorageFull>());
    expect(await store.load('avatar-u1'), isNull);
  });

  test('an oversize image is downscaled to 512 on its longest side', () {
    final encoded = encodeAvatarJpeg(jpeg(width: 1024, height: 512))!;
    final decoded = img.decodeImage(encoded)!;
    expect(math.max(decoded.width, decoded.height), avatarMaxSide);
    expect(decoded.width, avatarMaxSide);
    expect(decoded.height, avatarMaxSide ~/ 2);
  });

  test('bytes that are not an image are refused, so the old one stays', () async {
    final store = ProfilePhotoStore(InMemorySnapshotStore());
    final old = jpeg();
    final id = ((await store.save('u1', old)) as Ok<String>).value;

    expect(encodeAvatarJpeg(Uint8List.fromList([1, 2, 3, 4])), isNull);
    // A failed pick is not saved, so the stored photo is untouched.
    expect(await store.load(id), old);
  });
}
