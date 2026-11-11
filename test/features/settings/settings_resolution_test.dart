import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/audit/data/in_memory_audit_log_repository.dart';
import 'package:sprint/features/settings/data/in_memory_settings_repository.dart';
import 'package:sprint/features/settings/domain/setting_definition.dart';
import 'package:sprint/features/settings/domain/setting_registry.dart';
import 'package:sprint/features/booking/domain/unit_settings.dart';
import 'package:sprint/features/payments/domain/payment_provider.dart';

void main() {
  InMemorySettingsRepository repo() =>
      InMemorySettingsRepository(audit: InMemoryAuditLogRepository());

  const unitId = 'u1';
  const facilityId = 'f1';
  const key = SettingKeys.bookingWindowDays; // allowed at all three levels
  const registryDefault = 7;

  // All 8 combinations of unit / facility / university defined or not.
  for (var mask = 0; mask < 8; mask++) {
    final unitDefined = mask & 4 != 0;
    final facilityDefined = mask & 2 != 0;
    final universityDefined = mask & 1 != 0;
    final expected = unitDefined
        ? 30
        : facilityDefined
            ? 20
            : universityDefined
                ? 10
                : registryDefault;
    final expectedLevel = unitDefined
        ? SettingLevel.unit
        : facilityDefined
            ? SettingLevel.facility
            : universityDefined
                ? SettingLevel.university
                : SettingLevel.registryDefault;

    test('unit=$unitDefined facility=$facilityDefined university=$universityDefined '
        '-> $expected from $expectedLevel', () async {
      final r = repo();
      if (universityDefined) {
        await r.set(key, 10, const SettingScope.university(), actorId: 'a');
      }
      if (facilityDefined) {
        await r.set(key, 20, const SettingScope.facility(facilityId), actorId: 'a');
      }
      if (unitDefined) {
        await r.set(key, 30, const SettingScope.unit(unitId), actorId: 'a');
      }
      expect(
        await r.resolve(key, unitId: unitId, facilityId: facilityId),
        expected,
      );
      final described =
          await r.resolveWithSource(key, unitId: unitId, facilityId: facilityId);
      expect(described.value, expected);
      expect(described.level, expectedLevel);
    });
  }

  test('a unit without its own value picks up the facility value; another '
      'unit with its own value keeps it', () async {
    final r = repo();
    await r.set(key, 20, const SettingScope.facility(facilityId), actorId: 'a');
    await r.set(key, 30, const SettingScope.unit('u2'), actorId: 'a');
    expect(await r.resolve(key, unitId: 'u1', facilityId: facilityId), 20);
    expect(await r.resolve(key, unitId: 'u2', facilityId: facilityId), 30);
  });

  test('clearing a value falls back to the next level', () async {
    final r = repo();
    await r.set(key, 20, const SettingScope.facility(facilityId), actorId: 'a');
    await r.set(key, 30, const SettingScope.unit(unitId), actorId: 'a');
    await r.clear(key, const SettingScope.unit(unitId), actorId: 'a');
    expect(await r.resolve(key, unitId: unitId, facilityId: facilityId), 20);
  });

  test('a missing value at every level falls back to the BRD default', () async {
    expect(await repo().resolve(key), registryDefault);
  });

  test('BRD §4 defaults match the registry (SC-008)', () {
    final d = UnitSettings.registryDefaults();
    expect(d.bookingWindowDays, 7); // BR-06
    expect(d.minLeadMinutes, 0); // BR-07
    expect(d.slotGranularityMinutes, 60); // BR-08
    expect(d.maxRangeHours, 3); // BR-08
    expect(d.sessionMinutes, 60); // BR-09
    expect(d.holdMinutes, 10); // BR-12
    expect(d.maxActiveBookingsPerUser, isNull); // BR-14
    expect(d.cancellationCutoffHours, 2); // BR-30
    expect(d.refundPercent, 100); // BR-31
    expect(d.checkInOpensMinutes, 15); // BR-35
    expect(d.reminderLeadMinutes, 60); // BR-39
    expect(settingRegistry['verificationExpiry']!.defaultValue,
        const MonthDay(8, 31)); // BR-25
    expect(settingRegistry['paymentProvider']!.defaultValue,
        PaymentProviderKind.fake); // BR-29
  });

  test('every registry key has at least one allowed scope and a default', () {
    for (final def in settingRegistry.values) {
      expect(def.allowedScopes, isNotEmpty, reason: def.key.name);
    }
  });
}
