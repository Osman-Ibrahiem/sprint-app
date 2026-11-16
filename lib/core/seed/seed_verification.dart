import 'dart:math';

import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/seed/seed_users.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/features/auth/domain/credential.dart';
import 'package:sprint/features/auth/domain/password_hasher.dart';
import 'package:sprint/features/identity/domain/verification.dart';
import 'package:sprint/features/verification/domain/sheet_batch.dart';
import 'package:sprint/features/verification/domain/sheet_row.dart';

// FR-048. National IDs are fictional but valid per the national ID rule.

/// [SeedIds.demoPassword] hashed for every seed person (research R3). Sign-in
/// is blocked by account status, not by the credential, so all are active.
List<Credential> seedCredentials() {
  final random = Random(2026);
  return [
    for (final u in seedUsers)
      () {
        final h = PasswordHasher.hash(SeedIds.demoPassword, random: random);
        return Credential(userId: u.id, salt: h.salt, hash: h.hash);
      }(),
  ];
}

/// Approved student (internal), pending in `ou-pe` (دينا محمود), expired staff,
/// pending in `ou-eng` (outside the seed verifier's unit), and a rejection
/// with its reason (BR-26).
List<Verification> seedVerifications(DateTime now) {
  final today = CairoTime.toCairo(now);
  DateTime day(int offset) =>
      CairoTime.atWallClock(today.year, today.month, today.day + offset);
  return [
    Verification(
      id: SeedIds.verBookerInternal,
      userId: SeedIds.bookerInternal,
      type: VerificationType.student,
      nationalId: '29901010100011',
      code: '20210001',
      owningUnitId: SeedIds.ouPe,
      status: VerificationStatus.approved,
      method: VerificationMethod.auto,
      photoId: SeedIds.placeholderPhotoId,
      submittedAt: day(-90),
      decidedAt: day(-90),
      expiresAt: day(200),
    ),
    Verification(
      id: SeedIds.verUnverified,
      userId: SeedIds.userUnverified,
      type: VerificationType.student,
      nationalId: '30003030300033',
      code: '20220002',
      owningUnitId: SeedIds.ouPe,
      status: VerificationStatus.pending,
      method: VerificationMethod.manual,
      photoId: SeedIds.placeholderPhotoId,
      submittedAt: day(-1),
    ),
    Verification(
      id: SeedIds.verExpired,
      userId: SeedIds.userExpired,
      type: VerificationType.staff,
      nationalId: '29804040400044',
      code: 'ST-0044',
      owningUnitId: SeedIds.ouPe,
      status: VerificationStatus.approved,
      method: VerificationMethod.manual,
      photoId: SeedIds.placeholderPhotoId,
      reviewerId: SeedIds.verifier,
      submittedAt: day(-400),
      decidedAt: day(-395),
      expiresAt: day(-30),
    ),
    Verification(
      id: SeedIds.verEngPending,
      userId: SeedIds.userEngPending,
      type: VerificationType.student,
      nationalId: '30101011100055',
      code: '20230055',
      owningUnitId: SeedIds.ouEng,
      status: VerificationStatus.pending,
      method: VerificationMethod.manual,
      photoId: SeedIds.placeholderPhotoId,
      submittedAt: day(-2),
    ),
    Verification(
      id: SeedIds.verRejected,
      userId: SeedIds.userRejected,
      type: VerificationType.student,
      nationalId: '29705051400066',
      code: '20190066',
      owningUnitId: SeedIds.ouPe,
      status: VerificationStatus.rejected,
      method: VerificationMethod.manual,
      photoId: SeedIds.placeholderPhotoId,
      reviewerId: SeedIds.verifier,
      reason: 'صورة البطاقة غير واضحة، برجاء رفع صورة أوضح.',
      submittedAt: day(-5),
      decidedAt: day(-4),
    ),
  ];
}

/// One batch already uploaded by the seed verifier for `ou-pe`: كريم السيد's
/// row is in it, دينا محمود's is not (the sample CSV adds hers).
SheetBatch seedSheetBatch(DateTime now) => SheetBatch(
  id: SeedIds.sheetBatchPe,
  uploadedBy: SeedIds.verifier,
  fileName: 'students_pe_seed.csv',
  uploadedAt: now.toUtc().subtract(const Duration(days: 7)),
  owningUnitId: SeedIds.ouPe,
  rowsRead: 1,
  rowsAdded: 1,
);

List<SheetRow> seedSheetRows() => const [
  SheetRow(
    nationalId: '29902020200022',
    code: '20230003',
    type: VerificationType.student,
    uploadedBy: SeedIds.verifier,
    batchId: SeedIds.sheetBatchPe,
    owningUnitId: SeedIds.ouPe,
  ),
];
