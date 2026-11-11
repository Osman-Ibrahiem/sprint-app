import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/identity/domain/permission_checker.dart';

/// The role x scope matrix of BRD §6 (SC-009).
void main() {
  const checker = PermissionChecker();

  RoleAssignment grant(
    Role role, {
    RoleScopeType scope = RoleScopeType.university,
    String? scopeId,
    String user = 'u',
  }) =>
      RoleAssignment(userId: user, role: role, scopeType: scope, scopeId: scopeId);

  PermissionSubject subject(List<RoleAssignment> a, {String user = 'u'}) =>
      PermissionSubject(userId: user, assignments: a);

  // A facility f1 owned by ou1; its trainer is the user "u".
  const target = PermissionTarget(
    owningUnitId: 'ou1',
    facilityId: 'f1',
    trainerUserId: 'u',
  );

  // Rows of the BRD matrix. Columns: guest, booker, trainer, facility
  // manager, verifier, unit admin, super admin.
  const rows = <AppAction, List<bool>>{
    AppAction.browse: [true, true, true, true, true, true, true],
    AppAction.book: [false, true, true, true, true, true, true],
    AppAction.requestVerification: [false, true, true, true, true, true, true],
    AppAction.reviewVerification: [false, false, false, false, true, false, true],
    AppAction.scanAttendance: [false, false, true, true, false, false, false],
    AppAction.viewFacilityBookings: [false, false, true, true, false, true, true],
    AppAction.cancelAsAdmin: [false, false, false, true, false, true, true],
    AppAction.manageHours: [false, false, false, true, false, true, true],
    AppAction.manageSettings: [false, false, false, false, false, true, true],
    AppAction.manageFacilities: [false, false, false, false, false, true, true],
    AppAction.manageTrainers: [false, false, false, true, false, true, true],
    AppAction.manageAssets: [false, false, false, true, false, true, true],
    AppAction.reportDamage: [false, false, true, true, false, true, true],
    AppAction.resolveDamage: [false, false, false, true, false, true, true],
    AppAction.viewReports: [false, false, true, true, false, true, true],
    AppAction.assignRoles: [false, false, false, false, false, true, true],
    AppAction.createSubUnit: [false, false, false, false, false, false, true],
    AppAction.viewAudit: [false, false, false, false, false, true, true],
  };
  const columns = [
    null, // guest: no user at all
    Role.booker,
    Role.trainer,
    Role.facilityManager,
    Role.verifier,
    Role.unitAdmin,
    Role.superAdmin,
  ];

  group('matrix at the widest scope', () {
    rows.forEach((action, expected) {
      for (var i = 0; i < columns.length; i++) {
        final role = columns[i];
        test('${role?.name ?? 'guest'} / ${action.name} -> ${expected[i]}', () {
          final s = role == null
              ? PermissionSubject.guest
              : subject([grant(role)]);
          expect(checker.can(s, action, target), expected[i]);
        });
      }
    });
  });

  group('scopes', () {
    test('UNIVERSITY covers every facility and unit', () {
      final s = subject([grant(Role.superAdmin)]);
      for (final t in const [
        PermissionTarget(owningUnitId: 'ou9', facilityId: 'f9'),
        PermissionTarget(owningUnitId: 'ou1'),
        PermissionTarget(),
      ]) {
        expect(checker.can(s, AppAction.manageSettings, t), isTrue);
      }
    });

    test('OWNING_UNIT covers the facilities of that unit only', () {
      final s = subject([
        grant(Role.unitAdmin, scope: RoleScopeType.owningUnit, scopeId: 'ou1'),
      ]);
      expect(
        checker.can(s, AppAction.manageSettings,
            const PermissionTarget(owningUnitId: 'ou1', facilityId: 'f1')),
        isTrue,
      );
      expect(
        checker.can(s, AppAction.manageSettings,
            const PermissionTarget(owningUnitId: 'ou2', facilityId: 'f2')),
        isFalse,
      );
      // A target that names no unit cannot be matched.
      expect(
        checker.can(s, AppAction.manageSettings, const PermissionTarget()),
        isFalse,
      );
    });

    test('FACILITY covers that facility only', () {
      final s = subject([
        grant(Role.facilityManager, scope: RoleScopeType.facility, scopeId: 'f1'),
      ]);
      expect(
        checker.can(s, AppAction.manageHours,
            const PermissionTarget(owningUnitId: 'ou1', facilityId: 'f1')),
        isTrue,
      );
      expect(
        checker.can(s, AppAction.manageHours,
            const PermissionTarget(owningUnitId: 'ou1', facilityId: 'f2')),
        isFalse,
      );
    });

    test('the same role at two scopes sees different data', () {
      final dean = subject([
        grant(Role.unitAdmin, scope: RoleScopeType.owningUnit, scopeId: 'ou1'),
      ]);
      final stadium = subject([
        grant(Role.unitAdmin, scope: RoleScopeType.owningUnit, scopeId: 'ou2'),
      ]);
      const inOu1 = PermissionTarget(owningUnitId: 'ou1', facilityId: 'f1');
      expect(checker.can(dean, AppAction.viewFacilityBookings, inOu1), isTrue);
      expect(checker.can(stadium, AppAction.viewFacilityBookings, inOu1), isFalse);
    });

    test('a user with several roles gets the union', () {
      final s = subject([
        grant(Role.trainer, scope: RoleScopeType.facility, scopeId: 'f1'),
        grant(Role.facilityManager, scope: RoleScopeType.facility, scopeId: 'f2'),
      ]);
      const f1 = PermissionTarget(owningUnitId: 'ou1', facilityId: 'f1', trainerUserId: 'u');
      const f2 = PermissionTarget(owningUnitId: 'ou1', facilityId: 'f2');
      expect(checker.can(s, AppAction.reportDamage, f1), isTrue);
      expect(checker.can(s, AppAction.manageHours, f1), isFalse);
      expect(checker.can(s, AppAction.manageHours, f2), isTrue);
    });
  });

  group('special rules', () {
    test("a trainer reaches only their own sessions", () {
      final s = subject([
        grant(Role.trainer, scope: RoleScopeType.facility, scopeId: 'f1'),
      ]);
      const mine = PermissionTarget(owningUnitId: 'ou1', facilityId: 'f1', trainerUserId: 'u');
      const theirs = PermissionTarget(owningUnitId: 'ou1', facilityId: 'f1', trainerUserId: 'someone');
      for (final a in [
        AppAction.scanAttendance,
        AppAction.viewFacilityBookings,
        AppAction.viewReports,
      ]) {
        expect(checker.can(s, a, mine), isTrue, reason: '$a mine');
        expect(checker.can(s, a, theirs), isFalse, reason: '$a theirs');
      }
    });

    test('a viewer can read bookings and reports but change nothing', () {
      final s = subject([
        grant(Role.viewer, scope: RoleScopeType.owningUnit, scopeId: 'ou1'),
      ]);
      const t = PermissionTarget(owningUnitId: 'ou1', facilityId: 'f1');
      expect(checker.can(s, AppAction.browse, t), isTrue);
      expect(checker.can(s, AppAction.viewFacilityBookings, t), isTrue);
      expect(checker.can(s, AppAction.viewReports, t), isTrue);
      for (final a in AppAction.values) {
        if ({AppAction.browse, AppAction.viewFacilityBookings, AppAction.viewReports}
            .contains(a)) {
          continue;
        }
        if (a == AppAction.book || a == AppAction.requestVerification) continue;
        expect(checker.can(s, a, t), isFalse, reason: '$a');
      }
    });

    test('a verifier is scoped to a unit or the university', () {
      final unit = subject([
        grant(Role.verifier, scope: RoleScopeType.owningUnit, scopeId: 'ou1'),
      ]);
      expect(
        checker.can(unit, AppAction.reviewVerification,
            const PermissionTarget(owningUnitId: 'ou1')),
        isTrue,
      );
      expect(
        checker.can(unit, AppAction.reviewVerification,
            const PermissionTarget(owningUnitId: 'ou2')),
        isFalse,
      );
    });

    test('a unit admin assigns roles only under their own unit', () {
      final s = subject([
        grant(Role.unitAdmin, scope: RoleScopeType.owningUnit, scopeId: 'ou1'),
      ]);
      expect(
        checker.can(s, AppAction.assignRoles,
            const PermissionTarget(owningUnitId: 'ou1')),
        isTrue,
      );
      expect(
        checker.can(s, AppAction.assignRoles,
            const PermissionTarget(owningUnitId: 'ou2')),
        isFalse,
      );
      expect(checker.can(s, AppAction.createSubUnit, const PermissionTarget()),
          isFalse);
    });

    test('any signed-in user can book even without a staff role', () {
      expect(
        checker.can(subject(const []), AppAction.book, const PermissionTarget()),
        isTrue,
      );
    });

    test('a guest can only browse', () {
      for (final a in AppAction.values) {
        expect(
          checker.can(PermissionSubject.guest, a, target),
          a == AppAction.browse,
          reason: '$a',
        );
      }
    });
  });
}
