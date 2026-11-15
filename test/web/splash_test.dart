import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Keeps `web/index.html` (the first screen and the early connections) in step
/// with the design tokens and the web decisions (SC-011, decisions.md
/// 2026-11-11). The splash is plain HTML, so it cannot read the generated
/// Dart tokens; this test is the guard instead.
void main() {
  final html = File('web/index.html').readAsStringSync();
  final tokens = jsonDecode(File('docs/design-system/tokens.json').readAsStringSync())
      as Map<String, dynamic>;
  final colors = {
    for (final t in (tokens['color'] as Map<String, dynamic>)['tokens'] as List)
      if ((t as Map<String, dynamic>)['value'] is Map)
        t['name'] as String: t['value'] as Map<String, dynamic>,
  };

  test('splash colours match the bg and ink tokens in light and dark', () {
    for (final name in ['bg', 'ink']) {
      for (final theme in ['light', 'dark']) {
        final hex = (colors[name]![theme] as String).toLowerCase();
        expect(html.toLowerCase(), contains(hex),
            reason: 'token $name ($theme) = $hex is not in web/index.html');
      }
    }
  });

  test('splash logo uses the primary tile and the volt bolt of the logo file', () {
    final tile = File('docs/design-system/logo/sprint-tile-primary.svg').readAsStringSync();
    for (final hex in RegExp(r'fill="(#[0-9a-fA-F]{6})"')
        .allMatches(tile)
        .map((m) => m.group(1)!.toLowerCase())) {
      expect(html.toLowerCase(), contains('fill="$hex"'));
    }
  });

  test('connections to the engine CDN are opened early', () {
    expect(html, contains('rel="preconnect" href="https://www.gstatic.com" crossorigin'));
    expect(html, contains('rel="preconnect" href="https://www.gstatic.com">'));
    expect(html, contains('rel="preconnect" href="https://fonts.gstatic.com" crossorigin'));
  });

  test('splash goes away at the first frame, with a timeout and reduced motion', () {
    expect(html, contains("'flutter-first-frame'"));
    expect(html, contains('setTimeout(remove'));
    expect(html, contains('prefers-reduced-motion'));
  });

  test('page is Arabic, right-to-left, with the brand title', () {
    expect(html, contains('<html lang="ar" dir="rtl">'));
    expect(html, contains('<title>سبرنت</title>'));
  });
}
