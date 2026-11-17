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
  testWidgets('light splash uses primary, dark uses bg', (tester) async {
    await tester.pumpWidget(_app(theme: SprintTheme.light));
    await tester.pump();
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
    await tester.pumpWidget(_app(theme: SprintTheme.dark));
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
      SprintColors.dark.bg,
    );
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
}
