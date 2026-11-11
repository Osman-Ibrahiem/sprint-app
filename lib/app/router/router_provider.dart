import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprint/app/router/app_router.dart';
import 'package:sprint/app/router/destinations_provider.dart';

part 'router_provider.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  // Rebuilt only when the set of destinations changes.
  ref.watch(destinationPathsProvider);
  return buildAppRouter(destinations: ref.read(destinationsProvider));
}
