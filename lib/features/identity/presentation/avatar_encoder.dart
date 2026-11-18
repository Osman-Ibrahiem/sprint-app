import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint/core/data/jpeg_encoder.dart';

/// Longest side of a stored profile photo, in pixels (data-model).
const int avatarMaxSide = 512;

/// JPEG quality of a stored profile photo.
const int avatarJpegQuality = 80;

/// Turns the chosen bytes into the stored avatar, or null when they are not
/// an image, reusing the ID card encoder path.
Uint8List? encodeAvatarJpeg(Uint8List bytes) => encodeJpeg(
      bytes,
      maxSide: avatarMaxSide,
      quality: avatarJpegQuality,
    );

typedef AvatarEncoder = Future<Uint8List?> Function(Uint8List bytes);

/// Runs [encodeAvatarJpeg] in a background isolate (inline on the web).
final avatarEncoderProvider = Provider<AvatarEncoder>(
  (ref) => (bytes) => compute(encodeAvatarJpeg, bytes),
);
