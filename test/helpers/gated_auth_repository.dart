import 'dart:async';

import 'package:sprint/core/result/result.dart';
import 'package:sprint/features/auth/domain/auth_repository.dart';
import 'package:sprint/features/auth/domain/email_code.dart';

/// Wraps a real repository and holds `signIn` and `signUp` until [release] is called, so a
/// test can look at the loading state. Counts the calls.
class GatedAuthRepository implements AuthRepository {
  GatedAuthRepository(this.inner);

  final AuthRepository inner;
  final _gate = Completer<void>();
  int signInCalls = 0;
  int signUpCalls = 0;

  void release() {
    if (!_gate.isCompleted) _gate.complete();
  }

  @override
  Future<Result<SignedIn>> signIn({
    required String identifier,
    required String password,
  }) async {
    signInCalls++;
    await _gate.future;
    return inner.signIn(identifier: identifier, password: password);
  }

  @override
  Stream<void> get changes => inner.changes;
  @override
  Future<Result<PendingConfirmation>> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    signUpCalls++;
    await _gate.future;
    return inner.signUp(
      name: name,
      phone: phone,
      email: email,
      password: password,
    );
  }

  @override
  Future<Result<SignedIn>> confirmEmail({
    required String email,
    required String code,
  }) => inner.confirmEmail(email: email, code: code);
  @override
  Future<Result<CodeSent>> resendCode({
    required String email,
    required CodePurpose purpose,
  }) => inner.resendCode(email: email, purpose: purpose);
  @override
  Future<Result<Done>> signOut() => inner.signOut();
  @override
  Future<Result<CodeSent>> requestPasswordReset(String identifier) =>
      inner.requestPasswordReset(identifier);
  @override
  Future<Result<SignedIn>> resetPassword({
    required String identifier,
    required String code,
    required String newPassword,
  }) => inner.resetPassword(
    identifier: identifier,
    code: code,
    newPassword: newPassword,
  );
  @override
  Future<String?> currentUserId() => inner.currentUserId();
  @override
  Future<Result<Done>> actAs(String? userId) => inner.actAs(userId);
}
