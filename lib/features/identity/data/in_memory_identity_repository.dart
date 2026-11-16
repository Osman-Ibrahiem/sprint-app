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
}
