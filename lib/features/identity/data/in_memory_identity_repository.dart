import 'package:sprint/core/data/change_signal.dart';
import 'package:sprint/features/identity/domain/identity_repository.dart';
import 'package:sprint/features/identity/domain/role_assignment.dart';
import 'package:sprint/features/identity/domain/user.dart';

class InMemoryIdentityRepository
    with ChangeSignal
    implements IdentityRepository {
  InMemoryIdentityRepository({
    required Iterable<User> users,
    required Iterable<RoleAssignment> roleAssignments,
  }) : _users = [...users],
       _assignments = [...roleAssignments];

  final List<User> _users;
  final List<RoleAssignment> _assignments;

  /// Everything, for the demo snapshot.
  List<User> get allUsers => List.unmodifiable(_users);
  List<RoleAssignment> get allAssignments => List.unmodifiable(_assignments);

  /// Sets the national ID of a person when a verification is approved
  /// (FR-026, BR-27). Not part of the interface: only the verification
  /// repository calls it.
  void setNationalId(String userId, String nationalId) {
    final i = _users.indexWhere((u) => u.id == userId);
    if (i < 0) return;
    _users[i] = _users[i].copyWith(nationalId: nationalId);
    notifyChanged();
  }

  @override
  Future<List<User>> users() async => List.unmodifiable(_users);

  @override
  Future<User?> getUser(String id) async {
    for (final u in _users) {
      if (u.id == id) return u;
    }
    return null;
  }

  @override
  Future<List<RoleAssignment>> roleAssignments(String userId) async =>
      _assignments.where((a) => a.userId == userId).toList();

  /// Writes for the auth repository (feature 003): sign up adds a person,
  /// confirming an email activates them and gives them the `BOOKER` role.
  void addUser(User user) {
    _users.add(user);
    notifyChanged();
  }

  void updateUser(User user) {
    final i = _users.indexWhere((u) => u.id == user.id);
    if (i < 0) return;
    _users[i] = user;
    notifyChanged();
  }

  void addRoleAssignment(RoleAssignment assignment) {
    if (!_assignments.contains(assignment)) _assignments.add(assignment);
    notifyChanged();
  }
}
