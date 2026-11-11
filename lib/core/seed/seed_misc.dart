import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/features/assets/domain/asset.dart';
import 'package:sprint/features/assets/domain/damage_report.dart';
import 'package:sprint/features/audit/domain/audit_log.dart';
import 'package:sprint/features/catalogue/domain/offer.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/notifications/domain/notification.dart';

List<Offer> seedOffers(DateTime now) {
  final today = CairoTime.toCairo(now);
  DateTime day(int offset) =>
      CairoTime.atWallClock(today.year, today.month, today.day + offset);
  return [
    // Quiet mornings at the gym: Sunday to Wednesday, 8:00 - 12:00.
    Offer(
      id: 'of-1',
      scope: OfferScope.facility,
      scopeId: SeedIds.gymFacility,
      discountPercent: 15,
      days: const {7, 1, 2, 3},
      fromMinutes: 8 * 60,
      toMinutes: 12 * 60,
      validFrom: day(-30),
      validTo: day(60),
    ),
    // Thursday afternoons at the pool, for the internal tier only.
    Offer(
      id: 'of-2',
      scope: OfferScope.facility,
      scopeId: SeedIds.poolFacility,
      discountPercent: 20,
      days: const {4},
      fromMinutes: 14 * 60,
      toMinutes: 18 * 60,
      tier: PriceTier.internal,
      validFrom: day(-30),
      validTo: day(60),
    ),
  ];
}

List<Notification> seedNotifications(DateTime now) => [
      Notification(
        id: 'nt-1',
        userId: SeedIds.bookerInternal,
        type: 'booking.confirmed',
        payload: const {'code': 'SP-1009'},
        sentAt: now.subtract(const Duration(days: 1)),
      ),
      Notification(
        id: 'nt-2',
        userId: SeedIds.bookerInternal,
        type: 'booking.reminder',
        payload: const {'code': 'SP-1009'},
        sentAt: now.subtract(const Duration(hours: 3)),
      ),
      Notification(
        id: 'nt-3',
        userId: SeedIds.bookerInternal,
        type: 'booking.cancelled_by_admin',
        payload: const {'code': 'SP-1015'},
        sentAt: now.subtract(const Duration(days: 2)),
        readAt: now.subtract(const Duration(days: 2)),
      ),
      Notification(
        id: 'nt-4',
        userId: SeedIds.bookerExternal,
        type: 'booking.confirmed',
        payload: const {'code': 'SP-1010'},
        sentAt: now.subtract(const Duration(days: 1)),
      ),
      Notification(
        id: 'nt-5',
        userId: SeedIds.userUnverified,
        type: 'verification.pending',
        sentAt: now.subtract(const Duration(days: 3)),
      ),
    ];

const seedAssets = <Asset>[
  Asset(
    id: 'as-1',
    facilityId: SeedIds.poolFacility,
    name: 'حبال الحارات',
    code: 'POOL-LANE-ROPE',
    quantity: 7,
    custodianId: SeedIds.unitAdmin,
    status: AssetStatus.ok,
  ),
  Asset(
    id: 'as-2',
    facilityId: SeedIds.gymFacility,
    name: 'أجهزة الجري',
    code: 'GYM-TREADMILL',
    quantity: 6,
    custodianId: SeedIds.unitAdmin,
    status: AssetStatus.damaged,
  ),
  Asset(
    id: 'as-3',
    facilityId: SeedIds.futsalFacility,
    name: 'مرميان خماسي',
    code: 'FUT-GOAL',
    quantity: 2,
    custodianId: SeedIds.hallManager,
    status: AssetStatus.ok,
  ),
  Asset(
    id: 'as-4',
    facilityId: SeedIds.tennisFacility,
    name: 'شبكة تنس',
    code: 'TEN-NET',
    quantity: 2,
    custodianId: SeedIds.hallManager,
    status: AssetStatus.underRepair,
  ),
];

const seedDamageReports = <DamageReport>[
  DamageReport(
    id: 'dr-1',
    assetId: 'as-2',
    reportedBy: SeedIds.trainer1,
    description: 'سير جهاز الجري رقم ٣ بيفصل أثناء التشغيل.',
    status: DamageReportStatus.open,
  ),
];

List<AuditLog> seedAuditLog(DateTime now) => [
      AuditLog(
        actorId: SeedIds.superAdmin,
        action: 'setting.set',
        entity: 'Setting',
        entityId: 'cancellationCutoffHours@facility:${SeedIds.poolFacility}',
        before: null,
        after: '4',
        at: now.subtract(const Duration(days: 20)),
      ),
      AuditLog(
        actorId: SeedIds.unitAdmin,
        action: 'setting.set',
        entity: 'Setting',
        entityId: 'refundPercent@unit:${SeedIds.gym1}',
        before: null,
        after: '50',
        at: now.subtract(const Duration(days: 12)),
      ),
      AuditLog(
        actorId: SeedIds.unitAdmin,
        action: 'closure.create',
        entity: 'Closure',
        entityId: 'cl-1',
        after: 'صيانة العشب الصناعي',
        at: now.subtract(const Duration(days: 2)),
      ),
    ];
