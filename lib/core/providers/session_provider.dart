import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/features/auth/domain/auth_repository.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/identity/domain/role_assignment.dart';
import 'package:sprint/features/identity/domain/user.dart';
import 'package:sprint/features/identity/domain/verification.dart';
import 'package:sprint/features/verification/domain/tier.dart';

part 'session_provider.g.dart';

/// Who is using the app: nobody (a guest) or a signed-in person with their
/// roles, current verification and the price tier derived from them with
/// `tierFor` (FR-012, FR-040, research R9).
class Session {
  const Session({
    this.user,
    this.roles = const [],
    this.verification,
    this.tier = PriceTier.external,
  });

  static const guest = Session();

  final User? user;
  final List<RoleAssignment> roles;
  final Verification? verification;
  final PriceTier tier;

  bool get isGuest => user == null;
}

@Riverpod(keepAlive: true)
class SessionNotifier extends _$SessionNotifier {
  Timer? _expiry;
  int _generation = 0;

  @override
  Future<Session> build() {
    final subs = <StreamSubscription<void>>[
      ref.read(authRepositoryProvider).changes.listen((_) => _reload()),
      ref.read(identityRepositoryProvider).changes.listen((_) => _reload()),
      ref.read(verificationRepositoryProvider).changes.listen((_) => _reload()),
    ];
    ref.onDispose(() {
      for (final s in subs) {
        s.cancel();
      }
      _expiry?.cancel();
    });
    return _load();
  }

  Future<Session> _load() async {
    final identity = ref.read(identityRepositoryProvider);
    final userId = await ref.read(authRepositoryProvider).currentUserId();
    final user = userId == null ? null : await identity.getUser(userId);
    if (user == null) {
      _scheduleExpiry(null);
      return Session.guest;
    }
    final verification = await ref
        .read(verificationRepositoryProvider)
        .current(user.id);
    final now = ref.read(appClockProvider).now();
    _scheduleExpiry(verification);
    return Session(
      user: user,
      roles: await identity.roleAssignments(user.id),
      verification: verification,
      tier: tierFor(user, verification, now),
    );
  }

  /// One timer at the current verification's `expiresAt`, so expiry shows
  /// during a session (research R9, FR-042).
  void _scheduleExpiry(Verification? verification) {
    _expiry?.cancel();
    _expiry = null;
    final at = verification?.expiresAt;
    if (verification == null ||
        verification.status != VerificationStatus.approved ||
        at == null) {
      return;
    }
    final wait = at.difference(ref.read(appClockProvider).now());
    if (wait.isNegative || wait == Duration.zero) return;
    _expiry = Timer(wait, _reload);
  }

  Future<void> _reload() async {
    final generation = ++_generation;
    final session = await _load();
    // A newer reload started meanwhile: let it have the last word.
    if (generation == _generation) state = AsyncData(session);
  }

  /// Signs in and refreshes the session. The result is the repository's, so
  /// the screen can show the failure (FR-010, FR-011).
  Future<Result<SignedIn>> signIn({
    required String identifier,
    required String password,
  }) async {
    final result = await ref
        .read(authRepositoryProvider)
        .signIn(identifier: identifier, password: password);
    if (result.isOk) await _reload();
    return result;
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    await _reload();
  }

  /// Demo only: act as [userId], or as a guest when null (FR-015, FR-031).
  Future<void> actAs(String? userId) async {
    await ref.read(authRepositoryProvider).actAs(userId);
    await _reload();
  }

  /// Re-reads everything, for flows that sign in through the repository
  /// directly (sign up confirmation, password reset).
  Future<void> refresh() => _reload();
}

/// The session, as a guest until it has loaded.
@Riverpod(keepAlive: true)
Session currentSession(Ref ref) =>
    ref.watch(sessionProvider).value ?? Session.guest;
