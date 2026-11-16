import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every Phosphor glyph is declared with `matchTextDirection: true`, so a raw
/// `Icon(` flips itself in RTL, including ticks, magnifiers, clocks and QR
/// (CLAUDE.md: mirror directional icons only). Use `SprintIcon` for those and
/// `DirectionalIcon` for arrows and chevrons (FR-019).
void main() {
  final pattern = RegExp(r'(^|[^A-Za-z0-9_])Icon\(');
  const allowed = {
    // The two wrappers that decide the direction.
    'lib/core/l10n/sprint_icon.dart',
    'lib/core/l10n/directional_icon.dart',
    // Switch.thumbIcon only accepts an `Icon`; it sets textDirection itself.
    'lib/core/adaptive/adaptive_switch.dart',
  };

  test('no raw Icon( outside SprintIcon and DirectionalIcon', () {
    final hits = <String>[];
    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      if (allowed.contains(f.path)) continue;
      final lines = f.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].trimLeft().startsWith('//')) continue;
        if (pattern.hasMatch(lines[i])) {
          hits.add('${f.path}:${i + 1}: ${lines[i].trim()}');
        }
      }
    }
    expect(
      hits,
      isEmpty,
      reason: 'Raw Icon( flips in RTL. Use SprintIcon (never mirrors) or '
          'DirectionalIcon (mirrors once) instead:\n${hits.join('\n')}',
    );
  });
}
