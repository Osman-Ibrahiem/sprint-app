import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprint/app/router/destinations.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/features/identity/domain/app_section.dart';

part 'destinations_provider.g.dart';

/// Which section has a screen. Override in tests to prove role-specific
/// destinations; features add their own as they arrive.
@Riverpod(keepAlive: true)
Map<AppSection, ShellDestination> destinationRegistry(Ref ref) => baseRegistry;

/// The shell destinations for the current user's roles (FR-007, FR-031).
@Riverpod(keepAlive: true)
List<ShellDestination> destinations(Ref ref) {
  final session = ref.watch(currentSessionProvider);
  return destinationsFor(
    sectionsFor(session.roles),
    registry: ref.watch(destinationRegistryProvider),
  );
}

/// A stable key of the destination paths, so the router is rebuilt only when
/// the set of destinations really changes (guest and booker share the same).
@Riverpod(keepAlive: true)
String destinationPaths(Ref ref) =>
    ref.watch(destinationsProvider).map((d) => d.path).join('|');
