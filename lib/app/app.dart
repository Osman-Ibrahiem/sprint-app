import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint/app/router/router_provider.dart';
import 'package:sprint/core/l10n/locale_notifier.dart';
import 'package:sprint/core/scroll/sprint_scroll_behavior.dart';
import 'package:sprint/core/theme/sprint_theme.dart';
import 'package:sprint/core/theme/theme_mode_notifier.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

class SprintApp extends ConsumerWidget {
  const SprintApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      theme: SprintTheme.light,
      darkTheme: SprintTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      scrollBehavior: const SprintScrollBehavior(),
      // Arabic unless the user chose English; never the system language.
      locale: ref.watch(localeProvider),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
