import 'package:sprint/features/identity/domain/role_assignment.dart';

export 'package:sprint/features/identity/domain/role_assignment.dart'
    show Role, RoleAssignment, RoleScopeType;

/// One row of the BRD §6 matrix.
enum AppAction {
  browse,
  book,
  requestVerification,
  reviewVerification,
  scanAttendance,
  viewFacilityBookings,
  cancelAsAdmin,
  manageHours,
  manageSettings,
  manageFacilities,
  manageTrainers,
  manageAssets,
  reportDamage,
  resolveDamage,
  viewReports,
  assignRoles,
  createSubUnit,
  viewAudit,
}

/// Who is asking. A guest has no user id and no assignments.
class PermissionSubject {
  const PermissionSubject({this.userId, this.assignments = const []});

  static const guest = PermissionSubject();

  final String? userId;
  final List<RoleAssignment> assignments;

  bool get isSignedIn => userId != null;
}

/// What the action is about. Fill every level you know: a facility target
/// carries its owning unit too, so unit-scoped roles can be matched.
class PermissionTarget {
  const PermissionTarget({
    this.owningUnitId,
    this.facilityId,
    this.trainerUserId,
  });

  final String? owningUnitId;
  final String? facilityId;

  /// For trainer sessions: the user id of the session's trainer.
  final String? trainerUserId;
}

/// The single permission entry point (contracts/repositories.md). Screens use
/// it to hide or disable, repositories to refuse.
class PermissionChecker {
  const PermissionChecker();

  // Self actions: any signed-in user, on their own account.
  static const _self = {AppAction.book, AppAction.requestVerification};

  // Trainers reach these only for their own sessions ("حصصه").
  static const _trainerOwn = {
    AppAction.scanAttendance,
    AppAction.viewFacilityBookings,
    AppAction.viewReports,
  };

  static const _staffCommon = {
    AppAction.viewFacilityBookings,
    AppAction.cancelAsAdmin,
    AppAction.manageHours,
    AppAction.manageTrainers,
    AppAction.manageAssets,
    AppAction.reportDamage,
    AppAction.resolveDamage,
    AppAction.viewReports,
  };

  static const _admin = {
    ..._staffCommon,
    AppAction.manageSettings,
    AppAction.manageFacilities,
    AppAction.assignRoles,
    AppAction.viewAudit,
  };

  static const Map<Role, Set<AppAction>> _roleActions = {
    Role.guest: {},
    Role.booker: {},
    Role.trainer: {
      AppAction.scanAttendance,
      AppAction.viewFacilityBookings,
      AppAction.reportDamage,
      AppAction.viewReports,
    },
    Role.facilityManager: {..._staffCommon, AppAction.scanAttendance},
    Role.verifier: {AppAction.reviewVerification},
    Role.unitAdmin: _admin,
    Role.superAdmin: {
      ..._admin,
      AppAction.reviewVerification,
      AppAction.createSubUnit,
    },
    Role.viewer: {AppAction.viewFacilityBookings, AppAction.viewReports},
  };

  bool can(
    PermissionSubject subject,
    AppAction action,
    PermissionTarget target,
  ) {
    if (action == AppAction.browse) return true;
    if (!subject.isSignedIn) return false;
    if (_self.contains(action)) return true;

    for (final a in subject.assignments) {
      if (!(_roleActions[a.role]?.contains(action) ?? false)) continue;
      if (!_covers(a, target)) continue;
      if (a.role == Role.trainer &&
          _trainerOwn.contains(action) &&
          target.trainerUserId != subject.userId) {
        continue;
      }
      return true;
    }
    return false;
  }

  bool _covers(RoleAssignment a, PermissionTarget t) => switch (a.scopeType) {
        RoleScopeType.university => true,
        RoleScopeType.owningUnit =>
          t.owningUnitId != null && t.owningUnitId == a.scopeId,
        RoleScopeType.facility =>
          t.facilityId != null && t.facilityId == a.scopeId,
      };
}
