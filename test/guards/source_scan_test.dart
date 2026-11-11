import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Mechanical guards for the constitution (II, V): tokens only, direction-aware
/// layout, strings in ARB. Scans `lib/` except generated tokens, seed data and
/// generated l10n (SC-004, SC-005, research R9).
class _Rule {
  const _Rule(this.name, this.pattern, {this.uiOnly = false});
  final String name;
  final RegExp pattern;

  /// Skips `data/` and `domain/` code, where a duration is a rule or a fake's
  /// delay, not UI motion.
  final bool uiOnly;
}

bool _isLogic(String path) => path.contains('/data/') || path.contains('/domain/');

final _rules = <_Rule>[
  _Rule('raw colour Color(0x', RegExp(r'Color\(\s*0x')),
  _Rule('Colors.* other than transparent', RegExp(r'\bColors\.(?!transparent\b)\w+')),
  _Rule('numeric fontSize', RegExp(r'fontSize\s*:\s*\d')),
  _Rule('EdgeInsets.all(<number>)', RegExp(r'EdgeInsets(?:Directional)?\.all\(\s*\d')),
  _Rule(
    'numeric spacing/size literal',
    RegExp(
      r'\b(top|bottom|start|end|left|right|horizontal|vertical|width|height|'
      r'radius|blurRadius)\s*:\s*(?!0\b)\d',
    ),
  ),
  _Rule(
    'numeric Duration',
    RegExp(r'Duration\(\s*(milliseconds|seconds)\s*:\s*\d'),
    uiOnly: true,
  ),
  _Rule('BorderRadius.circular(<number>)', RegExp(r'BorderRadius\.circular\(\s*\d')),
  _Rule(
    'left/right-specific alignment',
    RegExp(r'Alignment\.(center|top|bottom)(Left|Right)\b'),
  ),
  _Rule(
    'EdgeInsets.only(left:/right:)',
    RegExp(r'EdgeInsets\.(only|fromLTRB)\((?:(?!\)).)*\b(left|right)\s*:', dotAll: true),
  ),
  _Rule('string literal in Text(', RegExp(r'\bText\(\s*(const\s+)?[\x27"]')),
  _Rule(
    'volt used as text, icon, line or foreground',
    RegExp(
      r'(TextStyle|style:|Icon\(|Border|BorderSide|foregroundColor|iconColor|'
      r'copyWith\(\s*color)[^\n;]*\.volt\b',
    ),
  ),
];

bool _excluded(String path) =>
    path.startsWith('lib/core/tokens/') ||
    path.startsWith('lib/core/seed/') ||
    path.startsWith('lib/l10n/gen/') ||
    path.endsWith('.g.dart') ||
    path.endsWith('.freezed.dart');

void main() {
  final files = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart') && !_excluded(f.path))
      .toList();

  test('the scan finds the app source', () {
    expect(files.length, greaterThan(20));
  });

  for (final rule in _rules) {
    test('no ${rule.name} in lib/', () {
      final hits = <String>[];
      for (final f in files) {
        if (rule.uiOnly && _isLogic(f.path)) continue;
        final lines = f.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i].trimLeft();
          if (line.startsWith('//')) continue;
          if (rule.pattern.hasMatch(lines[i])) {
            hits.add('${f.path}:${i + 1}: ${lines[i].trim()}');
          }
        }
        // Multi-line patterns (EdgeInsets.only(... left:) are checked on the
        // whole file text.
        if (rule.pattern.isMultiLine || rule.pattern.pattern.contains('(?!\\))')) {
          final text = f.readAsStringSync();
          for (final m in rule.pattern.allMatches(text)) {
            final line = '\n'.allMatches(text.substring(0, m.start)).length + 1;
            hits.add('${f.path}:$line: ${m.group(0)!.split('\n').first}');
          }
        }
      }
      expect(hits.toSet(), isEmpty, reason: hits.join('\n'));
    });
  }
}
