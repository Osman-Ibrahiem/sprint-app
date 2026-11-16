import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/adaptive/adaptive_pressable.dart';
import 'package:sprint/core/l10n/locale_notifier.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/theme/theme_mode_notifier.dart';

import '../../../helpers/pump_app.dart';

/// Every catalogue screen at every width, language, theme and text scale: no
/// overflow, no error and every tap target at least 48 (FR-030 – FR-032,
/// SC-005).
void main() {
  const widths = [400.0, 700.0, 1000.0, 1300.0];
  final paths = [
    '/home',
    '/facilities',
    '/facilities/${SeedIds.poolFacility}',
    '/facilities/${SeedIds.academyFacility}',
  ];

  for (final width in widths) {
    for (final lang in ['ar', 'en']) {
      for (final dark in [false, true]) {
        for (final scale in [1.0, 2.0]) {
          final name = '$width $lang${dark ? ' dark' : ''} x$scale';
          testWidgets('no overflow and 48dp targets at $name', (tester) async {
            await pumpSprintApp(tester,
                size: Size(width, 900), textScale: scale);
            final c = containerOf(tester);
            await c.read(localeProvider.notifier).set(Locale(lang));
            await c
                .read(themeModeProvider.notifier)
                .set(dark ? ThemeMode.dark : ThemeMode.light);
            await tester.pumpAndSettle();
            for (final path in paths) {
              routerOf(tester).go(path);
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull, reason: path);
              _expectTargets(tester, path);
            }
          });
        }
      }
    }
  }

  test('no hard-coded left/right alignment in the catalogue screens', () {
    final bad = RegExp(
      r'Alignment\.(centerLeft|centerRight|topLeft|topRight|bottomLeft|bottomRight)|'
      r'EdgeInsets\.(only|fromLTRB)\(.*(left|right)|TextAlign\.(left|right)|Positioned\(',
    );
    for (final f in Directory('lib/features/catalogue/presentation')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      expect(bad.hasMatch(f.readAsStringSync()), isFalse, reason: f.path);
    }
  });
}

/// Render sizes, not semantics rects: those are clipped by scroll viewports.
void _expectTargets(WidgetTester tester, String path) {
  final finders = [
    find.byType(AdaptivePressable),
    find.byType(IconButton),
    find.byType(SprintButton),
  ];
  for (final finder in finders) {
    for (final element in finder.evaluate()) {
      final box = element.renderObject as RenderBox?;
      if (box == null || !box.hasSize) continue;
      expect(box.size.height, greaterThanOrEqualTo(47.9),
          reason: '${element.widget.runtimeType} on $path is ${box.size}');
      expect(box.size.width, greaterThanOrEqualTo(47.9),
          reason: '${element.widget.runtimeType} on $path is ${box.size}');
    }
  }
}
