import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprint/app/router/app_router.dart';
import 'package:sprint/app/router/destinations_provider.dart';
import 'package:sprint/core/providers/session_provider.dart';

part 'router_provider.g.dart';

class _SessionRefresh extends ChangeNotifier {
  void notify() => notifyListeners();
}

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  // Rebuilt only when the set of destinations changes.
  ref.watch(destinationPathsProvider);
  // Every session change re-runs the redirects (contracts/routes.md rule 5).
  final refresh = _SessionRefresh();
  ref.onDispose(refresh.dispose);
  ref.listen(currentSessionProvider, (_, _) => refresh.notify());
  return buildAppRouter(
    destinations: ref.read(destinationsProvider),
    session: () => ref.read(currentSessionProvider),
    refreshListenable: refresh,
  );
}
