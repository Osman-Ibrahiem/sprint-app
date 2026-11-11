import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/features/settings/domain/setting_definition.dart';

/// Reads and changes settings with university -> facility -> unit inheritance.
/// Every number or behaviour the BRD marks as a setting goes through here
/// (constitution III).
abstract interface class SettingsRepository {
  /// Walks unit -> facility -> university -> registry default.
  Future<T> resolve<T>(
    SettingKey<T> key, {
    String? unitId,
    String? facilityId,
  });

  /// Like [resolve], and says which level the value came from.
  Future<ResolvedSetting<T>> resolveWithSource<T>(
    SettingKey<T> key, {
    String? unitId,
    String? facilityId,
  });

  /// Validates type, range and allowed scope, applies the value and writes an
  /// audit entry. Out-of-range or out-of-scope values change nothing and
  /// return [InvalidSetting].
  Future<Result<void>> set<T>(
    SettingKey<T> key,
    T value,
    SettingScope scope, {
    required String actorId,
  });

  /// Removes the value at [scope] so the next level applies.
  Future<Result<void>> clear<T>(
    SettingKey<T> key,
    SettingScope scope, {
    required String actorId,
  });

  /// The resolved value, now and after every change.
  Stream<T> watch<T>(
    SettingKey<T> key, {
    String? unitId,
    String? facilityId,
  });
}

/// A hook that can refuse a change because of existing data (BR-04). Returns
/// null to allow it.
typedef SettingChangeGuard = Future<Failure?> Function(
  SettingKey<dynamic> key,
  Object? value,
  SettingScope scope,
);
