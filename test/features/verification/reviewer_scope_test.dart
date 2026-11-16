import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/identity/domain/role_assignment.dart';
import 'package:sprint/features/verification/domain/reviewer_scope.dart';

/// FR-032: which units a reviewer may decide for.
void main() {
  RoleAssignment r(Role role, RoleScopeType scope, [String? id]) =>
      RoleAssignment(userId: 'u', role: role, scopeType: scope, scopeId: id);

  test('university verifier sees all units', () {
    final s = ReviewerScope.from([r(Role.verifier, RoleScopeType.university)]);
    expect(s.isReviewer, isTrue);
    expect(s.covers('ou-pe'), isTrue);
    expect(s.covers('ou-eng'), isTrue);
  });

  test('super admin sees all units', () {
    final s = ReviewerScope.from([
      r(Role.superAdmin, RoleScopeType.university),
    ]);
    expect(s, isA<AllUnits>());
    expect(s.covers('anything'), isTrue);
  });

  test('unit verifier sees only that unit', () {
    final s = ReviewerScope.from([
      r(Role.verifier, RoleScopeType.owningUnit, 'ou-pe'),
    ]);
    expect(s.isReviewer, isTrue);
    expect(s.covers('ou-pe'), isTrue);
    expect(s.covers('ou-eng'), isFalse);
  });

  test('several unit assignments add up', () {
    final s = ReviewerScope.from([
      r(Role.verifier, RoleScopeType.owningUnit, 'ou-pe'),
      r(Role.verifier, RoleScopeType.owningUnit, 'ou-eng'),
    ]);
    expect(s.covers('ou-pe'), isTrue);
    expect(s.covers('ou-eng'), isTrue);
    expect(s.covers('ou-med'), isFalse);
  });

  test('other roles see nothing', () {
    final s = ReviewerScope.from([
      r(Role.booker, RoleScopeType.university),
      r(Role.unitAdmin, RoleScopeType.owningUnit, 'ou-pe'),
      r(Role.viewer, RoleScopeType.owningUnit, 'ou-pe'),
      r(Role.facilityManager, RoleScopeType.facility, 'f1'),
    ]);
    expect(s.isReviewer, isFalse);
    expect(s.covers('ou-pe'), isFalse);
  });

  test('no assignments see nothing', () {
    expect(ReviewerScope.from(const []).isReviewer, isFalse);
    expect(ReviewerScope.none.covers('ou-pe'), isFalse);
  });
}
