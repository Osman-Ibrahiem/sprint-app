import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// IBM Plex Mono is used only for booking codes, so it is not declared under
/// `fonts:` in `pubspec.yaml` (which loads every file at startup) but bundled as
/// plain assets and loaded here the first time a code is shown. That keeps
/// about 0.14 MB (gzip) off the web's first load (SC-011, research R10).
///
/// While it loads, the `code` style falls back to the generic monospace family
/// with the same explicit line height, so nothing shifts.
const monoFamily = 'IBM Plex Mono';

/// Weight to asset path. Weights match `type.groups` in `tokens.json` (`code`
/// is 500) and the original declaration (400 and 500).
const deferredMonoAssets = <int, String>{
  400: 'assets/fonts/IBMPlexMono-Regular.ttf',
  500: 'assets/fonts/IBMPlexMono-Medium.ttf',
};

Future<void>? _mono;

/// Loads IBM Plex Mono once; later calls share the same future. A failure is
/// not remembered, so the next call tries again.
Future<void> ensureMonoFont() {
  return _mono ??= _loadMono().catchError((Object _) {
    _mono = null;
  });
}

Future<void> _loadMono() async {
  final loader = FontLoader(monoFamily);
  for (final path in deferredMonoAssets.values) {
    loader.addFont(rootBundle.load(path));
  }
  await loader.load();
}

/// Forgets that the font was loaded. For tests only.
@visibleForTesting
void debugResetMonoFont() => _mono = null;
