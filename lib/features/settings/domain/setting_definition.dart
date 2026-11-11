/// Where a setting value is stored. A unit's value beats its facility's, which
/// beats the university's, which beats the registry default (BRD §4).
enum SettingScopeType { university, facility, unit }

class SettingScope {
  const SettingScope.university()
      : type = SettingScopeType.university,
        id = null;
  const SettingScope.facility(String this.id) : type = SettingScopeType.facility;
  const SettingScope.unit(String this.id) : type = SettingScopeType.unit;

  final SettingScopeType type;
  final String? id;

  @override
  bool operator ==(Object other) =>
      other is SettingScope && other.type == type && other.id == id;

  @override
  int get hashCode => Object.hash(type, id);

  @override
  String toString() => '${type.name}${id == null ? '' : ':$id'}';
}

/// Which level a resolved value came from.
enum SettingLevel { unit, facility, university, registryDefault }

/// A typed handle to one setting.
class SettingKey<T> {
  const SettingKey(this.name);
  final String name;

  @override
  String toString() => name;
}

/// Everything the registry knows about one setting (data-model.md).
class SettingDefinition<T> {
  const SettingDefinition({
    required this.key,
    required this.defaultValue,
    required this.allowedScopes,
    required this.validate,
  });

  final SettingKey<T> key;
  final T defaultValue;
  final Set<SettingScopeType> allowedScopes;

  /// A reason when [value] is not acceptable, otherwise null.
  final String? Function(T value) validate;
}

class ResolvedSetting<T> {
  const ResolvedSetting(this.value, this.level);
  final T value;
  final SettingLevel level;
}

/// A stored value at one scope.
class SettingEntry {
  const SettingEntry(this.keyName, this.value, this.scope);
  final String keyName;
  final Object? value;
  final SettingScope scope;
}

/// A month and day, for `verificationExpiry` (BR-25: 31 August by default).
class MonthDay {
  const MonthDay(this.month, this.day);
  final int month;
  final int day;

  /// Leap day is allowed; 30 February is not.
  bool get isValid {
    if (month < 1 || month > 12 || day < 1) return false;
    return day <= DateTime(2024, month + 1, 0).day;
  }

  @override
  bool operator ==(Object other) =>
      other is MonthDay && other.month == month && other.day == day;

  @override
  int get hashCode => Object.hash(month, day);

  @override
  String toString() => '$month/$day';
}
