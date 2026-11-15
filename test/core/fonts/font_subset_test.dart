import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The Alexandria and Cairo files are subset (assets/fonts/SUBSET.md). Every
/// character the app can show must be inside the kept ranges, or it would fall
/// back to another font.
void main() {
  final config = jsonDecode(
    File('tool/font_subset.json').readAsStringSync(),
  ) as Map<String, dynamic>;

  bool inRanges(int cp) {
    for (final part in (config['unicodes'] as String).split(',')) {
      final bounds = part.replaceAll('U+', '').split('-');
      final lo = int.parse(bounds.first, radix: 16);
      final hi = int.parse(bounds.last, radix: 16);
      if (cp >= lo && cp <= hi) return true;
    }
    return false;
  }

  final used = <int, String>{}; // code point -> where it was found

  void scan(String text, String where) {
    for (final rune in text.runes) {
      if (rune < 0x20 || rune == 0x0A || rune == 0x0D || rune == 0x09) continue;
      used.putIfAbsent(rune, () => where);
    }
  }

  setUpAll(() {
    for (final f in Directory('lib/l10n').listSync().whereType<File>()) {
      if (!f.path.endsWith('.arb')) continue;
      final json = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      json.forEach((k, v) {
        if (v is String && !k.startsWith('@')) scan(v, f.path);
      });
    }
    final literal = RegExp(
      r"'((?:[^'\\\n]|\\.)*)'|"
      r'"((?:[^"\\\n]|\\.)*)"',
    );
    for (final f in Directory(
      'lib',
    ).listSync(recursive: true).whereType<File>()) {
      final p = f.path;
      if (!p.endsWith('.dart') ||
          p.contains('/gen/') ||
          p.endsWith('.g.dart')) {
        continue;
      }
      for (final m in literal.allMatches(f.readAsStringSync())) {
        scan(m.group(1) ?? m.group(2) ?? '', p);
      }
    }
  });

  test('the strings are found, so the scan is meaningful', () {
    expect(used.length, greaterThan(60));
  });

  test(
    'every character in the app copy and seed data is in the kept ranges',
    () {
      final missing = [
        for (final e in used.entries)
          if (!inRanges(e.key) && e.key != 0x5C) // a backslash only escapes
            'U+${e.key.toRadixString(16).toUpperCase()} '
                '"${String.fromCharCode(e.key)}" in ${e.value}',
      ];
      expect(missing, isEmpty, reason: missing.join('\n'));
    },
  );

  test('the six subset files exist and are small', () {
    for (final name in (config['fonts'] as List).cast<String>()) {
      final f = File('assets/fonts/$name.ttf');
      expect(f.existsSync(), isTrue, reason: name);
      expect(
        f.lengthSync(),
        lessThan(100 * 1024),
        reason: '$name is not subset',
      );
    }
  });

  test('IBM Plex Mono is untouched (its licence reserves the name)', () {
    for (final name in ['IBMPlexMono-Regular', 'IBMPlexMono-Medium']) {
      expect(
        File('assets/fonts/$name.ttf').lengthSync(),
        greaterThan(100 * 1024),
      );
    }
  });
}
