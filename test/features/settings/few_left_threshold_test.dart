import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/features/audit/data/in_memory_audit_log_repository.dart';
import 'package:sprint/features/settings/data/in_memory_settings_repository.dart';
import 'package:sprint/features/settings/domain/setting_definition.dart';
import 'package:sprint/features/settings/domain/setting_registry.dart';

/// BR-45, data-model.md "The new setting".
void main() {
  late InMemorySettingsRepository repo;

  setUp(() {
    repo = InMemorySettingsRepository(audit: InMemoryAuditLogRepository());
  });

  test('defaults to 2', () async {
    expect(await repo.resolve(SettingKeys.fewLeftThreshold), 2);
    expect(defaultOf(SettingKeys.fewLeftThreshold), 2);
  });

  test('a facility value beats the university value and a unit value beats '
      'both', () async {
    const uni = SettingScope.university();
    await repo.set(SettingKeys.fewLeftThreshold, 4, uni, actorId: 'a');
    expect(
      await repo.resolve(
        SettingKeys.fewLeftThreshold,
        unitId: 'u1',
        facilityId: 'f1',
      ),
      4,
    );

    await repo.set(
      SettingKeys.fewLeftThreshold,
      3,
      const SettingScope.facility('f1'),
      actorId: 'a',
    );
    expect(
      await repo.resolve(
        SettingKeys.fewLeftThreshold,
        unitId: 'u1',
        facilityId: 'f1',
      ),
      3,
    );

    await repo.set(
      SettingKeys.fewLeftThreshold,
      1,
      const SettingScope.unit('u1'),
      actorId: 'a',
    );
    expect(
      await repo.resolve(
        SettingKeys.fewLeftThreshold,
        unitId: 'u1',
        facilityId: 'f1',
      ),
      1,
    );
  });

  test('a value below 1 is rejected with "must be at least 1"', () async {
    final result = await repo.set(
      SettingKeys.fewLeftThreshold,
      0,
      const SettingScope.university(),
      actorId: 'a',
    );
    expect(result, isA<Err<void>>());
    final failure = (result as Err<void>).failure as InvalidSetting;
    expect(failure.reason, 'must be at least 1');
    expect(await repo.resolve(SettingKeys.fewLeftThreshold), 2);
  });

  test('the key appears in the registry listing', () {
    expect(settingRegistry, contains('fewLeftThreshold'));
    final def = settingRegistry['fewLeftThreshold']!;
    expect(def.allowedScopes, {
      SettingScopeType.university,
      SettingScopeType.facility,
      SettingScopeType.unit,
    });
  });
}
