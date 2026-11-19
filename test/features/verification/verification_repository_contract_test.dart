import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/data/demo_snapshot_store.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/features/audit/data/in_memory_audit_log_repository.dart';
import 'package:sprint/features/catalogue/domain/owning_unit.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/identity/data/in_memory_identity_repository.dart';
import 'package:sprint/features/identity/domain/role_assignment.dart';
import 'package:sprint/features/identity/domain/user.dart';
import 'package:sprint/features/identity/domain/verification.dart';
import 'package:sprint/features/notifications/data/in_memory_notification_repository.dart';
import 'package:sprint/features/settings/data/in_memory_settings_repository.dart';
import 'package:sprint/features/settings/domain/setting_definition.dart';
import 'package:sprint/features/settings/domain/setting_registry.dart';
import 'package:sprint/features/verification/data/in_memory_verification_repository.dart';

/// The contract of VerificationRepository (contracts/repositories.md), run
/// against the in-memory implementation; the backend runs it later.
/// FR-025 to FR-038, BR-23 to BR-27.
void main() {
  CairoTime.ensureInitialized();

  const pe = 'ou-pe';
  const eng = 'ou-eng';
  final photo = Uint8List.fromList([1, 2, 3]);

  /// A valid national ID: born 1 Jan 1999, governorate 12.
  String nid(int n) => '2990101${'12'}${n.toString().padLeft(5, '0')}';

  late DateTime now;
  late InMemoryIdentityRepository identity;
  late InMemoryAuditLogRepository audit;
  late InMemoryNotificationRepository notes;
  late InMemorySettingsRepository settings;
  late _Store store;
  late InMemoryVerificationRepository repo;

  User user(String id) => User(
    id: id,
    name: 'Person $id',
    phone: '0100000000${id.length}',
    email: '$id@example.com',
    createdAt: DateTime.utc(2026),
  );

  RoleAssignment role(String id, Role r, RoleScopeType t, [String? scope]) =>
      RoleAssignment(userId: id, role: r, scopeType: t, scopeId: scope);

  void build({List<Verification> seed = const []}) {
    identity = InMemoryIdentityRepository(
      users: [
        for (final id in [
          'alice',
          'bob',
          'carol',
          'peVerifier',
          'engVerifier',
          'uniVerifier',
          'root',
        ])
          user(id),
      ],
      roleAssignments: [
        role('peVerifier', Role.verifier, RoleScopeType.owningUnit, pe),
        role('engVerifier', Role.verifier, RoleScopeType.owningUnit, eng),
        role('uniVerifier', Role.verifier, RoleScopeType.university),
        role('root', Role.superAdmin, RoleScopeType.university),
        role('alice', Role.booker, RoleScopeType.university),
      ],
    );
    audit = InMemoryAuditLogRepository();
    notes = InMemoryNotificationRepository();
    final clock = Clock(() => now);
    settings = InMemorySettingsRepository(audit: audit, clock: clock);
    store = _Store();
    repo = InMemoryVerificationRepository(
      verifications: seed,
      identity: identity,
      settings: settings,
      audit: audit,
      notifications: notes,
      snapshotStore: store,
      owningUnits: const [
        OwningUnit(id: pe, name: 'PE', type: OwningUnitType.faculty),
        OwningUnit(id: eng, name: 'Eng', type: OwningUnitType.faculty),
      ],
      clock: clock,
    );
  }

  setUp(() {
    now = CairoTime.atWallClock(2026, 8, 20, 10);
    build();
  });

  Future<Result<Verification>> submit(
    String userId,
    int idNo, {
    String unit = pe,
    String code = '2021001',
    VerificationType type = VerificationType.student,
  }) => repo.submit(
    userId: userId,
    type: type,
    nationalId: nid(idNo),
    code: code,
    owningUnitId: unit,
    photo: photo,
  );

  Verification ok(Result<Verification> r) => (r as Ok<Verification>).value;
  Failure fail<T>(Result<T> r) => (r as Err<T>).failure;

  String csv(int idNo, {String code = '2021001', String type = 'student'}) =>
      '${nid(idNo)},$code,$type\n';

  group('submit: FR-026 order', () {
    test('no match and no duplicate is pending (BR-24)', () async {
      final v = ok(await submit('alice', 1));
      expect(v.status, VerificationStatus.pending);
      expect(v.method, VerificationMethod.manual);
      expect(v.nationalId, nid(1));
      expect(v.photoId, isNotNull);
      expect(await repo.current('alice'), v);
      expect(await repo.tierFor('alice', now), PriceTier.external);
      expect((await identity.getUser('alice'))!.nationalId, isNull);
    });

    test('invalid fields are refused with the field name', () async {
      final badId = await repo.submit(
        userId: 'alice',
        type: VerificationType.student,
        nationalId: '123',
        code: '1',
        owningUnitId: pe,
        photo: photo,
      );
      expect(
        fail(badId),
        isA<InvalidField>().having((f) => f.field, 'f', 'nationalId'),
      );
      final badCode = await submit('alice', 1, code: '!!');
      expect(
        fail(badCode),
        isA<InvalidField>().having((f) => f.field, 'f', 'code'),
      );
      final badUnit = await submit('alice', 1, unit: 'nope');
      expect(
        fail(badUnit),
        isA<InvalidField>().having((f) => f.field, 'f', 'owningUnitId'),
      );
      expect(fail(await submit('ghost', 1)), isA<NotSignedIn>());
      expect(await repo.history('alice'), isEmpty);
    });

    test('a pending request of another account refuses the same ID', () async {
      await submit('alice', 1);
      final v = ok(await submit('bob', 1));
      expect(v.status, VerificationStatus.rejected);
      expect(v.method, VerificationMethod.auto);
      expect(v.reason, duplicateNationalIdReason);
      expect(await repo.tierFor('bob', now), PriceTier.external);
    });

    test('an approved request of another account refuses it', () async {
      ok(await submit('alice', 1));
      final a = (await repo.queue('uniVerifier')).valueOrThrow.single;
      await repo.approve('uniVerifier', a.id);
      final v = ok(await submit('bob', 1));
      expect(v.reason, duplicateNationalIdReason);
    });

    test('an expired approved request still blocks the ID', () async {
      await submit('alice', 1);
      final a = (await repo.queue('uniVerifier')).valueOrThrow.single;
      await repo.approve('uniVerifier', a.id);
      now = now.add(const Duration(days: 400));
      final v = ok(await submit('bob', 1));
      expect(v.status, VerificationStatus.rejected);
    });

    test('a rejected request never blocks an ID', () async {
      await submit('alice', 1);
      final a = (await repo.queue('uniVerifier')).valueOrThrow.single;
      await repo.reject('uniVerifier', a.id, 'photo is not readable');
      final v = ok(await submit('bob', 1));
      expect(v.status, VerificationStatus.pending);
    });

    test('a person renewing their own ID is not a duplicate', () async {
      await submit('alice', 1);
      final a = (await repo.queue('uniVerifier')).valueOrThrow.single;
      await repo.approve('uniVerifier', a.id);
      now = now.add(const Duration(days: 400));
      final v = ok(await submit('alice', 1));
      expect(v.status, VerificationStatus.pending);
      expect(await repo.history('alice'), hasLength(2));
      expect((await repo.history('alice')).first, v); // newest first
    });

    test('the duplicate rule comes before the sheet match', () async {
      await submit('alice', 1);
      await repo.uploadSheet('uniVerifier', 's.csv', csv(1));
      // alice was approved by the sheet; bob's request is a duplicate even
      // though the sheet matches it.
      final v = ok(await submit('bob', 1));
      expect(v.status, VerificationStatus.rejected);
      expect(v.reason, duplicateNationalIdReason);
    });

    test('a matching sheet row approves at once (BR-23)', () async {
      await repo.uploadSheet('peVerifier', 's.csv', csv(2));
      final v = ok(await submit('alice', 2));
      expect(v.status, VerificationStatus.approved);
      expect(v.method, VerificationMethod.auto);
      expect(v.reviewerId, isNull);
      expect(v.expiresAt, isNotNull);
      expect((await identity.getUser('alice'))!.nationalId, nid(2));
      expect(await repo.tierFor('alice', now), PriceTier.internal);
    });

    test('the sheet row must match the ID, the code and the type', () async {
      await repo.uploadSheet('uniVerifier', 's.csv', csv(2) + csv(3));
      expect(
        ok(await submit('alice', 2, code: '999')).status,
        VerificationStatus.pending,
      );
      expect(
        ok(await submit('bob', 3, type: VerificationType.staff)).status,
        VerificationStatus.pending,
      );
    });

    test('a unit row matches only requests of its unit (FR-032)', () async {
      await repo.uploadSheet('peVerifier', 's.csv', csv(2) + csv(3));
      expect(
        ok(await submit('alice', 2, unit: eng)).status,
        VerificationStatus.pending,
      );
      expect(
        ok(await submit('bob', 3, unit: pe)).status,
        VerificationStatus.approved,
      );
    });

    test('a university row matches every unit', () async {
      await repo.uploadSheet('uniVerifier', 's.csv', csv(2));
      expect(
        ok(await submit('alice', 2, unit: eng)).status,
        VerificationStatus.approved,
      );
    });

    test('alreadyVerified while an approval still runs, so the tier never '
        'drops for a new request (FR-030)', () async {
      await repo.uploadSheet('uniVerifier', 's.csv', csv(2));
      expect(ok(await submit('alice', 2)).status, VerificationStatus.approved);
      expect(fail(await submit('alice', 2)), isA<AlreadyVerified>());
      expect(await repo.history('alice'), hasLength(1));
    });

    test('alreadyPending while one is pending (FR-027)', () async {
      await submit('alice', 1);
      expect(fail(await submit('alice', 3)), isA<AlreadyPending>());
      expect(await repo.history('alice'), hasLength(1));
    });

    test('a failed photo save reports storageFull and stores nothing, so a '
        'retry never makes a second request', () async {
      store.full = true;
      final r = await submit('alice', 1);
      expect(fail(r), isA<StorageFull>());
      expect(await repo.current('alice'), isNull);
      store.full = false;
      expect(ok(await submit('alice', 1)).status, VerificationStatus.pending);
      expect(await repo.history('alice'), hasLength(1));
    });
  });

  group('review scope: FR-032', () {
    late String peId;
    late String engId;

    setUp(() async {
      peId = ok(await submit('alice', 1, unit: pe)).id;
      now = now.add(const Duration(minutes: 5));
      engId = ok(await submit('bob', 2, unit: eng)).id;
    });

    Future<List<String>> queued(String who) async => [
      for (final v in (await repo.queue(who)).valueOrThrow) v.id,
    ];

    test('a PE verifier sees and decides only PE', () async {
      expect(await queued('peVerifier'), [peId]);
      expect(ok(await repo.request('peVerifier', peId)).id, peId);
      expect(fail(await repo.request('peVerifier', engId)), isA<NoAccess>());
      expect(fail(await repo.approve('peVerifier', engId)), isA<NoAccess>());
      expect(
        fail(await repo.reject('peVerifier', engId, 'long enough reason')),
        isA<NoAccess>(),
      );
      expect(
        fail(await repo.request('peVerifier', 'ver-404')),
        isA<NoAccess>(),
      );
    });

    test(
      'a university verifier and the super admin see everything, oldest first',
      () async {
        expect(await queued('uniVerifier'), [peId, engId]);
        expect(await queued('root'), [peId, engId]);
        expect(ok(await repo.approve('root', engId)).id, engId);
      },
    );

    test('a person without a reviewing role has no access', () async {
      expect(fail(await repo.queue('alice')), isA<NoAccess>());
      expect(fail(await repo.request('alice', peId)), isA<NoAccess>());
      expect(fail(await repo.approve('carol', peId)), isA<NoAccess>());
      expect(fail(await repo.batches('alice')), isA<NoAccess>());
      expect(
        fail(await repo.uploadSheet('alice', 'a', csv(5))),
        isA<NoAccess>(),
      );
      expect(fail(await repo.photo('alice', 'photo-$peId')), isA<NoAccess>());
    });

    test('photos follow the same scope', () async {
      final pePhoto = ok(await repo.request('peVerifier', peId)).photoId!;
      final engPhoto = ok(await repo.request('engVerifier', engId)).photoId!;
      expect((await repo.photo('peVerifier', pePhoto)).valueOrThrow, photo);
      expect(fail(await repo.photo('peVerifier', engPhoto)), isA<NoAccess>());
      expect(fail(await repo.photo('uniVerifier', 'nope')), isA<NoAccess>());
    });

    test('a decided request leaves the queue', () async {
      await repo.approve('peVerifier', peId);
      expect(await queued('peVerifier'), isEmpty);
    });
  });

  group('decisions', () {
    late String id;
    setUp(() async => id = ok(await submit('alice', 1)).id);

    test(
      'approve makes the person internal and sets the national ID',
      () async {
        final v = ok(await repo.approve('peVerifier', id));
        expect(v.status, VerificationStatus.approved);
        expect(v.method, VerificationMethod.manual);
        expect(v.reviewerId, 'peVerifier');
        expect(v.decidedAt, now);
        expect(v.expiresAt, isNotNull);
        expect((await identity.getUser('alice'))!.nationalId, nid(1));
        expect(await repo.tierFor('alice', now), PriceTier.internal);
        expect(await repo.tierFor('alice', v.expiresAt!), PriceTier.external);
      },
    );

    test('a reviewer never decides their own request (FR-035)', () async {
      final own = ok(await submit('peVerifier', 7)).id;
      expect(fail(await repo.approve('peVerifier', own)), isA<OwnRequest>());
      expect(
        fail(await repo.reject('peVerifier', own, 'long enough reason')),
        isA<OwnRequest>(),
      );
      // Someone else with scope can decide it.
      expect(
        ok(await repo.approve('root', own)).status,
        VerificationStatus.approved,
      );
    });

    test('a decided request cannot be decided again', () async {
      await repo.approve('peVerifier', id);
      expect(fail(await repo.approve('peVerifier', id)), isA<AlreadyDecided>());
      expect(
        fail(await repo.reject('peVerifier', id, 'long enough reason')),
        isA<AlreadyDecided>(),
      );
    });

    test('reject needs a reason of at least 10 characters (BR-26)', () async {
      expect(
        fail(await repo.reject('peVerifier', id, '123456789')),
        isA<ReasonTooShort>(),
      );
      expect(
        fail(await repo.reject('peVerifier', id, '   short   ')),
        isA<ReasonTooShort>(),
      );
      expect((await repo.current('alice'))!.status, VerificationStatus.pending);
      final v = ok(await repo.reject('peVerifier', id, '  1234567890  '));
      expect(v.status, VerificationStatus.rejected);
      expect(v.reason, '1234567890');
      expect(v.reviewerId, 'peVerifier');
      expect((await identity.getUser('alice'))!.nationalId, isNull);
      expect(await repo.tierFor('alice', now), PriceTier.external);
    });
  });

  group('expiry from the setting: FR-028', () {
    Future<DateTime> approvedAt(DateTime at) async {
      now = at;
      final v = ok(await submit('alice', 1));
      return ok(await repo.approve('uniVerifier', v.id)).expiresAt!;
    }

    DateTime endOfDay(int y, int m, int d) =>
        CairoTime.atWallClock(y, m, d + 1).subtract(const Duration(seconds: 1));

    test(
      'approved on 20 August: that year, 31 August 23:59:59 Cairo',
      () async {
        expect(
          await approvedAt(CairoTime.atWallClock(2026, 8, 20, 10)),
          endOfDay(2026, 8, 31),
        );
      },
    );

    test('approved on 1 September: the next year', () async {
      expect(
        await approvedAt(CairoTime.atWallClock(2026, 9, 1, 10)),
        endOfDay(2027, 8, 31),
      );
    });

    test('approved on the day after midnight of the day itself', () async {
      expect(
        await approvedAt(CairoTime.atWallClock(2026, 8, 31, 12)),
        endOfDay(2026, 8, 31),
      );
    });

    test('follows the setting, not a constant', () async {
      await settings.set<MonthDay>(
        SettingKeys.verificationExpiry,
        const MonthDay(10, 15),
        const SettingScope.university(),
        actorId: 'root',
      );
      expect(
        await approvedAt(CairoTime.atWallClock(2026, 8, 20, 10)),
        endOfDay(2026, 10, 15),
      );
    });
  });

  group('sheets: FR-036 to FR-038', () {
    test('rows are tagged with the uploader unit and summarised', () async {
      final b = (await repo.uploadSheet(
        'peVerifier',
        'pe.csv',
        'national_id,code,type\n${csv(1)}${csv(2, code: 'S9', type: 'موظف')}'
            '${nid(1)},2021001,student\n'
            '29913011234567,5,student\n',
      )).valueOrThrow;
      expect(b.owningUnitId, pe);
      expect(b.uploadedBy, 'peVerifier');
      expect(b.fileName, 'pe.csv');
      expect(b.uploadedAt, now);
      expect(b.rowsRead, 4);
      expect(b.rowsAdded, 2);
      expect(b.duplicates, 1);
      expect(b.invalid, 1);
      expect(b.approved, 0);
      expect(b.problems.single.rowNumber, 5);
      expect(repo.allSheetRows, hasLength(2));
      expect(repo.allSheetRows.every((r) => r.owningUnitId == pe), isTrue);
      expect(repo.allSheetRows.every((r) => r.batchId == b.id), isTrue);
    });

    test('university uploads are untagged', () async {
      final b = (await repo.uploadSheet('root', 'a.csv', csv(1))).valueOrThrow;
      expect(b.owningUnitId, isNull);
      expect(repo.allSheetRows.single.owningUnitId, isNull);
    });

    test(
      'a repeat of the same unit is a duplicate; another unit is not',
      () async {
        await repo.uploadSheet('peVerifier', 'a.csv', csv(1));
        final again = (await repo.uploadSheet(
          'peVerifier',
          'b.csv',
          csv(1),
        )).valueOrThrow;
        expect((again.rowsAdded, again.duplicates), (0, 1));
        final other = (await repo.uploadSheet(
          'engVerifier',
          'c.csv',
          csv(1),
        )).valueOrThrow;
        expect((other.rowsAdded, other.duplicates), (1, 0));
        final inFile = (await repo.uploadSheet(
          'uniVerifier',
          'd.csv',
          csv(3) + csv(3),
        )).valueOrThrow;
        expect((inFile.rowsAdded, inFile.duplicates), (1, 1));
      },
    );

    test(
      'pending requests in scope that match are approved (FR-037)',
      () async {
        final peReq = ok(await submit('alice', 1, unit: pe)).id;
        final engReq = ok(await submit('bob', 2, unit: eng)).id;
        final batch = (await repo.uploadSheet(
          'peVerifier',
          'pe.csv',
          csv(1) + csv(2),
        )).valueOrThrow;
        expect(batch.approved, 1);
        final a = ok(await repo.request('uniVerifier', peReq));
        expect(a.status, VerificationStatus.approved);
        expect(a.method, VerificationMethod.auto);
        expect(a.reviewerId, 'peVerifier');
        expect(
          ok(await repo.request('uniVerifier', engReq)).status,
          VerificationStatus.pending,
        );
        expect((await identity.getUser('alice'))!.nationalId, nid(1));
      },
    );

    test('a duplicate row does not approve anything new', () async {
      await repo.uploadSheet('peVerifier', 'pe.csv', csv(1));
      ok(await submit('alice', 1)); // approved at submit already
      final b = (await repo.uploadSheet(
        'peVerifier',
        'pe2.csv',
        csv(1),
      )).valueOrThrow;
      expect(b.approved, 0);
    });

    test('wrong columns and no valid rows add nothing', () async {
      expect(
        fail(await repo.uploadSheet('root', 'x.csv', 'a,b\n1,2\n')),
        isA<BadColumns>(),
      );
      expect(
        fail(await repo.uploadSheet('root', 'x.csv', '')),
        isA<NoValidRows>(),
      );
      expect(
        fail(await repo.uploadSheet('root', 'x.csv', 'a,b,c\n')),
        isA<NoValidRows>(),
      );
      expect(
        fail(await repo.uploadSheet('root', 'x.csv', '1,2,student\n')),
        isA<NoValidRows>(),
      );
      expect(repo.allSheetRows, isEmpty);
      expect(repo.allBatches, isEmpty);
      expect(audit.all, isEmpty);
    });

    test('batches are newest first and filtered by scope', () async {
      await repo.uploadSheet('peVerifier', 'pe.csv', csv(1));
      now = now.add(const Duration(hours: 1));
      await repo.uploadSheet('engVerifier', 'eng.csv', csv(2));
      now = now.add(const Duration(hours: 1));
      await repo.uploadSheet('root', 'all.csv', csv(3));
      List<String> names(Result<List<dynamic>> r) => [
        for (final b in r.valueOrThrow) b.fileName as String,
      ];
      expect(names(await repo.batches('uniVerifier')), [
        'all.csv',
        'eng.csv',
        'pe.csv',
      ]);
      expect(names(await repo.batches('peVerifier')), ['pe.csv']);
      expect(names(await repo.batches('engVerifier')), ['eng.csv']);
    });
  });

  group('audit and notifications: data-model table', () {
    test('manual approve', () async {
      final id = ok(await submit('alice', 1)).id;
      await repo.approve('peVerifier', id);
      final e = audit.all.single;
      expect(
        (e.actorId, e.action, e.entity, e.entityId, e.before, e.after, e.at),
        (
          'peVerifier',
          'verification.approve',
          'verification',
          id,
          'pending',
          'approved',
          now,
        ),
      );
      final n = (await notes.list('alice')).single;
      expect(n.type, 'verification.approved');
      expect(n.payload['verificationId'], id);
      expect(n.payload['expiresAt'], isNotNull);
    });

    test('manual reject carries the reason', () async {
      final id = ok(await submit('alice', 1)).id;
      await repo.reject('peVerifier', id, 'the photo is blurry');
      expect(audit.all.single.action, 'verification.reject');
      expect(audit.all.single.after, 'rejected');
      final n = (await notes.list('alice')).single;
      expect(n.type, 'verification.rejected');
      expect(n.payload['reason'], 'the photo is blurry');
    });

    test('auto approve at submit is by the system', () async {
      await repo.uploadSheet('peVerifier', 's.csv', csv(1));
      audit.all; // upload entry
      final id = ok(await submit('alice', 1)).id;
      final e = audit.all.last;
      expect(
        (e.actorId, e.action, e.entityId),
        ('system', 'verification.autoApprove', id),
      );
      expect((await notes.list('alice')).single.type, 'verification.approved');
    });

    test('auto approve from a sheet is by the uploader', () async {
      final id = ok(await submit('alice', 1)).id;
      await repo.uploadSheet('peVerifier', 's.csv', csv(1));
      final approve = audit.all.firstWhere(
        (e) => e.action == 'verification.autoApprove',
      );
      expect((approve.actorId, approve.entityId), ('peVerifier', id));
      expect((await notes.list('alice')).single.type, 'verification.approved');
    });

    test('auto reject for a duplicate ID has no notification', () async {
      await submit('alice', 1);
      final id = ok(await submit('bob', 1)).id;
      final e = audit.all.single;
      expect(
        (e.actorId, e.action, e.entityId, e.before, e.after),
        ('system', 'verification.autoReject', id, 'pending', 'rejected'),
      );
      expect(await notes.list('bob'), isEmpty);
    });

    test(
      'a sheet upload is audited against its batch, with no notification',
      () async {
        final b = (await repo.uploadSheet(
          'peVerifier',
          's.csv',
          csv(1),
        )).valueOrThrow;
        final e = audit.all.single;
        expect(
          (e.actorId, e.action, e.entity, e.entityId),
          ('peVerifier', 'verification.sheetUpload', 'sheetBatch', b.id),
        );
        expect(await notes.list('peVerifier'), isEmpty);
      },
    );

    test('a refused decision writes nothing', () async {
      final id = ok(await submit('alice', 1)).id;
      await repo.reject('peVerifier', id, 'short');
      await repo.approve('engVerifier', id);
      expect(audit.all, isEmpty);
      expect(await notes.list('alice'), isEmpty);
    });
  });

  group('changes and tier', () {
    test('every successful write fires changes; refusals do not', () async {
      var fired = 0;
      final sub = repo.changes.listen((_) => fired++);
      final id = ok(await submit('alice', 1)).id;
      await Future<void>.delayed(Duration.zero);
      expect(fired, greaterThan(0));
      final before = fired;
      await repo.approve('alice', id); // no access
      await Future<void>.delayed(Duration.zero);
      expect(fired, before);
      await sub.cancel();
    });

    test('suspended or unknown people are external', () async {
      expect(await repo.tierFor('ghost', now), PriceTier.external);
    });
  });
}

class _Store implements DemoSnapshotStore {
  final Map<String, Uint8List> photos = {};
  bool full = false;

  @override
  Future<Map<String, Object?>?> load() async => null;

  @override
  Future<void> save(Map<String, Object?> snapshot) async {}

  @override
  Future<Uint8List?> loadPhoto(String id) async => photos[id];

  @override
  Future<Result<void>> savePhoto(String id, Uint8List bytes) async {
    if (full) return const Err(StorageFull());
    photos[id] = bytes;
    return const Ok(null);
  }

  @override
  Future<void> deletePhoto(String id) async => photos.remove(id);

  @override
  Future<void> clear() async => photos.clear();
}
