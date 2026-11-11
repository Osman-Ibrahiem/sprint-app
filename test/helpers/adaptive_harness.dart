import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/theme/sprint_theme.dart';

/// Platforms that stand for each adaptive style in tests. Desktop proxies the
/// web/Windows/Linux column of `adaptive.md`.
const apple = {TargetPlatform.iOS, TargetPlatform.macOS};
const android = {TargetPlatform.android};
const desktop = {TargetPlatform.windows, TargetPlatform.linux};

final allPlatforms = TargetPlatformVariant({...apple, ...android, ...desktop});

bool isApple(TargetPlatform p) => apple.contains(p);
bool isDesktop(TargetPlatform p) => desktop.contains(p);

Future<void> pumpHarness(
  WidgetTester tester,
  WidgetBuilder builder, {
  Locale locale = const Locale('ar'),
  bool settle = true,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(800, 900);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: SprintTheme.light,
      locale: locale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: Center(child: Builder(builder: builder))),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}
