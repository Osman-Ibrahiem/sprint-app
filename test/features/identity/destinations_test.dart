import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/destinations.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/features/identity/domain/app_section.dart';
import 'package:sprint/features/identity/domain/role_assignment.dart';

/// The shell destinations are computed from role assignments (FR-007, FR-031).
void main() {
  RoleAssignment grant(Role r) => RoleAssignment(
        userId: 'u',
        role: r,
        scopeType: RoleScopeType.university,
      );

  const base = [
    AppSection.home,
    AppSection.facilities,
    AppSection.bookings,
    AppSection.profile,
  ];

  group('sections from roles', () {
    test('a guest gets the four base sections', () {
      expect(sectionsFor(const []), base);
    });

    test('a booker gets the same four', () {
      expect(sectionsFor([grant(Role.booker)]), base);
    });

    test('a trainer gets the base four plus trainer sessions', () {
      expect(
        sectionsFor([grant(Role.trainer)]),
        [...base, AppSection.trainerSessions],
      );
    });

    test('staff roles add their own sections', () {
      expect(sectionsFor([grant(Role.facilityManager)]),
          contains(AppSection.facilityOps));
      expect(sectionsFor([grant(Role.verifier)]),
          contains(AppSection.verification));
      expect(sectionsFor([grant(Role.unitAdmin)]),
          contains(AppSection.administration));
      expect(sectionsFor([grant(Role.superAdmin)]),
          contains(AppSection.administration));
      expect(sectionsFor([grant(Role.viewer)]), contains(AppSection.reports));
    });

    test('several roles never duplicate a section and keep a stable order', () {
      final s = sectionsFor([
        grant(Role.superAdmin),
        grant(Role.unitAdmin),
        grant(Role.trainer),
        grant(Role.booker),
      ]);
      expect(s.toSet().length, s.length);
      expect(s.take(4), base);
      // Stable: always in the order of the enum.
      expect(s, AppSection.values.where(s.contains).toList());
    });
  });

  group('destinations from sections', () {
    // A trainer fixture destination, registered in the test only: the app has
    // no trainer screen yet.
    final trainerDestination = ShellDestination(
      name: 'trainer',
      path: '/trainer',
      icon: Icons.sports,
      selectedIcon: Icons.sports,
      label: (l) => l.navHome,
      builder: () => const SizedBox.shrink(),
    );

    test('guest and booker both get the four registered destinations', () {
      for (final roles in [const <RoleAssignment>[], [grant(Role.booker)]]) {
        final d = destinationsFor(sectionsFor(roles), registry: baseRegistry);
        expect(d.map((x) => x.path), [
          AppPaths.home,
          AppPaths.facilities,
          AppPaths.bookings,
          AppPaths.profile,
        ]);
      }
    });

    test('a trainer fixture gets an extra destination, proved by data', () {
      final registry = {
        ...baseRegistry,
        AppSection.trainerSessions: trainerDestination,
      };
      final d = destinationsFor(
        sectionsFor([grant(Role.trainer)]),
        registry: registry,
      );
      expect(d, hasLength(5));
      expect(d.last.path, '/trainer');
    });

    test('a section with no registered screen is not shown', () {
      final d = destinationsFor(
        sectionsFor([grant(Role.trainer), grant(Role.unitAdmin)]),
        registry: baseRegistry,
      );
      expect(d, hasLength(4));
    });
  });
}
