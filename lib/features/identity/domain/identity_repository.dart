import 'package:sprint/core/result/result.dart';
import 'package:sprint/features/identity/domain/role_assignment.dart';
import 'package:sprint/features/identity/domain/user.dart';

/// Read access to people and their roles, and the one profile write the
/// booker owns. The signed-in user lives in `AuthRepository`; verification
/// requests in `VerificationRepository` (feature 003, research R2).
abstract interface class IdentityRepository {
  /// Fires after each successful write.
  Stream<void> get changes;

  Future<List<User>> users();
  Future<User?> getUser(String id);
  Future<List<RoleAssignment>> roleAssignments(String userId);

  /// The name trimmed, at least two characters after trimming, else
  /// `InvalidName` (data-model). `avatarId` sets the photo key;
  /// `clearAvatar` removes it. Email, phone and national id never change here.
  Future<Result<User>> updateProfile(
    String userId, {
    required String name,
    String? avatarId,
    bool clearAvatar = false,
  });

  /// The remaining writes of the auth and verification flows, behind the
  /// interface so their callers never reach into the in-memory class.
  void updateUser(User user);
  void addRoleAssignment(RoleAssignment assignment);
}
