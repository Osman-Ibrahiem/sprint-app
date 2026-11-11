import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _arb(String name) =>
    jsonDecode(File('lib/l10n/$name').readAsStringSync())
        as Map<String, dynamic>;

Map<String, String> _messages(Map<String, dynamic> arb) => {
      for (final e in arb.entries)
        if (!e.key.startsWith('@')) e.key: e.value as String,
    };

void main() {
  final ar = _messages(_arb('app_ar.arb'));
  final en = _messages(_arb('app_en.arb'));

  test('every key exists in both ARB files (SC-005)', () {
    expect(
      ar.keys.toSet().difference(en.keys.toSet()),
      isEmpty,
      reason: 'keys only in Arabic',
    );
    expect(
      en.keys.toSet().difference(ar.keys.toSet()),
      isEmpty,
      reason: 'keys only in English',
    );
  });

  test('no message is empty', () {
    for (final entry in {...ar.entries.map((e) => ('ar', e)), ...en.entries.map((e) => ('en', e))}) {
      expect(
        entry.$2.value.trim(),
        isNotEmpty,
        reason: '${entry.$1}:${entry.$2.key}',
      );
    }
  });

  test('Arabic messages contain Arabic letters, English ones do not', () {
    final arabicLetter = RegExp('[ء-ي]');
    // "English" is the language name shown in its own script on purpose.
    const ownScript = {'languageEn'};
    for (final e in ar.entries) {
      if (ownScript.contains(e.key)) continue;
      expect(arabicLetter.hasMatch(e.value), isTrue, reason: 'ar:${e.key}');
    }
    for (final e in en.entries) {
      if (ownScript.contains(e.key) || e.key == 'languageAr') continue;
      expect(arabicLetter.hasMatch(e.value), isFalse, reason: 'en:${e.key}');
    }
  });
}
