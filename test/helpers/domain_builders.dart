import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/unit_settings.dart';
import 'package:sprint/features/catalogue/domain/bookable_unit.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/domain/operating_hours.dart';
import 'package:sprint/features/catalogue/domain/price.dart';

/// A Cairo wall-clock moment as a UTC instant.
DateTime cairo(int y, int m, int d, [int h = 0, int min = 0]) {
  CairoTime.ensureInitialized();
  return CairoTime.atWallClock(y, m, d, h, min);
}

Facility facility({
  String id = 'f1',
  String owningUnitId = 'ou1',
  bool isFree = false,
  bool requiresTrainer = false,
  FacilityType type = FacilityType.gym,
}) =>
    Facility(
      id: id,
      owningUnitId: owningUnitId,
      name: 'منشأة',
      type: type,
      description: 'وصف',
      location: 'الموقع',
      isFree: isFree,
      requiresTrainer: requiresTrainer,
    );

BookableUnit unit({String id = 'u1', String facilityId = 'f1', bool isActive = true}) =>
    BookableUnit(id: id, facilityId: facilityId, name: 'وحدة', isActive: isActive);

/// Same hours for every day of the week (1 = Monday ... 7 = Sunday).
List<OperatingHours> dailyHours(
  String ownerId, {
  int open = 480,
  int close = 720,
  Iterable<int> days = const [1, 2, 3, 4, 5, 6, 7],
}) =>
    [
      for (final d in days)
        OperatingHours(
          ownerId: ownerId,
          dayOfWeek: d,
          openMinutes: open,
          closeMinutes: close,
        ),
    ];

UnitSettings settings({
  BookingMode? mode,
  int? capacity,
  int? bookingWindowDays,
  int? minLeadMinutes,
  int? slotGranularityMinutes,
  int? maxRangeHours,
  int? sessionMinutes,
  int? holdMinutes,
  int? maxActive,
  int? cancellationCutoffHours,
  int? refundPercent,
  int? checkInOpensMinutes,
  int? reminderLeadMinutes,
}) {
  final d = UnitSettings.registryDefaults();
  return d.copyWith(
    bookingMode: mode ?? d.bookingMode,
    capacity: capacity ?? d.capacity,
    bookingWindowDays: bookingWindowDays ?? d.bookingWindowDays,
    minLeadMinutes: minLeadMinutes ?? d.minLeadMinutes,
    slotGranularityMinutes: slotGranularityMinutes ?? d.slotGranularityMinutes,
    maxRangeHours: maxRangeHours ?? d.maxRangeHours,
    sessionMinutes: sessionMinutes ?? d.sessionMinutes,
    holdMinutes: holdMinutes ?? d.holdMinutes,
    maxActiveBookingsPerUser: maxActive ?? d.maxActiveBookingsPerUser,
    cancellationCutoffHours:
        cancellationCutoffHours ?? d.cancellationCutoffHours,
    refundPercent: refundPercent ?? d.refundPercent,
    checkInOpensMinutes: checkInOpensMinutes ?? d.checkInOpensMinutes,
    reminderLeadMinutes: reminderLeadMinutes ?? d.reminderLeadMinutes,
  );
}

int _n = 0;

Booking booking({
  String? id,
  String userId = 'user1',
  String facilityId = 'f1',
  String unitId = 'u1',
  String? trainerId,
  required DateTime start,
  DateTime? end,
  int seats = 1,
  BookingStatus status = BookingStatus.confirmed,
  DateTime? holdExpiresAt,
  PriceTier tier = PriceTier.external,
  int price = 100,
}) {
  _n++;
  return Booking(
    id: id ?? 'b$_n',
    code: 'SP-$_n',
    userId: userId,
    facilityId: facilityId,
    unitId: unitId,
    trainerId: trainerId,
    start: start,
    end: end ?? start.add(const Duration(hours: 1)),
    seats: seats,
    tierAtBooking: tier,
    priceAtBooking: price,
    status: status,
    qrToken: 'qr$_n',
    holdExpiresAt: holdExpiresAt,
  );
}
