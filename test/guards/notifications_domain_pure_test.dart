import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The notifications feature's pure-rules promise (constitution IV): files under
/// `lib/features/notifications/domain/` never import Flutter, Riverpod or a
/// `data/` implementation, and notifications screens never import an in-memory
/// class directly. Screens read interfaces through
/// `lib/core/providers/data_providers.dart` only.
void main() {
  final domainDir = Directory('lib/features/notifications/domain');
  final domainFiles = domainDir.existsSync()
      ? domainDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList()
      : <File>[];

  final presentationDir = Directory('lib/features/notifications/presentation');
  final presentationFiles = presentationDir.existsSync()
      ? presentationDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList()
      : <File>[];

  test('the scan finds the notifications domain files', () {
    expect(domainFiles, isNotEmpty);
  });

  test('domain/ imports nothing from Flutter, Riverpod or data/', () {
    const banned = [
      'package:flutter/',
      'package:flutter_riverpod/',
      'package:riverpod_annotation/',
      'package:flutter_test/',
    ];
    final hits = <String>[];
    for (final f in domainFiles) {
      final lines = f.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        if (!line.startsWith('import ') && !line.startsWith('export ')) {
          continue;
        }
        final hasBannedImport = banned.any(line.contains);
        final importsData = line.contains('features/') && line.contains('/data/');
        if (hasBannedImport || importsData) {
          hits.add('${f.path}:${i + 1}: $line');
        }
      }
    }
    expect(hits, isEmpty, reason: hits.join('\n'));
  });

  test('presentation/ never imports an in-memory class', () {
    final hits = <String>[];
    for (final f in presentationFiles) {
      final lines = f.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        if (!line.startsWith('import ')) continue;
        if (line.contains('/data/in_memory_')) {
          hits.add('${f.path}:${i + 1}: $line');
        }
      }
    }
    expect(hits, isEmpty, reason: hits.join('\n'));
  });
}
