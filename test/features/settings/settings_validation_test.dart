import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/features/audit/data/in_memory_audit_log_repository.dart';
import 'package:sprint/features/settings/data/in_memory_settings_repository.dart';
import 'package:sprint/features/settings/domain/setting_definition.dart';
import 'package:sprint/features/settings/domain/setting_registry.dart';

void main() {
  late InMemoryAuditLogRepository audit;
  late InMemorySettingsRepository repo;

  setUp(() {
    audit = InMemoryAuditLogRepository();
    repo = InMemorySettingsRepository(audit: audit);
  });

  Future<void> expectRejected<T>(
    SettingKey<T> key,
    T value,
    SettingScope scope,
  ) async {
    final before = await repo.resolve(key, unitId: 'u1', facilityId: 'f1');
    final result = await repo.set(key, value, scope, actorId: 'admin');
    expect(result, isA<Err<void>>(), reason: '${key.name}=$value at $scope');
    expect((result as Err<void>).failure, isA<InvalidSetting>());
    expect((result.failure as InvalidSetting).key, key.name);
    // Nothing changed and nothing was audited.
    expect(await repo.resolve(key, unitId: 'u1', facilityId: 'f1'), before);
    expect(await audit.list(), isEmpty);
  }

  test('out-of-range values are rejected and change nothing', () async {
    const uni = SettingScope.university();
    await expectRejected(SettingKeys.bookingWindowDays, 0, uni);
    await expectRejected(SettingKeys.bookingWindowDays, 61, uni);
    await expectRejected(SettingKeys.minLeadMinutes, -5, uni);
    await expectRejected(SettingKeys.holdMinutes, 0, uni);
    await expectRejected(SettingKeys.cancellationCutoffHours, -1, uni);
    await expectRejected(SettingKeys.refundPercent, 101, uni);
    await expectRejected(SettingKeys.refundPercent, -1, uni);
    await expectRejected(SettingKeys.slotGranularityMinutes, 10, uni);
    await expectRejected(SettingKeys.maxRangeHours, 13, uni);
    await expectRejected(SettingKeys.maxActiveBookingsPerUser, 0, uni);
    await expectRejected(SettingKeys.verificationExpiry, const MonthDay(2, 30), uni);
    await expectRejected(
      SettingKeys.capacity,
      0,
      const SettingScope.unit('u1'),
    );
  });

  test('values at a scope the key does not allow are rejected', () async {
    // slotGranularityMinutes: university and facility only.
    await expectRejected(
      SettingKeys.slotGranularityMinutes,
      30,
      const SettingScope.unit('u1'),
    );
    // capacity and bookingMode: unit only.
    await expectRejected(
      SettingKeys.capacity,
      5,
      const SettingScope.facility('f1'),
    );
    await expectRejected(
      SettingKeys.capacity,
      5,
      const SettingScope.university(),
    );
    // reminderLeadMinutes and maxActiveBookingsPerUser: university only.
    await expectRejected(
      SettingKeys.reminderLeadMinutes,
      30,
      const SettingScope.facility('f1'),
    );
  });

  test('a valid set is applied and writes an audit entry', () async {
    final result = await repo.set(
      SettingKeys.holdMinutes,
      15,
      const SettingScope.facility('f1'),
      actorId: 'admin-1',
    );
    expect(result, isA<Ok<void>>());
    expect(await repo.resolve(SettingKeys.holdMinutes, facilityId: 'f1'), 15);

    final entries = await audit.list();
    expect(entries, hasLength(1));
    final e = entries.single;
    expect(e.actorId, 'admin-1');
    expect(e.action, 'setting.set');
    expect(e.entity, 'Setting');
    expect(e.entityId, contains('holdMinutes'));
    expect(e.before, isNull); // nothing was stored at that level before
    expect(e.after, '15');
  });

  test('an audit entry records the previous value on change and on clear',
      () async {
    const scope = SettingScope.facility('f1');
    await repo.set(SettingKeys.holdMinutes, 15, scope, actorId: 'a');
    await repo.set(SettingKeys.holdMinutes, 20, scope, actorId: 'a');
    await repo.clear(SettingKeys.holdMinutes, scope, actorId: 'a');
    final entries = await audit.list();
    expect(entries.map((e) => e.action), [
      'setting.set',
      'setting.set',
      'setting.clear',
    ]);
    expect(entries[1].before, '15');
    expect(entries[1].after, '20');
    expect(entries[2].before, '20');
    expect(entries[2].after, isNull);
  });

  test('a nullable setting can be set to null (no limit)', () async {
    await repo.set(
      SettingKeys.maxActiveBookingsPerUser,
      3,
      const SettingScope.university(),
      actorId: 'a',
    );
    expect(await repo.resolve(SettingKeys.maxActiveBookingsPerUser), 3);
    await repo.set(
      SettingKeys.maxActiveBookingsPerUser,
      null,
      const SettingScope.university(),
      actorId: 'a',
    );
    expect(await repo.resolve(SettingKeys.maxActiveBookingsPerUser), isNull);
  });

  test('a change guard can refuse a change (BR-04) and nothing is written',
      () async {
    final guarded = InMemorySettingsRepository(
      audit: audit,
      guard: (key, value, scope) async =>
          key == SettingKeys.capacity ? const Conflict('bookings exceed') : null,
    );
    final r = await guarded.set(
      SettingKeys.capacity,
      5,
      const SettingScope.unit('u1'),
      actorId: 'a',
    );
    expect((r as Err<void>).failure, isA<Conflict>());
    // Still the registry default (1), not the refused 5.
    expect(await guarded.resolve(SettingKeys.capacity, unitId: 'u1'), 1);
    expect(await audit.list(), isEmpty);
  });
}
