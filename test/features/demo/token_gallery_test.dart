import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/l10n/locale_notifier.dart';
import 'package:sprint/features/demo/presentation/demo_screen.dart';
import 'package:sprint/core/theme/theme_mode_notifier.dart';

import '../../helpers/pump_app.dart';

void main() {
  for (final size in [const Size(360, 800), const Size(1000, 800)]) {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      for (final lang in ['ar', 'en']) {
        testWidgets('token gallery: $size $mode $lang renders without overflow',
            (tester) async {
          await pumpSprintApp(tester, size: size);
          final c = containerOf(tester);
          await c.read(themeModeProvider.notifier).set(mode);
          await c.read(localeProvider.notifier).set(Locale(lang));
          routerOf(tester).push('/demo');
          await tester.pumpAndSettle();

          final scrollable = find.byType(Scrollable).first;
          // Walk the whole gallery so every section is laid out.
          for (var i = 0; i < 40; i++) {
            await tester.drag(scrollable, const Offset(0, -400));
            await tester.pump();
          }
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('the gallery is reachable from Profile', (tester) async {
    await pumpSprintApp(tester, size: const Size(400, 900));
    routerOf(tester).go('/profile');
    await tester.pumpAndSettle();
    await tester.tap(find.text(ar.demoEntry));
    await tester.pumpAndSettle();
    expect(find.byType(DemoScreen), findsOneWidget);
    expect(find.text(ar.demoTitle), findsWidgets);
  });

  testWidgets('colour swatches are read as one phrase, not blank boxes',
      (tester) async {
    final handle = tester.ensureSemantics();
    await pumpSprintApp(tester, size: const Size(500, 900));
    routerOf(tester).push('/demo');
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.bySemanticsLabel(ar.demoSwatchLabel('bg')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.bySemanticsLabel(ar.demoSwatchLabel('bg')), findsOneWidget);
    handle.dispose();
  });
}
