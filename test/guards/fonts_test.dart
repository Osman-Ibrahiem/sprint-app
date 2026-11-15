import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Cairo is the only font (decisions.md, 2026-11-15). This keeps it that way:
/// no other family in `pubspec.yaml` or in the token text styles, and the
/// weights the tokens use are all declared.
void main() {
  final pubspec = File('pubspec.yaml').readAsStringSync();
  final text = File('lib/core/tokens/sprint_text.g.dart').readAsStringSync();

  test('pubspec declares only the Cairo family, weights 400 to 700', () {
    final families = RegExp(r'^\s*-\s*family:\s*(.+)$', multiLine: true)
        .allMatches(pubspec)
        .map((m) => m.group(1)!.trim())
        .toList();
    expect(families, ['Cairo']);
    for (final w in [400, 500, 600, 700]) {
      expect(pubspec, contains('weight: $w'));
    }
  });

  test('every generated text style uses Cairo', () {
    final used = RegExp(r"fontFamily:\s*'([^']+)'")
        .allMatches(text)
        .map((m) => m.group(1)!)
        .toSet();
    expect(used, {'Cairo'});
  });

  test('no font files besides Cairo (and its licence) are bundled', () {
    final files = Directory('assets/fonts')
        .listSync()
        .map((e) => e.uri.pathSegments.last)
        .toList()
      ..sort();
    expect(files, [
      'Cairo-Bold.ttf',
      'Cairo-Medium.ttf',
      'Cairo-Regular.ttf',
      'Cairo-SemiBold.ttf',
      'OFL-Cairo.txt',
    ]);
  });
}
