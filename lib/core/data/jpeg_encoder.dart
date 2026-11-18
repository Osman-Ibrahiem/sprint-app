import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Decodes, straightens, shrinks the longest side to [maxSide] and writes a
/// JPEG at [quality]. Returns null when the bytes are not an image. Pure, so
/// callers can run it in an isolate. Shared by the ID card and profile photos.
Uint8List? encodeJpeg(
  Uint8List bytes, {
  required int maxSide,
  required int quality,
}) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return null;
  var image = img.bakeOrientation(decoded);
  if (math.max(image.width, image.height) > maxSide) {
    image = image.width >= image.height
        ? img.copyResize(image, width: maxSide)
        : img.copyResize(image, height: maxSide);
  }
  return Uint8List.fromList(img.encodeJpg(image, quality: quality));
}
