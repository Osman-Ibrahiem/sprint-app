import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Keeps `web/index.html` (the first screen and the early connections) in step
/// with the design tokens and the web decisions (SC-011, decisions.md
/// 2026-11-11). The splash is plain HTML, so it cannot read the generated
/// Dart tokens; this test is the guard instead.
void main() {
  final html = File('web/index.html').readAsStringSync();
  final tokens = jsonDecode(
    File('docs/design-system/tokens.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final colors = {
    for (final t in (tokens['color'] as Map<String, dynamic>)['tokens'] as List)
      if ((t as Map<String, dynamic>)['value'] is Map)
        t['name'] as String: t['value'] as Map<String, dynamic>,
  };

  test('splash background is the light primary token in both themes', () {
    final primary = (colors['primary']!['light'] as String).toLowerCase();
    expect(html.toLowerCase(), contains('background: $primary;'));
    expect(html, isNot(contains('prefers-color-scheme: dark')));
  });

  test('splash shows the bare 88px volt bolt of the logo file, no tile', () {
    final mark = File('docs/design-system/logo/sprint-mark.svg')
        .readAsStringSync();
    final path = RegExp(r' d="([^"]+)"').firstMatch(mark)!.group(1)!;
    final tokenList =
        ((tokens['color'] as Map<String, dynamic>)['tokens'] as List)
            .cast<Map<String, dynamic>>();
    final volt =
        tokenList.firstWhere((t) => t['name'] == 'volt')['value'] as String;
    expect(html, contains('d="$path" fill="$volt"'));
    expect(html, contains('width: 88px; height: 88px;'));
    expect(html, isNot(contains('<rect')));
  });

  test('connections to the engine CDN are opened early', () {
    expect(
      html,
      contains('rel="preconnect" href="https://www.gstatic.com" crossorigin'),
    );
    expect(html, contains('rel="preconnect" href="https://www.gstatic.com">'));
    expect(
      html,
      contains('rel="preconnect" href="https://fonts.gstatic.com" crossorigin'),
    );
  });

  test(
    'splash goes away at the first frame, with a timeout and reduced motion',
    () {
      expect(html, contains("'flutter-first-frame'"));
      expect(html, contains('setTimeout(remove'));
      expect(html, contains('prefers-reduced-motion'));
    },
  );

  test('page is Arabic, right-to-left, with the brand title', () {
    expect(html, contains('<html lang="ar" dir="rtl">'));
    expect(html, contains('<title>سبرنت</title>'));
  });
}
