import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sprint/features/settings/domain/booking_mode.dart';
import 'package:sprint/features/settings/domain/setting_definition.dart';
import 'package:sprint/features/settings/domain/setting_registry.dart';
import 'package:sprint/features/settings/domain/settings_repository.dart';

export 'package:sprint/features/settings/domain/booking_mode.dart';

part 'unit_settings.freezed.dart';

/// Every setting the booking rules need, already resolved for one unit. The
/// rule services take this snapshot, so they stay pure and never read a
/// constant (constitution III).
@freezed
abstract class UnitSettings with _$UnitSettings {
  const factory UnitSettings({
    required BookingMode bookingMode,
    required int capacity,
    int? maxParticipants,
    required int bookingWindowDays,
    required int minLeadMinutes,
    required int slotGranularityMinutes,
    required int maxRangeHours,
    required int sessionMinutes,
    required int holdMinutes,
    int? maxActiveBookingsPerUser,
    required int cancellationCutoffHours,
    required int refundPercent,
    required int checkInOpensMinutes,
    required int reminderLeadMinutes,
  }) = _UnitSettings;

  /// The BRD defaults, straight from the registry. Used in tests and as a
  /// starting point; real values come from [resolve].
  factory UnitSettings.registryDefaults() => UnitSettings(
        bookingMode: defaultOf(SettingKeys.bookingMode),
        capacity: defaultOf(SettingKeys.capacity),
        maxParticipants: defaultOf(SettingKeys.maxParticipants),
        bookingWindowDays: defaultOf(SettingKeys.bookingWindowDays),
        minLeadMinutes: defaultOf(SettingKeys.minLeadMinutes),
        slotGranularityMinutes: defaultOf(SettingKeys.slotGranularityMinutes),
        maxRangeHours: defaultOf(SettingKeys.maxRangeHours),
        sessionMinutes: defaultOf(SettingKeys.sessionMinutes),
        holdMinutes: defaultOf(SettingKeys.holdMinutes),
        maxActiveBookingsPerUser: defaultOf(SettingKeys.maxActiveBookingsPerUser),
        cancellationCutoffHours: defaultOf(SettingKeys.cancellationCutoffHours),
        refundPercent: defaultOf(SettingKeys.refundPercent),
        checkInOpensMinutes: defaultOf(SettingKeys.checkInOpensMinutes),
        reminderLeadMinutes: defaultOf(SettingKeys.reminderLeadMinutes),
      );

  /// Resolves every key with unit -> facility -> university -> default.
  static Future<UnitSettings> resolve(
    SettingsRepository repo, {
    String? unitId,
    String? facilityId,
  }) async {
    Future<T> r<T>(SettingKey<T> k) =>
        repo.resolve(k, unitId: unitId, facilityId: facilityId);
    return UnitSettings(
      bookingMode: await r(SettingKeys.bookingMode),
      capacity: await r(SettingKeys.capacity),
      maxParticipants: await r(SettingKeys.maxParticipants),
      bookingWindowDays: await r(SettingKeys.bookingWindowDays),
      minLeadMinutes: await r(SettingKeys.minLeadMinutes),
      slotGranularityMinutes: await r(SettingKeys.slotGranularityMinutes),
      maxRangeHours: await r(SettingKeys.maxRangeHours),
      sessionMinutes: await r(SettingKeys.sessionMinutes),
      holdMinutes: await r(SettingKeys.holdMinutes),
      maxActiveBookingsPerUser: await r(SettingKeys.maxActiveBookingsPerUser),
      cancellationCutoffHours: await r(SettingKeys.cancellationCutoffHours),
      refundPercent: await r(SettingKeys.refundPercent),
      checkInOpensMinutes: await r(SettingKeys.checkInOpensMinutes),
      reminderLeadMinutes: await r(SettingKeys.reminderLeadMinutes),
    );
  }
}
