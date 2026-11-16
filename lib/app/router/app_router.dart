import 'package:go_router/go_router.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/app/shell/adaptive_shell.dart';
import 'package:sprint/app/shell/placeholders/not_found_screen.dart';
import 'package:sprint/features/demo/demo_flags.dart';
import 'package:sprint/features/demo/presentation/component_gallery/component_gallery_screen.dart';
import 'package:sprint/features/demo/presentation/demo_screen.dart';

/// Builds the app router. Web uses Flutter's default hash URL strategy
/// (`/#/path`), so deep links and refreshes work under the Pages sub-path
/// without server rewrites (research R10); nothing to configure here.
///
/// The route table is built from [destinations], never hard-coded per role
/// (contracts/routes.md rule 4).
GoRouter buildAppRouter({
  List<ShellDestination>? destinations,
  String initialLocation = AppPaths.root,
  bool demoTools = demoToolsEnabled,
}) {
  final list = destinations ?? baseDestinations;
  return GoRouter(
    initialLocation: initialLocation,
    redirect: (context, state) =>
        state.uri.path == AppPaths.root ? AppPaths.home : null,
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
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
                GoRoute(
                  path: d.path,
                  name: d.name,
                  builder: (context, state) => d.builder(),
                  routes: d.subRoutes,
                ),
              ],
            ),
        ],
      ),
    ],
  );
}
