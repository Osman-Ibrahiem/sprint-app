import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/app_router.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/theme/sprint_theme.dart';
import 'package:sprint/features/demo/presentation/component_gallery/component_gallery_screen.dart';
import 'package:sprint/features/demo/presentation/demo_screen.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('with demo tools hidden the link is absent', (tester) async {
    setWindow(tester);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: SprintTheme.light,
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const DemoScreen(showToolLinks: false),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(ar.galleryOpenFromDemo), findsNothing);
  });

  testWidgets('with demo tools hidden the route is not registered',
      (tester) async {
    setWindow(tester);
    final router = buildAppRouter(demoTools: false);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          theme: SprintTheme.light,
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    router.go(AppPaths.demoComponents);
    await tester.pumpAndSettle();
    expect(find.byType(ComponentGalleryScreen), findsNothing);
  });
}
