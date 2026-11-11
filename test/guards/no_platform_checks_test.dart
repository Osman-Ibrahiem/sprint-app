import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Screens never name a platform; only the adaptive controls, the scroll
/// behaviour and the theme glue may (FR-019, US3 scenario 6).
void main() {
  final pattern = RegExp(
    r'defaultTargetPlatform|Platform\.is|TargetPlatform|\.platform\b|'
    r'isApplePlatform|adaptiveStyleOf|\bkIsWeb\b',
  );
  const allowed = [
    'lib/core/adaptive/',
    'lib/core/scroll/',
    'lib/core/theme/',
  ];

  test('no platform checks outside the adaptive layer', () {
    final hits = <String>[];
    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      if (allowed.any(f.path.startsWith)) continue;
      final lines = f.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].trimLeft().startsWith('//')) continue;
        if (pattern.hasMatch(lines[i])) {
          hits.add('${f.path}:${i + 1}: ${lines[i].trim()}');
        }
      }
    }
    expect(hits, isEmpty, reason: hits.join('\n'));
  });
}
