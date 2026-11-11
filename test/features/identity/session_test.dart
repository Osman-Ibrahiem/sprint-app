import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/destinations.dart';
import 'package:sprint/app/router/destinations_provider.dart';
import 'package:sprint/app/router/router_provider.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/identity/domain/app_section.dart';

void main() {
  final trainerDestination = ShellDestination(
    name: 'trainer',
    path: '/trainer',
    icon: Icons.sports,
    selectedIcon: Icons.sports,
    label: (l) => l.navHome,
    builder: () => const SizedBox.shrink(),
  );

  ProviderContainer container({bool withTrainerScreen = false}) {
    final c = ProviderContainer(
      overrides: [
        if (withTrainerScreen)
          destinationRegistryProvider.overrideWith(
            (ref) => {
              ...baseRegistry,
              AppSection.trainerSessions: trainerDestination,
            },
          ),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('the app starts as a guest with the four destinations', () async {
    final c = container();
    final session = await c.read(sessionProvider.future);
    expect(session.isGuest, isTrue);
    expect(c.read(destinationsProvider), hasLength(4));
  });

  test('switching to a booker keeps four destinations and the same router',
      () async {
    final c = container();
    await c.read(sessionProvider.future);
    final router = c.read(appRouterProvider);

    await c.read(sessionProvider.notifier).selectUser(SeedIds.bookerInternal);
    final s = c.read(currentSessionProvider);
    expect(s.user!.id, SeedIds.bookerInternal);
    expect(s.tier, PriceTier.internal);
    expect(c.read(destinationsProvider), hasLength(4));
    expect(identical(c.read(appRouterProvider), router), isTrue,
        reason: 'the router is not rebuilt when the destinations are equal');
  });

  test('the tier follows verification: external, pending and expired',
      () async {
    final c = container();
    await c.read(sessionProvider.future);
    final n = c.read(sessionProvider.notifier);
    for (final id in [
      SeedIds.bookerExternal,
      SeedIds.userUnverified,
      SeedIds.userExpired,
    ]) {
      await n.selectUser(id);
      expect(c.read(currentSessionProvider).tier, PriceTier.external, reason: id);
    }
  });

  test('a trainer gets an extra destination when a screen exists for it',
      () async {
    final c = container(withTrainerScreen: true);
    await c.read(sessionProvider.future);
    await c.read(sessionProvider.notifier).selectUser(SeedIds.trainer1);
    final d = c.read(destinationsProvider);
    expect(d, hasLength(5));
    expect(d.last.path, '/trainer');

    // And back to a guest: four again.
    await c.read(sessionProvider.notifier).selectUser(null);
    expect(c.read(destinationsProvider), hasLength(4));
  });

  test('without a trainer screen a trainer still sees four', () async {
    final c = container();
    await c.read(sessionProvider.future);
    await c.read(sessionProvider.notifier).selectUser(SeedIds.trainer1);
    expect(c.read(destinationsProvider), hasLength(4));
  });
}
