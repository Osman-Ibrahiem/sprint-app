import 'package:sprint/features/identity/domain/role_assignment.dart';

/// The units a reviewer may decide for (FR-032), derived from their roles.
sealed class ReviewerScope {
  const ReviewerScope();

  /// No access: not a reviewer.
  static const none = UnitsScope({});

  /// From [assignments]: `SUPER_ADMIN` anywhere, or `VERIFIER` at
  /// `UNIVERSITY`, sees every unit; `VERIFIER` at `OWNING_UNIT` sees those
  /// units (several add up); anything else sees none.
  factory ReviewerScope.from(Iterable<RoleAssignment> assignments) {
    final units = <String>{};
    for (final a in assignments) {
      if (a.role == Role.superAdmin ||
          (a.role == Role.verifier &&
              a.scopeType == RoleScopeType.university)) {
        return const AllUnits();
      }
      if (a.role == Role.verifier &&
          a.scopeType == RoleScopeType.owningUnit &&
          a.scopeId != null) {
        units.add(a.scopeId!);
      }
    }
    return UnitsScope(units);
  }

  bool get isReviewer;

  bool covers(String owningUnitId);
}

final class AllUnits extends ReviewerScope {
  const AllUnits();

  @override
  bool get isReviewer => true;

  @override
  bool covers(String owningUnitId) => true;
}

final class UnitsScope extends ReviewerScope {
  const UnitsScope(this.unitIds);

  final Set<String> unitIds;

  @override
  bool get isReviewer => unitIds.isNotEmpty;

  @override
  bool covers(String owningUnitId) => unitIds.contains(owningUnitId);
}
