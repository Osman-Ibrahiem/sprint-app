import 'package:sprint/features/payments/domain/payment_provider.dart';
import 'package:sprint/features/settings/domain/booking_mode.dart';
import 'package:sprint/features/settings/domain/setting_definition.dart';

/// Typed keys for every setting the BRD marks as one (§4). The registry below
/// is the only place their defaults are written (constitution III).
abstract final class SettingKeys {
  static const bookingMode = SettingKey<BookingMode>('bookingMode');
  static const capacity = SettingKey<int>('capacity');
  static const maxParticipants = SettingKey<int?>('maxParticipants');
  static const bookingWindowDays = SettingKey<int>('bookingWindowDays');
  static const minLeadMinutes = SettingKey<int>('minLeadMinutes');
  static const slotGranularityMinutes = SettingKey<int>('slotGranularityMinutes');
  static const maxRangeHours = SettingKey<int>('maxRangeHours');
  static const sessionMinutes = SettingKey<int>('sessionMinutes');
  static const holdMinutes = SettingKey<int>('holdMinutes');
  static const maxActiveBookingsPerUser =
      SettingKey<int?>('maxActiveBookingsPerUser');
  static const cancellationCutoffHours = SettingKey<int>('cancellationCutoffHours');
  static const refundPercent = SettingKey<int>('refundPercent');
  static const verificationExpiry = SettingKey<MonthDay>('verificationExpiry');
  static const checkInOpensMinutes = SettingKey<int>('checkInOpensMinutes');
  static const reminderLeadMinutes = SettingKey<int>('reminderLeadMinutes');
  static const paymentProvider = SettingKey<PaymentProviderKind>('paymentProvider');
}

const _all = {
  SettingScopeType.university,
  SettingScopeType.facility,
  SettingScopeType.unit,
};
const _uniFacility = {SettingScopeType.university, SettingScopeType.facility};
const _uniOnly = {SettingScopeType.university};
const _unitOnly = {SettingScopeType.unit};

String? Function(int) _range(int min, int max) => (v) =>
    v >= min && v <= max ? null : 'must be between $min and $max';

String? Function(int) _atLeast(int min) =>
    (v) => v >= min ? null : 'must be at least $min';

String? Function(int?) _nullableAtLeast(int min) =>
    (v) => v == null || v >= min ? null : 'must be empty or at least $min';

/// All settings by key name. Defaults are the BRD values (data-model.md).
final Map<String, SettingDefinition<dynamic>> settingRegistry = {
  for (final d in <SettingDefinition<dynamic>>[
    // The seed sets the real mode and capacity per unit; these are only the
    // fallbacks when a unit has no value of its own.
    SettingDefinition<BookingMode>(
      key: SettingKeys.bookingMode,
      defaultValue: BookingMode.exclusive,
      allowedScopes: _unitOnly,
      validate: (_) => null,
    ),
    SettingDefinition<int>(
      key: SettingKeys.capacity,
      defaultValue: 1,
      allowedScopes: _unitOnly,
      validate: _atLeast(1),
    ),
    SettingDefinition<int?>(
      key: SettingKeys.maxParticipants,
      defaultValue: null,
      allowedScopes: _unitOnly,
      validate: _nullableAtLeast(1),
    ),
    SettingDefinition<int>(
      key: SettingKeys.bookingWindowDays, // BR-06
      defaultValue: 7,
      allowedScopes: _all,
      validate: _range(1, 60),
    ),
    SettingDefinition<int>(
      key: SettingKeys.minLeadMinutes, // BR-07
      defaultValue: 0,
      allowedScopes: _all,
      validate: _atLeast(0),
    ),
    SettingDefinition<int>(
      key: SettingKeys.slotGranularityMinutes, // BR-08
      defaultValue: 60,
      allowedScopes: _uniFacility,
      validate: _range(15, 240),
    ),
    SettingDefinition<int>(
      key: SettingKeys.maxRangeHours, // BR-08
      defaultValue: 3,
      allowedScopes: _uniFacility,
      validate: _range(1, 12),
    ),
    SettingDefinition<int>(
      key: SettingKeys.sessionMinutes, // BR-09
      defaultValue: 60,
      allowedScopes: _uniFacility,
      validate: _range(15, 240),
    ),
    SettingDefinition<int>(
      key: SettingKeys.holdMinutes, // BR-12
      defaultValue: 10,
      allowedScopes: _uniFacility,
      validate: _range(1, 60),
    ),
    SettingDefinition<int?>(
      key: SettingKeys.maxActiveBookingsPerUser, // BR-14
      defaultValue: null,
      allowedScopes: _uniOnly,
      validate: _nullableAtLeast(1),
    ),
    SettingDefinition<int>(
      key: SettingKeys.cancellationCutoffHours, // BR-30
      defaultValue: 2,
      allowedScopes: _all,
      validate: _atLeast(0),
    ),
    SettingDefinition<int>(
      key: SettingKeys.refundPercent, // BR-31
      defaultValue: 100,
      allowedScopes: _all,
      validate: _range(0, 100),
    ),
    SettingDefinition<MonthDay>(
      key: SettingKeys.verificationExpiry, // BR-25
      defaultValue: const MonthDay(8, 31),
      allowedScopes: _uniOnly,
      validate: (v) => v.isValid ? null : 'not a valid month and day',
    ),
    SettingDefinition<int>(
      key: SettingKeys.checkInOpensMinutes, // BR-35
      defaultValue: 15,
      allowedScopes: _uniFacility,
      validate: _atLeast(0),
    ),
    SettingDefinition<int>(
      key: SettingKeys.reminderLeadMinutes, // BR-39
      defaultValue: 60,
      allowedScopes: _uniOnly,
      validate: _atLeast(0),
    ),
    SettingDefinition<PaymentProviderKind>(
      key: SettingKeys.paymentProvider, // BR-29
      defaultValue: PaymentProviderKind.fake,
      allowedScopes: _uniOnly,
      validate: (_) => null,
    ),
  ])
    d.key.name: d,
};

/// The registry default of [key].
T defaultOf<T>(SettingKey<T> key) =>
    settingRegistry[key.name]!.defaultValue as T;
