import 'dart:typed_data';

import 'package:sprint/core/data/change_signal.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/identity/domain/identity_repository.dart';
import 'package:sprint/features/identity/domain/verification.dart';
import 'package:sprint/features/verification/domain/sheet_batch.dart';
import 'package:sprint/features/verification/domain/tier.dart' as rules;
import 'package:sprint/features/verification/domain/verification_repository.dart';

/// TEMPORARY SHIM (T020), replaced by the full implementation in T027. It
/// only holds the Foundation's verifications and answers `current`, `history`
/// and `tierFor`; every write refuses with [NotPermitted].
class InMemoryVerificationRepository
    with ChangeSignal
    implements VerificationRepository {
  InMemoryVerificationRepository({
    required Iterable<Verification> verifications,
    required this.identity,
  }) : _all = [...verifications];

  final List<Verification> _all;
  final IdentityRepository identity;

  /// Everything, for the demo snapshot.
  List<Verification> get allVerifications => List.unmodifiable(_all);

  @override
  Future<List<Verification>> history(String userId) async =>
      (_all.where((v) => v.userId == userId).toList()
        ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt)));

  @override
  Future<Verification?> current(String userId) async {
    final h = await history(userId);
    return h.isEmpty ? null : h.first;
  }

  /// Seeding hook for tests and the demo; not part of the interface.
  Future<void> put(Verification v) async {
    _all
      ..removeWhere((e) => e.id == v.id)
      ..add(v);
    notifyChanged();
  }

  @override
  Future<PriceTier> tierFor(String userId, DateTime at) async =>
      rules.tierFor(await identity.getUser(userId), await current(userId), at);

  @override
  Future<Result<Verification>> submit({
    required String userId,
    required VerificationType type,
    required String nationalId,
    required String code,
    required String owningUnitId,
    required Uint8List photo,
  }) async => const Err(NotPermitted());

  @override
  Future<Result<List<Verification>>> queue(String reviewerId) async =>
      const Err(NotPermitted());

  @override
  Future<Result<Verification>> request(
    String reviewerId,
    String verificationId,
  ) async => const Err(NotPermitted());

  @override
  Future<Result<Verification>> approve(
    String reviewerId,
    String verificationId,
  ) async => const Err(NotPermitted());

  @override
  Future<Result<Verification>> reject(
    String reviewerId,
    String verificationId,
    String reason,
  ) async => const Err(NotPermitted());

  @override
  Future<Result<SheetBatch>> uploadSheet(
    String reviewerId,
    String fileName,
    String csvText,
  ) async => const Err(NotPermitted());

  @override
  Future<Result<List<SheetBatch>>> batches(String reviewerId) async =>
      const Err(NotPermitted());

  @override
  Future<Result<Uint8List>> photo(String reviewerId, String photoId) async =>
      const Err(NotPermitted());
}
