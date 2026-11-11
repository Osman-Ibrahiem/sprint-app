import 'package:sprint/features/identity/domain/role_assignment.dart';
import 'package:sprint/features/identity/domain/user.dart';
import 'package:sprint/features/identity/domain/verification.dart';

/// No passwords or sessions in this feature. The "current user" is demo-only:
/// the app starts as a guest and a reviewer can switch (FR-031).
abstract interface class IdentityRepository {
  /// Null for a guest.
  Future<User?> currentUser();

  /// Demo only. Null returns to guest.
  Future<void> setCurrentUser(String? userId);

  Future<List<User>> users();
  Future<User?> getUser(String id);
  Future<List<RoleAssignment>> roleAssignments(String userId);
  Future<Verification?> verification(String userId);
}
