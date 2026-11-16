import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/app/router/app_router.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/theme/sprint_theme.dart';
import 'package:sprint/core/widgets/app_navigation/sprint_tab_bar.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

Widget _app(GoRouter router) => MaterialApp.router(
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
    );

List<ShellDestination> _destinations({List<RouteBase> subRoutes = const []}) => [
      ShellDestination(
        name: 'home',
        path: '/home',
        icon: PhosphorIconsRegular.house,
        selectedIcon: PhosphorIconsFill.house,
        label: (l) => l.navHome,
        builder: () => const Scaffold(body: Text('home-screen')),
      ),
      ShellDestination(
        name: 'facilities',
        path: '/facilities',
        icon: PhosphorIconsRegular.squaresFour,
        selectedIcon: PhosphorIconsFill.squaresFour,
        label: (l) => l.navFacilities,
        builder: () => const Scaffold(body: Text('facilities-screen')),
        subRoutes: subRoutes,
      ),
    ];

void main() {
  testWidgets('a sub-route resolves inside the shell, nav bar still present',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(tester.view.reset);

    final router = buildAppRouter(
      destinations: _destinations(
        subRoutes: [
          GoRoute(
            path: ':id',
            name: 'detail',
            builder: (context, state) =>
                Text('detail-${state.pathParameters['id']}'),
          ),
        ],
      ),
      initialLocation: '/facilities/x',
    );
    await tester.pumpWidget(_app(router));
    await tester.pumpAndSettle();

    expect(find.text('detail-x'), findsOneWidget);
    expect(find.byType(SprintTabBar), findsOneWidget);
    expect(find.text('facilities-screen'), findsNothing);
  });

  testWidgets('a destination without sub-routes behaves as before',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(tester.view.reset);

    final router = buildAppRouter(
      destinations: _destinations(),
      initialLocation: '/home',
    );
    await tester.pumpWidget(_app(router));
    await tester.pumpAndSettle();

    expect(find.text('home-screen'), findsOneWidget);
    expect(find.byType(SprintTabBar), findsOneWidget);
  });
}
