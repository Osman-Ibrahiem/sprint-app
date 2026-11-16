import 'dart:convert';
import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprint/core/data/in_memory_data_layer.dart';
import 'package:sprint/core/data/in_memory_snapshot_store.dart';
import 'package:sprint/core/data/preferences_snapshot_store.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/features/audit/domain/audit_log.dart';
import 'package:sprint/features/settings/domain/setting_definition.dart';
import 'package:sprint/features/settings/domain/setting_registry.dart';

import '../../helpers/domain_builders.dart' show cairo;

Clock _clock() {
  final now = cairo(2026, 11, 14, 8);
  return Clock(() => now);
}

InMemoryDataLayer _seeded() =>
    InMemoryDataLayer.create(clock: _clock(), paymentDelay: Duration.zero);

/// The snapshot as it would come back from storage: through real JSON text.
Map<String, Object?> _viaJson(Map<String, Object?> snapshot) =>
    Map<String, Object?>.from(jsonDecode(jsonEncode(snapshot)) as Map);

Map<String, Object?> _data(InMemoryDataLayer l) =>
    Map<String, Object?>.from(_viaJson(l.toSnapshot())['data']! as Map);

Future<void> _turn() => Future<void>.delayed(Duration.zero);

AuditLog _entry() => AuditLog(
  actorId: 'a',
  action: 'test',
  entity: 'E',
  entityId: '1',
  at: cairo(2026, 11, 14, 9),
);

void main() {
  group('round trip', () {
    test('the whole seeded layer survives a snapshot unchanged', () {
      final layer = _seeded();
      final snap = _viaJson(layer.toSnapshot());
      expect(snap['schemaVersion'], 1);
      expect(snap['seededAt'], isA<String>());
      expect(snap['savedAt'], isA<String>());

      final back = InMemoryDataLayer.fromSnapshot(
        clock: _clock(),
        snapshot: snap,
        paymentDelay: Duration.zero,
      );
      expect(_data(back), _data(layer));
      expect(back.seededAt.isAtSameMomentAs(layer.seededAt), isTrue);
    });

    test('changes made after seeding come back', () async {
      final layer = _seeded();
      final id = layer.notifications.all.first.id;
      await layer.notifications.markRead(id, cairo(2026, 11, 14, 10));
      await layer.audit.append(_entry());
      await layer.settings.set(
        SettingKeys.verificationExpiry,
        const MonthDay(9, 15),
        const SettingScope.university(),
        actorId: SeedIds.superAdmin,
      );

      final back = InMemoryDataLayer.fromSnapshot(
        clock: _clock(),
        snapshot: _viaJson(layer.toSnapshot()),
        paymentDelay: Duration.zero,
      );
      expect(
        back.notifications.all.firstWhere((n) => n.id == id).readAt,
        isNotNull,
      );
      expect(back.audit.all.any((e) => e.action == 'test'), isTrue);
      expect(
        await back.settings.resolve(SettingKeys.verificationExpiry),
        const MonthDay(9, 15),
      );
    });

    test('restoring a snapshot restores the signed-in user (FR-013)', () async {
      final layer = _seeded();
      // TODO(T025): the session moves to AuthRepository; point this at it.
      await layer.auth.actAs(SeedIds.userUnverified);

      final back = InMemoryDataLayer.fromSnapshot(
        clock: _clock(),
        snapshot: _viaJson(layer.toSnapshot()),
        paymentDelay: Duration.zero,
      );
      expect((await back.auth.currentUserId()), SeedIds.userUnverified);

      await layer.auth.actAs(null);
      final guest = InMemoryDataLayer.fromSnapshot(
        clock: _clock(),
        snapshot: _viaJson(layer.toSnapshot()),
        paymentDelay: Duration.zero,
      );
      expect(await guest.auth.currentUserId(), isNull);
    });

    test('a saved password never appears in the snapshot JSON (FR-044)', () {
      // TODO(T025): sign up with a known password through AuthRepository and
      // assert jsonEncode(layer.toSnapshot()) does not contain it. The auth
      // repository does not exist yet, so there is nothing to sign up with.
    }, skip: 'waits for AuthRepository (T025)');
  });

  group('falls back to the seed', () {
    final fresh = _data(_seeded());

    test('a missing snapshot', () {
      final l = InMemoryDataLayer.fromSnapshot(clock: _clock());
      expect(_data(l), fresh);
    });

    test('corrupt data', () {
      final l = InMemoryDataLayer.fromSnapshot(
        clock: _clock(),
        snapshot: {
          'schemaVersion': 1,
          'seededAt': 'nope',
          'data': {'bookings': 'not a list'},
        },
      );
      expect(_data(l), fresh);
    });

    test('schemaVersion 2', () {
      final snap = _viaJson(_seeded().toSnapshot())..['schemaVersion'] = 2;
      final l = InMemoryDataLayer.fromSnapshot(clock: _clock(), snapshot: snap);
      expect(_data(l), fresh);
    });

    test(
      'PreferencesSnapshotStore reads corrupt JSON as no snapshot',
      () async {
        SharedPreferences.setMockInitialValues({
          PreferencesSnapshotStore.snapshotKey: '{not json',
        });
        final store = PreferencesSnapshotStore(
          await SharedPreferences.getInstance(),
        );
        expect(await store.load(), isNull);
        expect(await store.loadPhoto('missing'), isNull);
      },
    );
  });

  group('saving', () {
    test('several writes in one turn trigger exactly one save', () async {
      final layer = _seeded();
      final store = InMemorySnapshotStore();
      layer.attachStore(store);

      await layer.audit.append(_entry());
      await layer.audit.append(_entry());
      await layer.auth.actAs(SeedIds.userUnverified);
      await layer.notifications.markRead(
        layer.notifications.all.first.id,
        cairo(2026, 11, 14, 10),
      );
      await _turn();
      expect(store.saveCount, 1);
      expect(store.snapshot!['schemaVersion'], 1);

      await layer.audit.append(_entry());
      await _turn();
      expect(store.saveCount, 2);
      layer.detachStore();
    });

    test('a write in any repository saves', () async {
      final layer = _seeded();
      final store = InMemorySnapshotStore();
      layer.attachStore(store);
      var n = 0;

      Future<void> expectSave(Future<void> Function() write) async {
        await write();
        await _turn();
        expect(store.saveCount, ++n);
      }

      await expectSave(() => layer.audit.append(_entry()));
      await expectSave(
        () => layer.notifications.markRead(
          layer.notifications.all.first.id,
          cairo(2026, 11, 14, 9),
        ),
      );
      await expectSave(
        () => layer.payments.savePayment(layer.payments.allPayments.first),
      );
      await expectSave(() => layer.attendance.save(layer.attendance.all.first));
      await expectSave(
        () => layer.assets.saveAsset(layer.assets.allAssets.first),
      );
      await expectSave(
        () => layer.auth.actAs(SeedIds.userUnverified),
      );
      await expectSave(
        () => layer.settings.set(
          SettingKeys.refundPercent,
          50,
          const SettingScope.university(),
          actorId: SeedIds.superAdmin,
        ),
      );
      final b = layer.bookings.allBookings.firstWhere(
        (b) => b.status.name == 'confirmed',
        orElse: () => layer.bookings.allBookings.first,
      );
      await expectSave(() async {
        await layer.bookings.markNoShows();
        await layer.bookings.expireHolds();
        expect(b, isNotNull);
      });
      layer.detachStore();
    });

    test('nothing is saved before a write', () async {
      final store = InMemorySnapshotStore();
      _seeded().attachStore(store);
      await _turn();
      expect(store.saveCount, 0);
    });
  });

  group('reset', () {
    test('clears snapshot and photos but keeps theme and language', () async {
      SharedPreferences.setMockInitialValues({
        'themeMode': 'dark',
        'locale': 'en',
        PreferencesSnapshotStore.snapshotKey: '{}',
      });
      final prefs = await SharedPreferences.getInstance();
      final store = PreferencesSnapshotStore(prefs);
      expect(
        (await store.savePhoto('p1', Uint8List.fromList([1, 2, 3]))).isOk,
        isTrue,
      );
      expect(await store.loadPhoto('p1'), Uint8List.fromList([1, 2, 3]));

      final layer = _seeded()..attachStore(store);
      await layer.reset();

      expect(await store.load(), isNull);
      expect(await store.loadPhoto('p1'), isNull);
      expect(prefs.getKeys().where((k) => k.startsWith('photo/')), isEmpty);
      expect(prefs.getString('themeMode'), 'dark');
      expect(prefs.getString('locale'), 'en');

      // A write after reset does not bring the old data back.
      await layer.audit.append(_entry());
      await _turn();
      expect(await store.load(), isNull);
    });

    test(
      'a failed photo save reports storageFull and keeps the snapshot',
      () async {
        final store = InMemorySnapshotStore(photoQuotaBytes: 4);
        await store.save({'schemaVersion': 1});
        final r = await store.savePhoto('big', Uint8List(10));
        expect(r, isA<Err<void>>());
        expect((r as Err<void>).failure, isA<StorageFull>());
        expect(await store.load(), isNotNull);
      },
    );
  });

  test('a restored layer keeps issuing fresh booking ids and payment refs', () {
    final layer = _seeded();
    final back = InMemoryDataLayer.fromSnapshot(
      clock: _clock(),
      snapshot: _viaJson(layer.toSnapshot()),
      paymentDelay: Duration.zero,
    );
    expect(back.bookings.allBookings.length, layer.bookings.allBookings.length);
  });
}
