import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/identity/domain/role_assignment.dart';
import 'package:sprint/features/identity/domain/user.dart';
import 'package:sprint/features/identity/domain/verification.dart';

part 'session_provider.g.dart';

/// Who is using the app: nobody (a guest) or a seeded user chosen with the
/// reviewer switcher. There is no real sign-in in this feature.
class Session {
  const Session({this.user, this.roles = const [], this.tier = PriceTier.external});

  static const guest = Session();

  final User? user;
  final List<RoleAssignment> roles;
  final PriceTier tier;

  bool get isGuest => user == null;
}

@Riverpod(keepAlive: true)
class SessionNotifier extends _$SessionNotifier {
  @override
  Future<Session> build() => _load();

  Future<Session> _load() async {
    final identity = ref.read(identityRepositoryProvider);
    final user = await identity.currentUser();
    if (user == null) return Session.guest;
    final now = ref.read(dataLayerProvider).clock.now();
    return Session(
      user: user,
      roles: await identity.roleAssignments(user.id),
      tier: tierAt(await identity.verification(user.id), now),
    );
  }

  /// Demo only: act as [userId], or as a guest when null (FR-031).
  Future<void> selectUser(String? userId) async {
    await ref.read(identityRepositoryProvider).setCurrentUser(userId);
    state = AsyncData(await _load());
  }
}

/// The session, as a guest until it has loaded.
@Riverpod(keepAlive: true)
Session currentSession(Ref ref) =>
    ref.watch(sessionProvider).value ?? Session.guest;
