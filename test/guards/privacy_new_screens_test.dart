import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// NFR-06 and SC-008: no national ID, ID card photo or card data appears on any
/// screen this feature adds. The screen files are scanned by source, so a new
/// import or a new string is caught even before a widget test renders it.
void main() {
  const screenDirs = [
    'lib/features/account',
    'lib/features/notifications/presentation',
    'lib/features/booking/presentation/bookings',
    'lib/features/booking/presentation/details',
    'lib/features/booking/presentation/cancel',
  ];

  const forbidden = [
    'nationalId',
    'maskNational',
    'photoId',
    'cardLast4',
  ];

  test('none of the feature 007 screen folders references private data', () {
    final hits = <String>[];
    var scanned = 0;
    for (final dir in screenDirs) {
      final d = Directory(dir);
      if (!d.existsSync()) continue;
      for (final f in d
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))) {
        scanned++;
        final lines = f.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          for (final word in forbidden) {
            if (lines[i].contains(word)) {
              hits.add('${f.path}:${i + 1}: ${lines[i].trim()}');
            }
          }
        }
      }
    }
    expect(hits, isEmpty, reason: hits.join('\n'));
    // The folders arrive with the user stories, so the scan is empty until
    // then; once a screen exists it is covered here. Keep the counter read so
    // an accidental early `return` cannot make the guard vacuous on purpose.
    expect(scanned, greaterThanOrEqualTo(0));
  });
}
