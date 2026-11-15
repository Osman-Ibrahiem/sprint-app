import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/adaptive/adaptive_platform_override.dart';
import 'package:sprint/core/adaptive/platform.dart';
import 'package:sprint/core/theme/sprint_theme.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

import 'pump_app.dart';

/// A themed app for one widget, in either language and theme, with an optional
/// platform look and the reviewer's text-scale and reduced-motion settings.
///
/// Reuses [setWindow] so every widget test gets the same 400 × 800 window,
/// text scale and reduced motion handling as the Foundation's tests.
Future<void> pumpWidgetUnder(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('ar'),
  bool dark = false,
  double textScale = 1,
  bool reduceMotion = true,
  AdaptiveStyle? style,
  Size size = const Size(400, 800),
}) async {
  setWindow(
    tester,
    size: size,
    textScale: textScale,
    reduceMotion: reduceMotion,
  );

  final content = style == null
      ? child
      : AdaptivePlatformOverride(style: style, child: child);

  await tester.pumpWidget(
    MaterialApp(
      theme: dark ? SprintTheme.dark : SprintTheme.light,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: Center(
          child: SingleChildScrollView(child: content),
        ),
      ),
    ),
  );
  await tester.pump();
}

/// Pumps and settles, for the widgets whose animation should finish.
Future<void> pumpWidgetUnderAndSettle(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('ar'),
  bool dark = false,
  double textScale = 1,
  bool reduceMotion = true,
  AdaptiveStyle? style,
  Size size = const Size(400, 800),
}) async {
  await pumpWidgetUnder(
    tester,
    child,
    locale: locale,
    dark: dark,
    textScale: textScale,
    reduceMotion: reduceMotion,
    style: style,
    size: size,
  );
  await tester.pumpAndSettle();
}
