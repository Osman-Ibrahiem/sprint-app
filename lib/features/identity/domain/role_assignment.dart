import 'package:freezed_annotation/freezed_annotation.dart';

part 'role_assignment.freezed.dart';

/// BRD §6. A user may hold several.
enum Role {
  guest,
  booker,
  trainer,
  facilityManager,
  verifier,
  unitAdmin,
  superAdmin,
  viewer,
}

enum RoleScopeType { university, owningUnit, facility }

/// A role at a scope. `university` has no [scopeId]; the others require one.
@freezed
abstract class RoleAssignment with _$RoleAssignment {
  const factory RoleAssignment({
    required String userId,
    required Role role,
    required RoleScopeType scopeType,
    String? scopeId,
  }) = _RoleAssignment;
}
