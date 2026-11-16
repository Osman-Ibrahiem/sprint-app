import 'package:sprint/core/data/change_signal.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/features/auth/domain/auth_repository.dart';
import 'package:sprint/features/auth/domain/email_code.dart';
import 'package:sprint/features/identity/domain/identity_repository.dart';

/// TEMPORARY SHIM (T020), replaced by the full implementation in T025. It
/// only carries the signed-in user id (moved from the Foundation's identity
/// repository) and `actAs`; every other method refuses with [NotPermitted].
class InMemoryAuthRepository with ChangeSignal implements AuthRepository {
  InMemoryAuthRepository({required this.identity, String? currentUserId})
    : _currentId = currentUserId;

  final IdentityRepository identity;
  String? _currentId; // the launch state is a guest

  /// The signed-in id, for the demo snapshot (FR-013).
  String? get signedInUserId => _currentId;

  @override
  Future<String?> currentUserId() async =>
      await identity.getUser(_currentId ?? '') == null ? null : _currentId;

  @override
  Future<Result<Done>> actAs(String? userId) async {
    _currentId = userId;
    notifyChanged();
    return const Ok(Done());
  }

  @override
  Future<Result<Done>> signOut() => actAs(null);

  @override
  Future<Result<PendingConfirmation>> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async => const Err(NotPermitted());

  @override
  Future<Result<SignedIn>> confirmEmail({
    required String email,
    required String code,
  }) async => const Err(NotPermitted());

  @override
  Future<Result<CodeSent>> resendCode({
    required String email,
    required CodePurpose purpose,
  }) async => const Err(NotPermitted());

  @override
  Future<Result<SignedIn>> signIn({
    required String identifier,
    required String password,
  }) async => const Err(NotPermitted());

  @override
  Future<Result<CodeSent>> requestPasswordReset(String identifier) async =>
      const Err(NotPermitted());

  @override
  Future<Result<SignedIn>> resetPassword({
    required String identifier,
    required String code,
    required String newPassword,
  }) async => const Err(NotPermitted());
}
