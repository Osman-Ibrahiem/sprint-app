import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Provider;
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprint/app/router/app_router.dart';
import 'package:sprint/app/router/destinations_provider.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/providers/session_provider.dart';

part 'router_provider.g.dart';

class _SessionRefresh extends ChangeNotifier {
  void notify() => notifyListeners();
}

/// Where the person was, so a router rebuilt for a new set of destinations
/// (a staff sign in adds sections) starts there and `/sign-in?from=` can still
/// send them back (FR-016).
class _LastLocation {
  String? value;
}

final _lastLocationProvider = Provider<_LastLocation>((ref) => _LastLocation());

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  // Rebuilt only when the set of destinations changes.
  ref.watch(destinationPathsProvider);
  // Every session change re-runs the redirects (contracts/routes.md rule 5).
  final refresh = _SessionRefresh();
  ref.onDispose(refresh.dispose);
  ref.listen(currentSessionProvider, (_, _) => refresh.notify());
  final last = ref.read(_lastLocationProvider);
  final router = buildAppRouter(
    destinations: ref.read(destinationsProvider),
    initialLocation: last.value ?? AppPaths.root,
    session: () => ref.read(currentSessionProvider),
    refreshListenable: refresh,
  );
  void remember() =>
      last.value = router.routerDelegate.currentConfiguration.uri.toString();
  router.routerDelegate.addListener(remember);
  ref.onDispose(() => router.routerDelegate.removeListener(remember));
  return router;
}
