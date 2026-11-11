import 'dart:async';

import 'package:clock/clock.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/features/audit/domain/audit_log.dart';
import 'package:sprint/features/audit/domain/audit_log_repository.dart';
import 'package:sprint/features/settings/domain/setting_definition.dart';
import 'package:sprint/features/settings/domain/setting_registry.dart';
import 'package:sprint/features/settings/domain/settings_repository.dart';

class InMemorySettingsRepository implements SettingsRepository {
  InMemorySettingsRepository({
    required this.audit,
    Iterable<SettingEntry> seed = const [],
    this.guard,
    this.clock = const Clock(),
  }) {
    for (final e in seed) {
      _values[_slot(e.keyName, e.scope)] = e.value;
    }
  }

  final AuditLogRepository audit;
  final Clock clock;
  final Map<String, Object?> _values = {};
  final _changes = StreamController<void>.broadcast();

  /// Refuses changes that clash with existing bookings (BR-04). Can be set
  /// after construction, because the guard reads bookings, which need this
  /// repository first.
  SettingChangeGuard? guard;

  String _slot(String name, SettingScope s) => '$name|${s.type.name}|${s.id ?? ''}';

  ResolvedSetting<T> _resolve<T>(
    SettingKey<T> key,
    String? unitId,
    String? facilityId,
  ) {
    if (unitId != null) {
      final k = _slot(key.name, SettingScope.unit(unitId));
      if (_values.containsKey(k)) {
        return ResolvedSetting(_values[k] as T, SettingLevel.unit);
      }
    }
    if (facilityId != null) {
      final k = _slot(key.name, SettingScope.facility(facilityId));
      if (_values.containsKey(k)) {
        return ResolvedSetting(_values[k] as T, SettingLevel.facility);
      }
    }
    final u = _slot(key.name, const SettingScope.university());
    if (_values.containsKey(u)) {
      return ResolvedSetting(_values[u] as T, SettingLevel.university);
    }
    return ResolvedSetting(defaultOf(key), SettingLevel.registryDefault);
  }

  @override
  Future<T> resolve<T>(
    SettingKey<T> key, {
    String? unitId,
    String? facilityId,
  }) async =>
      _resolve(key, unitId, facilityId).value;

  @override
  Future<ResolvedSetting<T>> resolveWithSource<T>(
    SettingKey<T> key, {
    String? unitId,
    String? facilityId,
  }) async =>
      _resolve(key, unitId, facilityId);

  @override
  Future<Result<void>> set<T>(
    SettingKey<T> key,
    T value,
    SettingScope scope, {
    required String actorId,
  }) async {
    final def = settingRegistry[key.name] as SettingDefinition<T>?;
    if (def == null) return Err(InvalidSetting(key.name, 'unknown setting'));
    if (!def.allowedScopes.contains(scope.type)) {
      return Err(InvalidSetting(key.name, 'not allowed at ${scope.type.name} level'));
    }
    final reason = def.validate(value);
    if (reason != null) return Err(InvalidSetting(key.name, reason));
    final refused = await guard?.call(key, value, scope);
    if (refused != null) return Err(refused);

    final slot = _slot(key.name, scope);
    final before = _values.containsKey(slot) ? _fmt(_values[slot]) : null;
    _values[slot] = value;
    await audit.append(
      AuditLog(
        actorId: actorId,
        action: 'setting.set',
        entity: 'Setting',
        entityId: '${key.name}@$scope',
        before: before,
        after: _fmt(value),
        at: clock.now().toUtc(),
      ),
    );
    _changes.add(null);
    return const Ok<void>(null);
  }

  @override
  Future<Result<void>> clear<T>(
    SettingKey<T> key,
    SettingScope scope, {
    required String actorId,
  }) async {
    final slot = _slot(key.name, scope);
    if (!_values.containsKey(slot)) return const Ok<void>(null);
    final before = _fmt(_values.remove(slot));
    await audit.append(
      AuditLog(
        actorId: actorId,
        action: 'setting.clear',
        entity: 'Setting',
        entityId: '${key.name}@$scope',
        before: before,
        at: clock.now().toUtc(),
      ),
    );
    _changes.add(null);
    return const Ok<void>(null);
  }

  @override
  Stream<T> watch<T>(
    SettingKey<T> key, {
    String? unitId,
    String? facilityId,
  }) async* {
    yield _resolve(key, unitId, facilityId).value;
    await for (final _ in _changes.stream) {
      yield _resolve(key, unitId, facilityId).value;
    }
  }

  static String? _fmt(Object? v) => v is Enum ? v.name : v?.toString();
}
