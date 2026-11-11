import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/gen_tokens.dart';

void main() {
  final json =
      jsonDecode(File('docs/design-system/tokens.json').readAsStringSync())
          as Map<String, dynamic>;

  test('committed token files match tokens.json', () {
    final generated = generateTokens(json);
    expect(generated, isNotEmpty);
    generated.forEach((name, content) {
      final file = File('lib/core/tokens/$name');
      expect(file.existsSync(), isTrue, reason: '$name is missing');
      expect(
        file.readAsStringSync(),
        content,
        reason: '$name drifted: run dart run tool/gen_tokens.dart',
      );
    });
  });

  test('every font weight used by a type style is declared in pubspec', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final declared = <String, Set<int>>{};
    String? family;
    for (final line in pubspec.split('\n')) {
      final f = RegExp(r'^\s*-\s*family:\s*(.+?)\s*$').firstMatch(line);
      if (f != null) family = f.group(1);
      final w = RegExp(r'^\s*weight:\s*(\d+)').firstMatch(line);
      if (w != null && family != null) {
        declared.putIfAbsent(family, () => {}).add(int.parse(w.group(1)!));
      }
    }

    final type = json['type'] as Map<String, dynamic>;
    final families = type['families'] as Map<String, dynamic>;
    for (final g in (type['groups'] as List).cast<Map<String, dynamic>>()) {
      final fam = RegExp(r'"([^"]+)"')
          .firstMatch(families[g['family'] as String] as String)!
          .group(1)!;
      for (final s in (g['styles'] as List).cast<Map<String, dynamic>>()) {
        expect(
          declared[fam],
          contains(s['fontWeight'] as int),
          reason: '$fam ${s['fontWeight']} used by ${s['name']} '
              'is not declared in pubspec.yaml',
        );
      }
    }
  });
}
