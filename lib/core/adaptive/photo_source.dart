import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// Where a picked photo comes from (the ID card and the profile photo share
/// it; neither feature owns it).
enum PhotoSource { camera, gallery }

/// Where the picture comes from. Injectable, so tests use a fake picker
/// instead of the platform's.
abstract interface class PhotoSourcePicker {
  /// The raw bytes of the chosen image, or null when the person backed out.
  /// Throws when the platform refuses (for example a denied permission).
  Future<Uint8List?> pick(PhotoSource source);
}

/// `image_picker`: camera on Android and iOS, gallery or files everywhere.
/// Images only; on the web and desktop it opens the file selector.
class ImagePickerPhotoSource implements PhotoSourcePicker {
  const ImagePickerPhotoSource();

  @override
  Future<Uint8List?> pick(PhotoSource source) async {
    final file = await ImagePicker().pickImage(
      source: source == PhotoSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
    );
    return file?.readAsBytes();
  }
}

final photoSourceProvider = Provider<PhotoSourcePicker>(
  (ref) => const ImagePickerPhotoSource(),
);

