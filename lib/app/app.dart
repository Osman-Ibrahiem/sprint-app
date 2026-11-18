import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint/app/router/router_provider.dart';
import 'package:sprint/core/l10n/locale_notifier.dart';
import 'package:sprint/core/scroll/sprint_scroll_behavior.dart';
import 'package:sprint/core/splash/sprint_splash.dart';
import 'package:sprint/core/theme/sprint_theme.dart';
import 'package:sprint/core/theme/theme_mode_notifier.dart';
import 'package:sprint/features/booking/presentation/providers/checkout_providers.dart';
import 'package:sprint/features/notifications/presentation/providers/reminder_providers.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

class SprintApp extends ConsumerWidget {
  const SprintApp({this.showSplash = true, super.key});

  /// Tests turn the splash off; the app always shows it.
  final bool showSplash;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // A dialog, sheet or menu built in one language must not stay open, mixed
    // with the other direction, after the language changes (spec edge case).
    ref.listen(localeProvider, (previous, next) {
      if (previous == next) return;
      ref
          .read(appRouterProvider)
          .routerDelegate
          .navigatorKey
          .currentState
          ?.popUntil((route) => route is! PopupRoute<Object?>);
    });
    // Holds are kept honest anywhere in the app, not only on the checkout
    // screen (FR-004, BR-12, BR-46).
    ref.watch(holdHousekeepingProvider);
    // One reminder per confirmed booking, on build, every minute and on
    // resume (BR-39).
    ref.watch(reminderSchedulerProvider);
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
      builder: (context, child) => SprintSplashGate(
        enabled: showSplash,
        child: child ?? const SizedBox.shrink(),
      ),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
