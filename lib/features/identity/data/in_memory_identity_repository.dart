import 'package:sprint/core/data/change_signal.dart';
import 'package:sprint/features/identity/domain/identity_repository.dart';
import 'package:sprint/features/identity/domain/role_assignment.dart';
import 'package:sprint/features/identity/domain/user.dart';
import 'package:sprint/features/identity/domain/verification.dart';

class InMemoryIdentityRepository with ChangeSignal implements IdentityRepository {
  InMemoryIdentityRepository({
    required Iterable<User> users,
    required Iterable<RoleAssignment> roleAssignments,
    required Iterable<Verification> verifications,
    String? currentUserId,
  })  : _users = [...users],
        _assignments = [...roleAssignments],
        _verifications = {for (final v in verifications) v.userId: v},
        _currentId = currentUserId;

  final List<User> _users;
  final List<RoleAssignment> _assignments;
  final Map<String, Verification> _verifications;
  String? _currentId; // the launch state is a guest

  @override
  Future<User?> currentUser() async => getUser(_currentId ?? '');

  @override
  Future<void> setCurrentUser(String? userId) async {
    _currentId = userId;
    notifyChanged();
  }

  /// The signed-in id, for the demo snapshot (FR-013).
  String? get currentUserId => _currentId;

  /// Everything, for the demo snapshot.
  List<User> get allUsers => List.unmodifiable(_users);
  List<RoleAssignment> get allAssignments => List.unmodifiable(_assignments);
  List<Verification> get allVerifications => _verifications.values.toList();

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

  @override
  Future<Verification?> verification(String userId) async =>
      _verifications[userId];

  /// Seeding hook for tests and the demo; not part of the interface.
  Future<void> putVerification(Verification v) async {
    _verifications[v.userId] = v;
    notifyChanged();
  }
}
