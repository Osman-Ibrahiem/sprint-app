import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Whether the device can take a photo with its camera: Android and iOS
/// apps only. On the web and on desktop the choice is gallery or files
/// (research R7). Platform checks stay in the adaptive layer (FR-019).
bool cameraAvailableFor(TargetPlatform platform, {required bool isWeb}) =>
    !isWeb &&
    (platform == TargetPlatform.android || platform == TargetPlatform.iOS);

bool cameraAvailableOf(BuildContext context) =>
    cameraAvailableFor(Theme.of(context).platform, isWeb: kIsWeb);
