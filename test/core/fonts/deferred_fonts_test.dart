import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/fonts/deferred_fonts.dart';
import 'package:sprint/core/l10n/booking_code_text.dart';
import 'package:sprint/core/theme/sprint_theme.dart';
import 'package:sprint/core/tokens/sprint_text.g.dart';

/// IBM Plex Mono is bundled but loaded on demand (SC-011). These tests keep the
/// two halves honest: the declaration and the loader.
void main() {
  final pubspec = File('pubspec.yaml').readAsStringSync();

  /// The lines of the `fonts:` block, up to the next top-level `flutter` key.
  String fontsBlock() {
    final start = RegExp(
      r'^  fonts:',
      multiLine: true,
    ).firstMatch(pubspec)!.start;
    final end = pubspec.indexOf('\n  # IBM Plex Mono', start);
    return pubspec.substring(start, end);
  }

  group('declaration', () {
    test('Plex Mono is not under fonts:, so it is not loaded at startup', () {
      expect(fontsBlock(), isNot(contains('IBM Plex Mono')));
      expect(fontsBlock(), isNot(contains('IBMPlexMono')));
      // The eagerly loaded families are still declared.
      expect(fontsBlock(), contains('family: Alexandria'));
      expect(fontsBlock(), contains('family: Cairo'));
    });

    test('both Plex Mono files are bundled as assets and exist', () {
      for (final path in deferredMonoAssets.values) {
        expect(pubspec, contains('- $path'), reason: '$path not in assets:');
        expect(File(path).existsSync(), isTrue, reason: '$path is missing');
      }
    });

    test('the deferred weights cover every weight a Plex Mono style uses', () {
      final json = jsonDecode(
        File('docs/design-system/tokens.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      final groups = ((json['type'] as Map<String, dynamic>)['groups'] as List)
          .cast<Map<String, dynamic>>();
      final used = <int>{
        for (final g in groups)
          if (g['family'] == 'mono')
            for (final s in (g['styles'] as List).cast<Map<String, dynamic>>())
              s['fontWeight'] as int,
      };
      expect(used, isNotEmpty);
      expect(deferredMonoAssets.keys.toSet().containsAll(used), isTrue);
    });

    test(
      'the code style falls back to a generic monospace family while loading',
      () {
        expect(SprintText.code.fontFamily, monoFamily);
        expect(SprintText.code.fontFamilyFallback, contains('monospace'));
        expect(SprintText.code.height, isNotNull);
      },
    );
  });

  group('loader', () {
    setUp(debugResetMonoFont);

    testWidgets('loads once and shares the same future', (tester) async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final first = ensureMonoFont();
      final second = ensureMonoFont();
      expect(identical(first, second), isTrue);
      await tester.runAsync(() => first);
    });

    testWidgets('a call after loading completes at once', (tester) async {
      await tester.runAsync(ensureMonoFont);
      var done = false;
      await tester.runAsync(() async {
        await ensureMonoFont();
        done = true;
      });
      expect(done, isTrue);
    });
  });

  group('BookingCodeText', () {
    setUp(debugResetMonoFont);

    testWidgets(
      'shows the code left-to-right inside Arabic and uses the code style',
      (tester) async {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.rtl,
            child: MaterialApp(
              theme: SprintTheme.light,
              home: const Scaffold(body: BookingCodeText('SP-1042')),
            ),
          ),
        );
        await tester.runAsync(ensureMonoFont);
        await tester.pump();

        final text = tester.widget<Text>(find.text('SP-1042'));
        expect(text.textDirection, TextDirection.ltr);
        expect(text.style?.fontFamily, monoFamily);
        expect(text.style?.height, SprintText.code.height);
        final dir = Directionality.of(tester.element(find.text('SP-1042')));
        expect(dir, TextDirection.ltr);
      },
    );
  });
}
