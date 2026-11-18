import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/features/audit/data/in_memory_audit_log_repository.dart';
import 'package:sprint/features/booking/domain/unit_settings.dart';
import 'package:sprint/features/settings/data/in_memory_settings_repository.dart';
import 'package:sprint/features/settings/domain/setting_definition.dart';
import 'package:sprint/features/settings/domain/setting_registry.dart';

/// BR-46: the longest a Hold can be extended while a payment is pending.
void main() {
  late InMemorySettingsRepository repo;

  setUp(() {
    repo = InMemorySettingsRepository(audit: InMemoryAuditLogRepository());
  });

  test('defaults to 20 and reaches UnitSettings', () async {
    expect(await repo.resolve(SettingKeys.holdMaxMinutes), 20);
    expect(UnitSettings.registryDefaults().holdMaxMinutes, 20);
    final d = await UnitSettings.resolve(repo, unitId: 'u1', facilityId: 'f1');
    expect(d.holdMaxMinutes, 20);
  });

  test('a facility override wins over the university value', () async {
    await repo.set(SettingKeys.holdMaxMinutes, 30,
        const SettingScope.university(),
        actorId: 'a');
    await repo.set(
        SettingKeys.holdMaxMinutes, 45, const SettingScope.facility('f1'),
        actorId: 'a');
    expect(await repo.resolve(SettingKeys.holdMaxMinutes, facilityId: 'f1'), 45);
    expect(await repo.resolve(SettingKeys.holdMaxMinutes, facilityId: 'f2'), 30);
  });

  test('range is 1 to 120 and a unit scope is refused', () async {
    for (final bad in [0, 121]) {
      final r = await repo.set(
          SettingKeys.holdMaxMinutes, bad, const SettingScope.university(),
          actorId: 'a');
      expect(r, isA<Err<void>>(), reason: '$bad');
    }
    final unit = await repo.set(
        SettingKeys.holdMaxMinutes, 30, const SettingScope.unit('u1'),
        actorId: 'a');
    expect(unit, isA<Err<void>>());
  });
}
