import 'package:sprint/features/identity/domain/role_assignment.dart';
import 'package:sprint/features/identity/domain/user.dart';

/// Read access to people and their roles. The signed-in user lives in
/// `AuthRepository`; verification requests in `VerificationRepository`
/// (feature 003, research R2).
abstract interface class IdentityRepository {
  /// Fires after each successful write.
  Stream<void> get changes;

  Future<List<User>> users();
  Future<User?> getUser(String id);
  Future<List<RoleAssignment>> roleAssignments(String userId);
}
