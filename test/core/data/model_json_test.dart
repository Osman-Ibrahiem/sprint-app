import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/data/json_converters.dart';
import 'package:sprint/core/seed/seed_data.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/assets/domain/asset.dart';
import 'package:sprint/features/assets/domain/damage_report.dart';
import 'package:sprint/features/attendance/domain/attendance.dart';
import 'package:sprint/features/audit/domain/audit_log.dart';
import 'package:sprint/features/catalogue/domain/closure.dart';
import 'package:sprint/features/catalogue/domain/offer.dart';
import 'package:sprint/features/catalogue/domain/owning_unit.dart';
import 'package:sprint/features/catalogue/domain/trainer.dart';
import 'package:sprint/features/catalogue/domain/trainer_availability.dart';
import 'package:sprint/features/identity/domain/role_assignment.dart';
import 'package:sprint/features/identity/domain/user.dart';
import 'package:sprint/features/identity/domain/verification.dart';
import 'package:sprint/features/notifications/domain/notification.dart';
import 'package:sprint/features/payments/domain/payment.dart';
import 'package:sprint/features/payments/domain/refund.dart';
import 'package:sprint/features/booking/domain/unit_settings.dart';
import 'package:sprint/features/catalogue/domain/bookable_unit.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/domain/operating_hours.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/settings/domain/setting_definition.dart';
import 'package:sprint/features/settings/domain/setting_registry.dart';

import '../../helpers/domain_builders.dart' as b;

/// Sends a model through `toJson`, real JSON text and `fromJson`.
T roundTrip<T>(
  T model,
  Map<String, dynamic> Function(T) toJson,
  T Function(Map<String, dynamic>) fromJson,
) {
  final text = jsonEncode(toJson(model));
  return fromJson(jsonDecode(text) as Map<String, dynamic>);
}

void main() {
  group('hand-built models (research R1)', () {
    test('Booking keeps enums, nullable fields and UTC times', () {
      final full = b.booking(
        start: b.cairo(2026, 11, 20, 17),
        status: BookingStatus.pendingPayment,
        holdExpiresAt: b
            .cairo(2026, 11, 20, 12)
            .add(const Duration(minutes: 10)),
        trainerId: 't1',
        tier: PriceTier.internal,
      );
      final cancelled = b
          .booking(start: b.cairo(2026, 11, 21, 9))
          .copyWith(
            status: BookingStatus.cancelled,
            cancelledBy: CancelledBy.admin,
            cancelReason: 'صيانة',
          );
      for (final m in [full, cancelled]) {
        final back = roundTrip(m, (x) => x.toJson(), Booking.fromJson);
        expect(back, m);
        expect(back.start.isUtc, isTrue);
        expect(back.end.isUtc, isTrue);
      }
      final back = roundTrip(full, (x) => x.toJson(), Booking.fromJson);
      expect(
        back.holdExpiresAt!.millisecondsSinceEpoch,
        full.holdExpiresAt!.millisecondsSinceEpoch,
      );
      expect(
        roundTrip(cancelled, (x) => x.toJson(), Booking.fromJson).holdExpiresAt,
        isNull,
      );
    });

    test('Facility, BookableUnit, OperatingHours', () {
      final f = b.facility(
        isFree: true,
        requiresTrainer: true,
        type: FacilityType.swimming,
      );
      expect(roundTrip(f, (x) => x.toJson(), Facility.fromJson), f);
      final u = b.unit(isActive: false);
      expect(roundTrip(u, (x) => x.toJson(), BookableUnit.fromJson), u);
      for (final h in b.dailyHours('u1')) {
        expect(roundTrip(h, (x) => x.toJson(), OperatingHours.fromJson), h);
      }
    });

    test('UnitSettings, with a nullable and an enum', () {
      final s = b.settings(mode: BookingMode.exclusive, capacity: 7);
      expect(roundTrip(s, (x) => x.toJson(), UnitSettings.fromJson), s);
    });
  });

  group('every model the seed builds', () {
    final now = b.cairo(2026, 11, 14, 8);
    final d = SeedData.build(now);

    void check<T>(
      String name,
      List<T> items,
      Map<String, dynamic> Function(T) toJson,
      T Function(Map<String, dynamic>) fromJson,
    ) {
      test(name, () {
        expect(items, isNotEmpty);
        for (final m in items) {
          expect(roundTrip(m, toJson, fromJson), m, reason: '$m');
        }
      });
    }

    check('OwningUnit', d.owningUnits, (x) => x.toJson(), OwningUnit.fromJson);
    check('Facility', d.facilities, (x) => x.toJson(), Facility.fromJson);
    check('BookableUnit', d.units, (x) => x.toJson(), BookableUnit.fromJson);
    check(
      'OperatingHours',
      d.hours,
      (x) => x.toJson(),
      OperatingHours.fromJson,
    );
    check('Closure', d.closures, (x) => x.toJson(), Closure.fromJson);
    check('Price', d.prices, (x) => x.toJson(), Price.fromJson);
    check('Offer', d.offers, (x) => x.toJson(), Offer.fromJson);
    check('Trainer', d.trainers, (x) => x.toJson(), Trainer.fromJson);
    check(
      'TrainerAvailability',
      d.trainerAvailability,
      (x) => x.toJson(),
      TrainerAvailability.fromJson,
    );
    check('User', d.users, (x) => x.toJson(), User.fromJson);
    check(
      'Verification',
      d.verifications,
      (x) => x.toJson(),
      Verification.fromJson,
    );
    check(
      'RoleAssignment',
      d.roleAssignments,
      (x) => x.toJson(),
      RoleAssignment.fromJson,
    );
    check('Booking', d.bookings, (x) => x.toJson(), Booking.fromJson);
    check('Payment', d.payments, (x) => x.toJson(), Payment.fromJson);
    check('Refund', d.refunds, (x) => x.toJson(), Refund.fromJson);
    check('Attendance', d.attendance, (x) => x.toJson(), Attendance.fromJson);
    check(
      'Notification',
      d.notifications,
      (x) => x.toJson(),
      Notification.fromJson,
    );
    check('Asset', d.assets, (x) => x.toJson(), Asset.fromJson);
    check(
      'DamageReport',
      d.damageReports,
      (x) => x.toJson(),
      DamageReport.fromJson,
    );
    check('AuditLog', d.auditLog, (x) => x.toJson(), AuditLog.fromJson);
  });

  group('settings values', () {
    test('MonthDay round trips through its converter', () {
      const c = MonthDayConverter();
      expect(
        c.fromJson(c.toJson(const MonthDay(8, 31))),
        const MonthDay(8, 31),
      );
    });

    test('every registry default survives the codec by key name', () {
      for (final def in settingRegistry.values) {
        final json = jsonDecode(
          jsonEncode(SettingValueCodec.encode(def.defaultValue)),
        );
        expect(
          SettingValueCodec.decode(def.key.name, json),
          def.defaultValue,
          reason: def.key.name,
        );
      }
    });
  });
}
