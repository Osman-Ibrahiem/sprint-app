import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:sprint/core/data/change_signal.dart';
import 'package:sprint/core/data/demo_snapshot_store.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/features/audit/domain/audit_log.dart';
import 'package:sprint/features/audit/domain/audit_log_repository.dart';
import 'package:sprint/features/auth/domain/validators.dart';
import 'package:sprint/features/catalogue/domain/owning_unit.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/identity/data/in_memory_identity_repository.dart';
import 'package:sprint/features/identity/domain/verification.dart';
import 'package:sprint/features/notifications/domain/notification.dart';
import 'package:sprint/features/notifications/domain/notification_repository.dart';
import 'package:sprint/features/settings/domain/setting_definition.dart';
import 'package:sprint/features/settings/domain/setting_registry.dart';
import 'package:sprint/features/settings/domain/settings_repository.dart';
import 'package:sprint/features/verification/data/csv_sheet_parser.dart';
import 'package:sprint/features/verification/domain/national_id.dart';
import 'package:sprint/features/verification/domain/reviewer_scope.dart';
import 'package:sprint/features/verification/domain/sheet_batch.dart';
import 'package:sprint/features/verification/domain/sheet_row.dart';
import 'package:sprint/features/verification/domain/tier.dart' as rules;
import 'package:sprint/features/verification/domain/verification_repository.dart';
import 'package:sprint/features/verification/domain/verification_sheet_parser.dart';

/// The reason code of an automatic refusal for a national ID that another
/// account already holds (BR-27).
const String duplicateNationalIdReason = 'duplicateNationalId';

/// The actor of automatic decisions at submit (data-model: AuditLog).
const String systemActor = 'system';

/// Minimum length of a rejection reason (BR-26).
const int minRejectReasonLength = 10;

/// Verification requests, sheets and review, enforcing every rule of
/// contracts/repositories.md and data-model.md in memory (FR-025 to FR-038,
/// BR-21 to BR-27). Time comes from [clock].
class InMemoryVerificationRepository
    with ChangeSignal
    implements VerificationRepository {
  InMemoryVerificationRepository({
    required Iterable<Verification> verifications,
    required this.identity,
    required this.settings,
    required this.audit,
    required this.notifications,
    DemoSnapshotStore? snapshotStore,
    Iterable<SheetRow> sheetRows = const [],
    Iterable<SheetBatch> batches = const [],
    Iterable<OwningUnit> owningUnits = const [],
    this.parser = const CsvSheetParser(),
    this.clock = const Clock(),
  }) : _all = [...verifications],
       _rows = [...sheetRows],
       _batches = [...batches],
       _unitIds = {for (final u in owningUnits) u.id},
       snapshotStore = snapshotStore ?? _MemoryPhotoStore();

  final InMemoryIdentityRepository identity;
  final SettingsRepository settings;
  final AuditLogRepository audit;
  final NotificationRepository notifications;

  /// Where photos are saved; photos only live in memory when none is given.
  final DemoSnapshotStore snapshotStore;
  final VerificationSheetParser parser;
  final Clock clock;

  final List<Verification> _all;
  final List<SheetRow> _rows;
  final List<SheetBatch> _batches;

  /// Known units; empty means the unit is not checked.
  final Set<String> _unitIds;

  /// Everything, for the demo snapshot.
  List<Verification> get allVerifications => List.unmodifiable(_all);
  List<SheetRow> get allSheetRows => List.unmodifiable(_rows);
  List<SheetBatch> get allBatches => List.unmodifiable(_batches);

  /// Seeding hook for tests and the demo; not part of the interface.
  Future<void> put(Verification v) async {
    _all
      ..removeWhere((e) => e.id == v.id)
      ..add(v);
    notifyChanged();
  }

  // ------------------------------------------------------------- reading

  @override
  Future<List<Verification>> history(String userId) async =>
      (_all.where((v) => v.userId == userId).toList()
        ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt)));

  @override
  Future<Verification?> current(String userId) async {
    final h = await history(userId);
    return h.isEmpty ? null : h.first;
  }

  @override
  Future<PriceTier> tierFor(String userId, DateTime at) async =>
      rules.tierFor(await identity.getUser(userId), await current(userId), at);

  // ------------------------------------------------------------- submit

  @override
  Future<Result<Verification>> submit({
    required String userId,
    required VerificationType type,
    required String nationalId,
    required String code,
    required String owningUnitId,
    required Uint8List photo,
  }) async {
    final user = await identity.getUser(userId);
    if (user == null) return const Err(NotSignedIn());

    final now = clock.now().toUtc();
    final id = validateNationalId(nationalId, now: now);
    if (id case Invalid(:final reason)) {
      return Err(InvalidField('nationalId', reason.name));
    }
    final cleanId = id.valueOrNull!;
    final cleanCode = normalizeVerificationCode(code);
    if (cleanCode == null) {
      return const Err(InvalidField('code', 'invalid'));
    }
    if (_unitIds.isNotEmpty && !_unitIds.contains(owningUnitId)) {
      return const Err(InvalidField('owningUnitId', 'unknown'));
    }
    if (photo.isEmpty) return const Err(InvalidField('photo', 'empty'));

    // One pending request per person (FR-027).
    if (_all.any(
      (v) => v.userId == userId && v.status == VerificationStatus.pending,
    )) {
      return const Err(AlreadyPending());
    }
    // A person whose approval still runs has nothing to request: a new request
    // would become the current one and drop the tier (BR-21, FR-030 renews
    // only after expiry).
    if ((await current(userId))?.isActiveAt(now) ?? false) {
      return const Err(AlreadyVerified());
    }

    final verificationId = _nextId();
    final photoId = 'photo-$verificationId';
    // The photo first: when it cannot be saved nothing else happens, so a
    // retry never makes a second request (research R7).
    if (await snapshotStore.savePhoto(photoId, photo) case Err()) {
      return const Err(StorageFull());
    }
    var request = Verification(
      id: verificationId,
      userId: userId,
      type: type,
      nationalId: cleanId,
      code: cleanCode,
      owningUnitId: owningUnitId,
      status: VerificationStatus.pending,
      method: VerificationMethod.manual,
      submittedAt: now,
      photoId: photoId,
    );

    // FR-026 (1): another account holds this national ID. A rejected request
    // never blocks it.
    final duplicate = _all.any(
      (v) =>
          v.userId != userId &&
          v.nationalId == cleanId &&
          v.status != VerificationStatus.rejected,
    );
    if (duplicate) {
      request = request.copyWith(
        status: VerificationStatus.rejected,
        method: VerificationMethod.auto,
        reason: duplicateNationalIdReason,
        decidedAt: now,
      );
      _all.add(request);
      await _audit(
        systemActor,
        'verification.autoReject',
        request,
        VerificationStatus.pending,
        VerificationStatus.rejected,
        now,
      );
    } else if (_rows.any((r) => _rowMatches(r, request))) {
      // FR-026 (2): a sheet row in scope matches.
      _all.add(request);
      request = await _approve(
        request,
        method: VerificationMethod.auto,
        reviewerId: null,
        actor: systemActor,
        action: 'verification.autoApprove',
        now: now,
      );
    } else {
      _all.add(request);
    }
    notifyChanged();
    return Ok(request);
  }

  // ------------------------------------------------------------- review

  @override
  Future<Result<List<Verification>>> queue(String reviewerId) async {
    final scope = await _scope(reviewerId);
    if (!scope.isReviewer) return const Err(NoAccess());
    // A reviewer's own request is not theirs to decide (FR-035), so it is
    // not listed.
    final list =
        _all
            .where(
              (v) =>
                  v.status == VerificationStatus.pending &&
                  v.userId != reviewerId &&
                  scope.covers(v.owningUnitId),
            )
            .toList()
          ..sort((a, b) => a.submittedAt.compareTo(b.submittedAt));
    return Ok(list);
  }

  @override
  Future<Result<Verification>> request(
    String reviewerId,
    String verificationId,
  ) async {
    final found = await _inScope(reviewerId, verificationId);
    return switch (found) {
      Ok(:final value) => Ok(value),
      Err(:final failure) => Err(failure),
    };
  }

  @override
  Future<Result<Verification>> approve(
    String reviewerId,
    String verificationId,
  ) async {
    final r = await _decidable(reviewerId, verificationId);
    if (r case Err(:final failure)) return Err(failure);
    final v = r.valueOrThrow;
    final done = await _approve(
      v,
      method: VerificationMethod.manual,
      reviewerId: reviewerId,
      actor: reviewerId,
      action: 'verification.approve',
      now: clock.now().toUtc(),
    );
    notifyChanged();
    return Ok(done);
  }

  @override
  Future<Result<Verification>> reject(
    String reviewerId,
    String verificationId,
    String reason,
  ) async {
    final r = await _decidable(reviewerId, verificationId);
    if (r case Err(:final failure)) return Err(failure);
    final v = r.valueOrThrow;
    final clean = reason.trim();
    if (clean.length < minRejectReasonLength) {
      return const Err(ReasonTooShort());
    }
    final now = clock.now().toUtc();
    final done = v.copyWith(
      status: VerificationStatus.rejected,
      method: VerificationMethod.manual,
      reviewerId: reviewerId,
      reason: clean,
      decidedAt: now,
    );
    _replace(done);
    await _audit(
      reviewerId,
      'verification.reject',
      done,
      VerificationStatus.pending,
      VerificationStatus.rejected,
      now,
    );
    await _notify(done, 'verification.rejected', {'reason': clean}, now);
    notifyChanged();
    return Ok(done);
  }

  @override
  Future<Result<Uint8List>> photo(String reviewerId, String photoId) async {
    final scope = await _scope(reviewerId);
    if (!scope.isReviewer) return const Err(NoAccess());
    final owner = _all.where((v) => v.photoId == photoId).firstOrNull;
    if (owner == null || !scope.covers(owner.owningUnitId)) {
      return const Err(NoAccess());
    }
    final bytes = await snapshotStore.loadPhoto(photoId);
    return bytes == null ? const Err(NotFound('photo')) : Ok(bytes);
  }

  // ------------------------------------------------------------- sheets

  @override
  Future<Result<SheetBatch>> uploadSheet(
    String reviewerId,
    String fileName,
    String csvText,
  ) async {
    final scope = await _scope(reviewerId);
    if (!scope.isReviewer) return const Err(NoAccess());

    final parsed = parser.parse(csvText);
    if (parsed.rows.isEmpty) {
      final wrongShape =
          parsed.problems.isNotEmpty &&
          parsed.problems.every((p) => p.reasonCode == sheetReasonColumns);
      return Err(wrongShape ? const BadColumns() : const NoValidRows());
    }

    // Rows are tagged with the uploader's unit; several units mean one tag
    // each, university scope means no tag (FR-032).
    final tags = switch (scope) {
      AllUnits() => <String?>[null],
      UnitsScope(:final unitIds) => <String?>[...unitIds]..sort(),
    };
    final now = clock.now().toUtc();
    final batchId = _nextBatchId();

    var added = 0;
    var duplicates = 0;
    final fresh = <SheetRow>[];
    for (final p in parsed.rows) {
      var isNew = false;
      for (final tag in tags) {
        final exists =
            _rows.any((r) => _sameRow(r, p, tag)) ||
            fresh.any((r) => _sameRow(r, p, tag));
        if (exists) continue;
        isNew = true;
        fresh.add(
          SheetRow(
            nationalId: p.nationalId,
            code: p.code,
            type: p.type,
            uploadedBy: reviewerId,
            batchId: batchId,
            owningUnitId: tag,
          ),
        );
      }
      if (isNew) {
        added++;
      } else {
        duplicates++;
      }
    }
    _rows.addAll(fresh);

    // FR-037: every pending request in scope that matches a new row.
    var approved = 0;
    for (final v in List.of(_all)) {
      if (v.status != VerificationStatus.pending ||
          v.userId == reviewerId ||
          !scope.covers(v.owningUnitId)) {
        continue;
      }
      if (!fresh.any((r) => _rowMatches(r, v))) continue;
      await _approve(
        v,
        method: VerificationMethod.auto,
        reviewerId: reviewerId,
        actor: reviewerId,
        action: 'verification.autoApprove',
        now: now,
      );
      approved++;
    }

    final batch = SheetBatch(
      id: batchId,
      uploadedBy: reviewerId,
      owningUnitId: tags.length == 1 ? tags.single : null,
      fileName: fileName,
      uploadedAt: now,
      rowsRead: parsed.rows.length + parsed.problems.length,
      rowsAdded: added,
      duplicates: duplicates,
      invalid: parsed.problems.length,
      approved: approved,
      problems: parsed.problems,
    );
    _batches.add(batch);
    await audit.append(
      AuditLog(
        actorId: reviewerId,
        action: 'verification.sheetUpload',
        entity: 'sheetBatch',
        entityId: batchId,
        after:
            'read ${batch.rowsRead}, added $added, duplicates $duplicates, '
            'invalid ${batch.invalid}, approved $approved',
        at: now,
      ),
    );
    notifyChanged();
    return Ok(batch);
  }

  @override
  Future<Result<List<SheetBatch>>> batches(String reviewerId) async {
    final scope = await _scope(reviewerId);
    if (!scope.isReviewer) return const Err(NoAccess());
    final list =
        _batches
            .where(
              (b) =>
                  scope is AllUnits ||
                  b.uploadedBy == reviewerId ||
                  (b.owningUnitId != null && scope.covers(b.owningUnitId!)),
            )
            .toList()
          ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
    return Ok(list);
  }

  // ------------------------------------------------------------- helpers

  Future<ReviewerScope> _scope(String reviewerId) async =>
      ReviewerScope.from(await identity.roleAssignments(reviewerId));

  /// The request when the reviewer may see it; out of scope and unknown
  /// both answer [NoAccess], so nothing leaks (FR-032).
  Future<Result<Verification>> _inScope(
    String reviewerId,
    String verificationId,
  ) async {
    final scope = await _scope(reviewerId);
    if (!scope.isReviewer) return const Err(NoAccess());
    final v = _all.where((e) => e.id == verificationId).firstOrNull;
    if (v == null || !scope.covers(v.owningUnitId)) {
      return const Err(NoAccess());
    }
    return Ok(v);
  }

  /// A request the reviewer may decide now: in scope, not their own (FR-035),
  /// still pending.
  Future<Result<Verification>> _decidable(
    String reviewerId,
    String verificationId,
  ) async {
    final r = await _inScope(reviewerId, verificationId);
    if (r case Err()) return r;
    final v = r.valueOrThrow;
    if (v.userId == reviewerId) return const Err(OwnRequest());
    if (v.status != VerificationStatus.pending) {
      return const Err(AlreadyDecided());
    }
    return Ok(v);
  }

  bool _rowMatches(SheetRow r, Verification v) =>
      r.nationalId == v.nationalId &&
      r.code == v.code &&
      r.type == v.type &&
      (r.owningUnitId == null || r.owningUnitId == v.owningUnitId);

  bool _sameRow(SheetRow r, ParsedSheetRow p, String? tag) =>
      r.nationalId == p.nationalId &&
      r.code == p.code &&
      r.type == p.type &&
      r.owningUnitId == tag;

  /// Approves [v]: expiry from the setting, the person's national ID, audit
  /// and notification (FR-028, FR-034). The caller notifies listeners.
  Future<Verification> _approve(
    Verification v, {
    required VerificationMethod method,
    required String? reviewerId,
    required String actor,
    required String action,
    required DateTime now,
  }) async {
    final expiresAt = await _expiryFrom(now);
    final done = v.copyWith(
      status: VerificationStatus.approved,
      method: method,
      reviewerId: reviewerId,
      decidedAt: now,
      expiresAt: expiresAt,
    );
    _replace(done);
    identity.setNationalId(v.userId, v.nationalId);
    await _audit(
      actor,
      action,
      done,
      VerificationStatus.pending,
      VerificationStatus.approved,
      now,
    );
    await _notify(done, 'verification.approved', {
      'expiresAt': expiresAt.toUtc().toIso8601String(),
    }, now);
    return done;
  }

  /// `verificationExpiry` at 23:59:59 Cairo time, this Cairo year if still
  /// ahead, otherwise the next (FR-028).
  Future<DateTime> _expiryFrom(DateTime now) async {
    final md = await settings.resolve<MonthDay>(SettingKeys.verificationExpiry);
    final year = CairoTime.toCairo(now).year;
    DateTime endOf(int y) {
      // 29 February in a year without one falls on the 28th.
      final day = md.day > DateTime(y, md.month + 1, 0).day
          ? DateTime(y, md.month + 1, 0).day
          : md.day;
      return CairoTime.atWallClock(
        y,
        md.month,
        day + 1,
      ).subtract(const Duration(seconds: 1));
    }

    final thisYear = endOf(year);
    return thisYear.isAfter(now) ? thisYear : endOf(year + 1);
  }

  void _replace(Verification v) {
    final i = _all.indexWhere((e) => e.id == v.id);
    if (i >= 0) _all[i] = v;
  }

  Future<void> _audit(
    String actor,
    String action,
    Verification v,
    VerificationStatus before,
    VerificationStatus after,
    DateTime at,
  ) => audit.append(
    AuditLog(
      actorId: actor,
      action: action,
      entity: 'verification',
      entityId: v.id,
      before: before.name,
      after: after.name,
      at: at,
    ),
  );

  Future<void> _notify(
    Verification v,
    String type,
    Map<String, String> payload,
    DateTime at,
  ) => notifications.push(
    Notification(
      id: 'ntf-${v.id}-${v.status.name}',
      userId: v.userId,
      type: type,
      payload: {'verificationId': v.id, ...payload},
      sentAt: at,
    ),
  );

  String _nextId() {
    var n = _all.length + 1;
    while (_all.any((v) => v.id == 'ver-$n')) {
      n++;
    }
    return 'ver-$n';
  }

  String _nextBatchId() {
    var n = _batches.length + 1;
    while (_batches.any((b) => b.id == 'batch-$n')) {
      n++;
    }
    return 'batch-$n';
  }
}

/// Photos kept in memory, for when no snapshot store is injected.
class _MemoryPhotoStore implements DemoSnapshotStore {
  final Map<String, Uint8List> _photos = {};

  @override
  Future<Map<String, Object?>?> load() async => null;

  @override
  Future<void> save(Map<String, Object?> snapshot) async {}

  @override
  Future<Uint8List?> loadPhoto(String id) async => _photos[id];

  @override
  Future<Result<void>> savePhoto(String id, Uint8List bytes) async {
    _photos[id] = bytes;
    return const Ok(null);
  }

  @override
  Future<void> deletePhoto(String id) async {
    _photos.remove(id);
  }

  @override
  Future<void> clear() async => _photos.clear();
}
