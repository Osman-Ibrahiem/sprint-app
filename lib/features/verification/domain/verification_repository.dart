import 'dart:typed_data';

import 'package:sprint/core/result/result.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/identity/domain/verification.dart';
import 'package:sprint/features/verification/domain/sheet_batch.dart';

/// Verification requests, reviewing and sheet uploads
/// (contracts/repositories.md). Failures: `InvalidField`, `AlreadyPending`,
/// `NotSignedIn`, `NoAccess`, `AlreadyDecided`, `OwnRequest`,
/// `ReasonTooShort`, `BadColumns`, `NoValidRows`.
abstract interface class VerificationRepository {
  /// Fires after each successful write.
  Stream<void> get changes;

  /// The person's latest request, or null.
  Future<Verification?> current(String userId);

  /// Newest first.
  Future<List<Verification>> history(String userId);

  Future<Result<Verification>> submit({
    required String userId,
    required VerificationType type,
    required String nationalId,
    required String code,
    required String owningUnitId,
    required Uint8List photo,
  });

  /// Pending requests in the reviewer's scope, oldest first.
  Future<Result<List<Verification>>> queue(String reviewerId);

  Future<Result<Verification>> request(
    String reviewerId,
    String verificationId,
  );

  Future<Result<Verification>> approve(
    String reviewerId,
    String verificationId,
  );

  Future<Result<Verification>> reject(
    String reviewerId,
    String verificationId,
    String reason,
  );

  Future<Result<SheetBatch>> uploadSheet(
    String reviewerId,
    String fileName,
    String csvText,
  );

  /// Newest first.
  Future<Result<List<SheetBatch>>> batches(String reviewerId);

  Future<Result<Uint8List>> photo(String reviewerId, String photoId);

  /// The price tier of [userId] at [at] (research R9).
  Future<PriceTier> tierFor(String userId, DateTime at);
}
