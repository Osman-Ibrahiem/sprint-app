import 'package:sprint/core/data/json_converters.dart';
import 'package:sprint/core/seed/seed_data.dart';
import 'package:sprint/features/assets/domain/asset.dart';
import 'package:sprint/features/assets/domain/damage_report.dart';
import 'package:sprint/features/attendance/domain/attendance.dart';
import 'package:sprint/features/audit/domain/audit_log.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/catalogue/domain/bookable_unit.dart';
import 'package:sprint/features/catalogue/domain/closure.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/domain/offer.dart';
import 'package:sprint/features/catalogue/domain/operating_hours.dart';
import 'package:sprint/features/catalogue/domain/owning_unit.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/catalogue/domain/trainer.dart';
import 'package:sprint/features/catalogue/domain/trainer_availability.dart';
import 'package:sprint/features/identity/domain/role_assignment.dart';
import 'package:sprint/features/identity/domain/user.dart';
import 'package:sprint/features/identity/domain/verification.dart';
import 'package:sprint/features/notifications/domain/notification.dart';
import 'package:sprint/features/payments/domain/payment.dart';
import 'package:sprint/features/payments/domain/refund.dart';
import 'package:sprint/features/settings/domain/setting_definition.dart';

/// Turns every repository list of a [SeedData] into JSON and back (research
/// R1). The names are the keys of the snapshot's `data` object.
abstract final class SnapshotCodec {
  static Map<String, Object?> encode(SeedData d) => {
    'owningUnits': _l(d.owningUnits, (e) => e.toJson()),
    'facilities': _l(d.facilities, (e) => e.toJson()),
    'units': _l(d.units, (e) => e.toJson()),
    'hours': _l(d.hours, (e) => e.toJson()),
    'closures': _l(d.closures, (e) => e.toJson()),
    'prices': _l(d.prices, (e) => e.toJson()),
    'offers': _l(d.offers, (e) => e.toJson()),
    'trainers': _l(d.trainers, (e) => e.toJson()),
    'trainerAvailability': _l(d.trainerAvailability, (e) => e.toJson()),
    'users': _l(d.users, (e) => e.toJson()),
    'verifications': _l(d.verifications, (e) => e.toJson()),
    'roleAssignments': _l(d.roleAssignments, (e) => e.toJson()),
    'bookings': _l(d.bookings, (e) => e.toJson()),
    'payments': _l(d.payments, (e) => e.toJson()),
    'refunds': _l(d.refunds, (e) => e.toJson()),
    'attendance': _l(d.attendance, (e) => e.toJson()),
    'notifications': _l(d.notifications, (e) => e.toJson()),
    'assets': _l(d.assets, (e) => e.toJson()),
    'damageReports': _l(d.damageReports, (e) => e.toJson()),
    'settings': _l(d.settings, _encodeSetting),
    'auditLog': _l(d.auditLog, (e) => e.toJson()),
  };

  /// Throws when [data] is malformed; the caller falls back to the seed.
  static SeedData decode(Map<String, Object?> data) => SeedData(
    owningUnits: _r(data, 'owningUnits', OwningUnit.fromJson),
    facilities: _r(data, 'facilities', Facility.fromJson),
    units: _r(data, 'units', BookableUnit.fromJson),
    hours: _r(data, 'hours', OperatingHours.fromJson),
    closures: _r(data, 'closures', Closure.fromJson),
    prices: _r(data, 'prices', Price.fromJson),
    offers: _r(data, 'offers', Offer.fromJson),
    trainers: _r(data, 'trainers', Trainer.fromJson),
    trainerAvailability: _r(
      data,
      'trainerAvailability',
      TrainerAvailability.fromJson,
    ),
    users: _r(data, 'users', User.fromJson),
    verifications: _r(data, 'verifications', Verification.fromJson),
    roleAssignments: _r(data, 'roleAssignments', RoleAssignment.fromJson),
    bookings: _r(data, 'bookings', Booking.fromJson),
    payments: _r(data, 'payments', Payment.fromJson),
    refunds: _r(data, 'refunds', Refund.fromJson),
    attendance: _r(data, 'attendance', Attendance.fromJson),
    notifications: _r(data, 'notifications', Notification.fromJson),
    assets: _r(data, 'assets', Asset.fromJson),
    damageReports: _r(data, 'damageReports', DamageReport.fromJson),
    settings: _r(data, 'settings', _decodeSetting),
    auditLog: _r(data, 'auditLog', AuditLog.fromJson),
  );

  static List<Map<String, Object?>> _l<T>(
    List<T> items,
    Map<String, Object?> Function(T) f,
  ) => [for (final i in items) f(i)];

  static List<T> _r<T>(
    Map<String, Object?> data,
    String key,
    T Function(Map<String, dynamic>) f,
  ) => [
    for (final e in data[key]! as List<Object?>)
      f(Map<String, dynamic>.from(e! as Map)),
  ];

  static Map<String, Object?> _encodeSetting(SettingEntry e) => {
    'key': e.keyName,
    'scope': e.scope.type.name,
    'scopeId': e.scope.id,
    'value': SettingValueCodec.encode(e.value),
  };

  static SettingEntry _decodeSetting(Map<String, dynamic> j) {
    final id = j['scopeId'] as String?;
    final scope = switch (j['scope']! as String) {
      'facility' => SettingScope.facility(id!),
      'unit' => SettingScope.unit(id!),
      _ => const SettingScope.university(),
    };
    final key = j['key']! as String;
    return SettingEntry(key, SettingValueCodec.decode(key, j['value']), scope);
  }
}
