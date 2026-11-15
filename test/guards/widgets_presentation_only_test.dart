import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// FR-010: widgets under `lib/core/widgets/` are presentation only. They never
/// import a feature, the app shell or a repository/provider.
void main() {
  final files = Directory('lib/core/widgets')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  test('the scan finds the existing widgets, so it cannot pass on an empty '
      'folder', () {
    expect(
      files.any((f) => f.path.endsWith('option_group.dart')),
      isTrue,
    );
  });

  test('no widget imports features/, app/, a provider or a repository', () {
    final hits = <String>[];
    for (final f in files) {
      final lines = f.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        if (!line.startsWith('import ') && !line.startsWith('export ')) {
          continue;
        }
        if (line.contains('package:sprint/features/') ||
            line.contains('package:sprint/app/') ||
            line.contains('_provider.dart') ||
            line.contains('repository.dart')) {
          hits.add('${f.path}:${i + 1}: $line');
        }
      }
    }
    expect(hits, isEmpty, reason: hits.join('\n'));
  });
}
