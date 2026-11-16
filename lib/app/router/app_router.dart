import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/app/shell/adaptive_shell.dart';
import 'package:sprint/app/shell/placeholders/not_found_screen.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/features/demo/demo_flags.dart';
import 'package:sprint/features/demo/presentation/component_gallery/component_gallery_screen.dart';
import 'package:sprint/features/demo/presentation/demo_screen.dart';

/// Builds the app router. Web uses Flutter's default hash URL strategy
/// (`/#/path`), so deep links and refreshes work under the Pages sub-path
/// without server rewrites (research R10); nothing to configure here.
///
/// The route table is built from [destinations], never hard-coded per role
/// (contracts/routes.md rule 4).
///
/// [session] is read on every redirect; [refreshListenable] re-runs the
/// redirects when it changes (sign in, sign out, actAs), contracts/routes.md
/// rules 2 and 5. [extraRoutes] are added outside the shell (auth screens).
GoRouter buildAppRouter({
  List<ShellDestination>? destinations,
  String initialLocation = AppPaths.root,
  bool demoTools = demoToolsEnabled,
  Session Function()? session,
  Listenable? refreshListenable,
  List<RouteBase> extraRoutes = const [],
}) {
  final list = destinations ?? baseDestinations;
  final sessionOf = session ?? () => Session.guest;
  late final GoRouter router;

  /// `from` is accepted only when it is a path this router recognises and is
  /// not an auth route; otherwise Home (rule 3).
  String safeFrom(String? from) {
    if (from == null || !from.startsWith('/') || from.startsWith('//')) {
      return AppPaths.home;
    }
    final uri = Uri.tryParse(from);
    if (uri == null || uri.hasScheme || uri.hasAuthority) return AppPaths.home;
    if (uri.path == AppPaths.root || AppPaths.auth.contains(uri.path)) {
      return AppPaths.home;
    }
    return router.configuration.findMatch(uri).isError
        ? AppPaths.home
        : uri.toString();
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final path = state.uri.path;
    if (path == AppPaths.root) return AppPaths.home;
    final current = sessionOf();
    if (AppPaths.authEntry.contains(path) && !current.isGuest) {
      return safeFrom(state.uri.queryParameters['from']);
    }
    final route = state.topRoute;
    if (route is GatedRoute && route.access.needsAccount && current.isGuest) {
      return AppPaths.signInFrom(state.uri.toString());
    }
    return null;
  }

  router = GoRouter(
    initialLocation: initialLocation,
    refreshListenable: refreshListenable,
    redirect: redirect,
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
      ...extraRoutes,
      // Outside the shell and out of navigation; reached from Profile.
      GoRoute(
        path: AppPaths.demo,
        name: AppRouteNames.demo,
        builder: (context, state) => DemoScreen(showToolLinks: demoTools),
      ),
      if (demoTools)
        GoRoute(
          path: AppPaths.demoComponents,
          name: AppRouteNames.demoComponents,
          builder: (context, state) => const ComponentGalleryScreen(),
        ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) =>
            AdaptiveShell(navigationShell: shell, destinations: list),
        branches: [
          for (final d in list)
            StatefulShellBranch(
              routes: [
                GatedRoute(
                  path: d.path,
                  name: d.name,
                  access: d.access,
                  builder: (context, state) => d.builder(),
                ),
              ],
            ),
        ],
      ),
    ],
  );
  return router;
}
