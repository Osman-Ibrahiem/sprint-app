import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The payments feature's pure-rules promise (constitution IV): files under
/// `lib/features/payments/domain/` never import Flutter, Riverpod or a
/// `data/` implementation, and nothing under `lib/features/booking/` imports
/// the fake gateway (only the fake page and `/demo` may, BR-28, FR-009).
List<File> _dartFiles(String dir) {
  final d = Directory(dir);
  if (!d.existsSync()) return [];
  return d
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();
}

Iterable<String> _imports(File f) sync* {
  final lines = f.readAsLinesSync();
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.startsWith('import ') || line.startsWith('export ')) {
      yield '${f.path}:${i + 1}: $line';
    }
  }
}

void main() {
  final domainFiles = _dartFiles('lib/features/payments/domain');
  final bookingFiles = _dartFiles('lib/features/booking');

  test('the scan finds the payments domain files', () {
    expect(domainFiles, isNotEmpty);
  });

  test('payments domain imports nothing from Flutter, Riverpod or data/', () {
    const banned = [
      'package:flutter/',
      'package:flutter_riverpod/',
      'package:riverpod_annotation/',
      'package:flutter_test/',
    ];
    final hits = <String>[];
    for (final f in domainFiles) {
      for (final line in _imports(f)) {
        final importsData =
            line.contains('features/') && line.contains('/data/');
        if (banned.any(line.contains) || importsData) hits.add(line);
      }
    }
    expect(hits, isEmpty, reason: hits.join('\n'));
  });

  test('booking code never imports the fake gateway or fake provider', () {
    final hits = <String>[];
    for (final f in bookingFiles) {
      for (final line in _imports(f)) {
        if (line.contains('fake_gateway_controller.dart') ||
            line.contains('fake_payment_provider.dart')) {
          hits.add(line);
        }
      }
    }
    expect(hits, isEmpty, reason: hits.join('\n'));
  });

  test('only the provider page and the /demo section read fakeGatewayProvider',
      () {
    const allowed = {
      'lib/core/providers/data_providers.dart',
      'lib/core/providers/data_providers.g.dart',
      'lib/features/payments/presentation/fake_gateway_screen.dart',
      'lib/features/demo/presentation/demo_payment_section.dart',
    };
    final hits = <String>[];
    for (final f in _dartFiles('lib')) {
      if (allowed.contains(f.path)) continue;
      if (f.readAsStringSync().contains('fakeGatewayProvider')) {
        hits.add(f.path);
      }
    }
    expect(hits, isEmpty, reason: hits.join('\n'));
  });
}
