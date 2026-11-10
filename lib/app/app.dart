import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:sprint/core/scroll/sprint_scroll_behavior.dart';
import 'package:sprint/core/theme/sprint_theme.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

// Placeholder router; replaced by the shell router in T028/T029.
final _placeholderRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => Scaffold(
        body: Center(child: Text(AppLocalizations.of(context).appName)),
      ),
    ),
  ],
);

class SprintApp extends StatelessWidget {
  const SprintApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      theme: SprintTheme.light,
      darkTheme: SprintTheme.dark,
      themeMode: ThemeMode.system,
      scrollBehavior: const SprintScrollBehavior(),
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: _placeholderRouter,
    );
  }
}
