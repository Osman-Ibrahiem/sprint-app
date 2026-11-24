import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/theme/sprint_theme.dart';
import 'package:sprint/features/demo/presentation/component_gallery/component_gallery_screen.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

import '../../helpers/no_truncation.dart';
import '../../helpers/pump_app.dart';

/// Decision T1 of refactor 000: no component in the gallery cuts its text at
/// 100%, 150% or 200%, in Arabic and English, measured with the bundled
/// Cairo. No exceptions: the DayStrip v2 (decision 18) passes too.
void main() {
  setUpAll(loadSprintFonts);

  for (final lang in ['ar', 'en']) {
    for (final scale in truncationScales) {
      testWidgets('gallery: no text cut short, $lang x$scale', (tester) async {
        setWindow(
          tester,
          size: const Size(400, 800),
          textScale: scale,
          reduceMotion: true,
        );
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: SprintTheme.light,
              locale: Locale(lang),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: const ComponentGalleryScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final cut = <String>{};
        final position = tester
            .state<ScrollableState>(find.byType(Scrollable).first)
            .position;
        for (var i = 0; i < 400; i++) {
          cut.addAll(truncatedTexts(tester));
          if (position.pixels >= position.maxScrollExtent) break;
          position.jumpTo(
            (position.pixels + 400).clamp(0, position.maxScrollExtent),
          );
          await tester.pump(const Duration(milliseconds: 50));
        }
        expect(cut, isEmpty, reason: 'cut short: $cut');
      });
    }
  }
}
