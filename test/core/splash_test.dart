import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/splash/sprint_splash.dart';
import 'package:sprint/core/theme/sprint_theme.dart';
import 'package:sprint/core/tokens/sprint_colors.g.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

Widget _app({required ThemeData theme, bool reduced = false}) => MaterialApp(
  theme: theme,
  locale: const Locale('ar'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
    child: SprintSplashGate(
      hold: const Duration(milliseconds: 100),
      child: child!,
    ),
  ),
  home: const Scaffold(body: Text('app')),
);

void main() {
  testWidgets('splash is primary in both themes', (tester) async {
    for (final theme in [SprintTheme.light, SprintTheme.dark]) {
      await tester.pumpWidget(_app(theme: theme));
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        tester
            .widget<ColoredBox>(
              find
                  .descendant(
                    of: find.byType(SprintSplash),
                    matching: find.byType(ColoredBox),
                  )
                  .first,
            )
            .color,
        SprintColors.light.primary,
      );
    }
  });

  testWidgets('runs the sequence, then reveals the app', (tester) async {
    await tester.pumpWidget(_app(theme: SprintTheme.light));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('سبرنت'), findsOneWidget);
    expect(find.text('احجز من غير زحمة'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();
    expect(find.byType(SprintSplash), findsNothing);
    expect(find.text('app'), findsOneWidget);
  });

  testWidgets('reduced motion starts at step 3', (tester) async {
    await tester.pumpWidget(_app(theme: SprintTheme.light, reduced: true));
    await tester.pump();
    final tagline = tester.widget<Opacity>(
      find.ancestor(
        of: find.text('احجز من غير زحمة'),
        matching: find.byType(Opacity),
      ),
    );
    expect(tagline.opacity, 1);
    await tester.pumpAndSettle();
    expect(find.byType(SprintSplash), findsNothing);
  });

  testWidgets('loader and caption sit at the same offsets on every width '
      '(decision 10)', (tester) async {
    addTearDown(tester.view.reset);
    for (final width in [390.0, 720.0, 1194.0, 1440.0]) {
      tester.view
        ..devicePixelRatio = 1
        ..physicalSize = Size(width, 900);
      // A fresh gate each time, so the splash shows again.
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(_app(theme: SprintTheme.light, reduced: true));
      await tester.pump();
      final height = tester.view.physicalSize.height;
      expect(
        height - tester.getBottomLeft(find.byKey(SprintSplash.loaderKey)).dy,
        SprintSplash.loaderBottom,
        reason: 'loader at width $width',
      );
      expect(
        height - tester.getBottomLeft(find.byKey(SprintSplash.captionKey)).dy,
        SprintSplash.captionBottom,
        reason: 'caption at width $width',
      );
      await tester.pumpAndSettle();
    }
  });
}
