import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/features/catalogue/domain/bookable_unit.dart';
import 'package:sprint/features/catalogue/domain/closure.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/domain/operating_hours.dart';
import 'package:sprint/features/catalogue/domain/owning_unit.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/settings/domain/booking_mode.dart';
import 'package:sprint/features/settings/domain/setting_definition.dart';
import 'package:sprint/features/settings/domain/setting_registry.dart';

// Placeholder data until Dr. Sara's real data arrives. Names are Arabic, prices
// are whole EGP, hours are 8:00 am - 10:00 pm. All fictional.

const seedOwningUnits = <OwningUnit>[
  OwningUnit(id: SeedIds.ouPe, name: 'كلية التربية الرياضية', type: OwningUnitType.faculty),
  OwningUnit(id: SeedIds.ouEng, name: 'كلية الهندسة', type: OwningUnitType.faculty),
  OwningUnit(id: SeedIds.ouCentral, name: 'إدارة الأنشطة الرياضية', type: OwningUnitType.central),
];

const seedFacilities = <Facility>[
  Facility(
    id: SeedIds.poolFacility,
    owningUnitId: SeedIds.ouPe,
    name: 'حمام السباحة الأولمبي',
    type: FacilityType.swimming,
    description: 'حمام سباحة أولمبي بست حارات، الحجز بالمكان في الحارة.',
    location: 'كلية التربية الرياضية، الدور الأرضي',
    isFree: false,
    requiresTrainer: false,
  ),
  Facility(
    id: SeedIds.futsalFacility,
    owningUnitId: SeedIds.ouCentral,
    name: 'ملعب كرة القدم الخماسي',
    type: FacilityType.football,
    description: 'ملعب خماسي بعشب صناعي، الحجز للملعب كله.',
    location: 'الاستاد الجامعي',
    isFree: false,
    requiresTrainer: false,
  ),
  Facility(
    id: SeedIds.gymFacility,
    owningUnitId: SeedIds.ouPe,
    name: 'صالة اللياقة البدنية',
    type: FacilityType.gym,
    description: 'صالة أجهزة وأوزان، الحجز بالمكان.',
    location: 'كلية التربية الرياضية، الدور الأول',
    isFree: false,
    requiresTrainer: false,
  ),
  Facility(
    id: SeedIds.tennisFacility,
    owningUnitId: SeedIds.ouEng,
    name: 'ملعب التنس',
    type: FacilityType.tennis,
    description: 'ملعبان تنس، الحجز للملعب كله.',
    location: 'كلية الهندسة، الحرم الخلفي',
    isFree: false,
    requiresTrainer: false,
  ),
  Facility(
    id: SeedIds.hallFacility,
    owningUnitId: SeedIds.ouCentral,
    name: 'الصالة المغطاة متعددة الأغراض',
    type: FacilityType.hall,
    description: 'صالة مجانية، الحجز بنطاق ساعات متتالية.',
    location: 'الاستاد الجامعي',
    isFree: true,
    requiresTrainer: false,
  ),
  Facility(
    id: SeedIds.academyFacility,
    owningUnitId: SeedIds.ouPe,
    name: 'أكاديمية التدريب',
    type: FacilityType.training,
    description: 'حصص مع مدرب، تختار المدرب الأول وبعدين الميعاد.',
    location: 'كلية التربية الرياضية، الدور الثاني',
    isFree: false,
    requiresTrainer: true,
  ),
];

const seedUnits = <BookableUnit>[
  BookableUnit(id: SeedIds.pool1, facilityId: SeedIds.poolFacility, name: 'حارة 1'),
  BookableUnit(id: SeedIds.pool2, facilityId: SeedIds.poolFacility, name: 'حارة 2'),
  BookableUnit(id: SeedIds.pool3, facilityId: SeedIds.poolFacility, name: 'حارة 3'),
  BookableUnit(id: SeedIds.pool4, facilityId: SeedIds.poolFacility, name: 'حارة 4'),
  BookableUnit(id: SeedIds.pool5, facilityId: SeedIds.poolFacility, name: 'حارة 5'),
  BookableUnit(id: SeedIds.pool6, facilityId: SeedIds.poolFacility, name: 'حارة 6'),
  BookableUnit(id: SeedIds.futsal1, facilityId: SeedIds.futsalFacility, name: 'ملعب أ'),
  BookableUnit(id: SeedIds.futsal2, facilityId: SeedIds.futsalFacility, name: 'ملعب ب'),
  BookableUnit(id: SeedIds.gym1, facilityId: SeedIds.gymFacility, name: 'أرضية الصالة'),
  BookableUnit(id: SeedIds.tennis1, facilityId: SeedIds.tennisFacility, name: 'ملعب 1'),
  BookableUnit(id: SeedIds.tennis2, facilityId: SeedIds.tennisFacility, name: 'ملعب 2'),
  BookableUnit(id: SeedIds.hall1, facilityId: SeedIds.hallFacility, name: 'قاعة 1'),
  BookableUnit(id: SeedIds.hall2, facilityId: SeedIds.hallFacility, name: 'قاعة 2'),
  BookableUnit(id: SeedIds.room1, facilityId: SeedIds.academyFacility, name: 'غرفة تدريب 1'),
  BookableUnit(id: SeedIds.room2, facilityId: SeedIds.academyFacility, name: 'غرفة تدريب 2'),
];

/// Facility-level weekly hours, 8:00 am - 10:00 pm. The hall is closed on
/// Fridays (`DateTime.friday`).
List<OperatingHours> seedHours() => [
      for (final f in seedFacilities)
        for (var day = 1; day <= 7; day++)
          if (!(f.id == SeedIds.hallFacility && day == DateTime.friday))
            OperatingHours(
              ownerId: f.id,
              dayOfWeek: day,
              openMinutes: 8 * 60,
              closeMinutes: 22 * 60,
            ),
    ];

/// One future closure: pitch A is closed for maintenance three days from now.
List<Closure> seedClosures(DateTime now) {
  final today = CairoTime.toCairo(now);
  return [
    Closure(
      id: 'cl-1',
      scope: ClosureScope.unit,
      scopeId: SeedIds.futsal1,
      from: CairoTime.atWallClock(today.year, today.month, today.day + 3),
      to: CairoTime.atWallClock(today.year, today.month, today.day + 4),
      reason: 'صيانة العشب الصناعي',
    ),
  ];
}

/// Prices in whole EGP: internal is roughly 40-50% of external. Free
/// facilities have none.
final seedPrices = <Price>[
  for (final u in [
    SeedIds.pool1, SeedIds.pool2, SeedIds.pool3,
    SeedIds.pool4, SeedIds.pool5, SeedIds.pool6,
  ]) ...[
    Price(unitId: u, tier: PriceTier.external, amount: 40),
    Price(unitId: u, tier: PriceTier.internal, amount: 20),
  ],
  for (final u in [SeedIds.futsal1, SeedIds.futsal2]) ...[
    Price(unitId: u, tier: PriceTier.external, amount: 300),
    Price(unitId: u, tier: PriceTier.internal, amount: 140),
  ],
  const Price(unitId: SeedIds.gym1, tier: PriceTier.external, amount: 60),
  const Price(unitId: SeedIds.gym1, tier: PriceTier.internal, amount: 25),
  for (final u in [SeedIds.tennis1, SeedIds.tennis2]) ...[
    Price(unitId: u, tier: PriceTier.external, amount: 120),
    Price(unitId: u, tier: PriceTier.internal, amount: 55),
  ],
  for (final u in [SeedIds.room1, SeedIds.room2]) ...[
    Price(unitId: u, tier: PriceTier.external, amount: 100),
    Price(unitId: u, tier: PriceTier.internal, amount: 45),
  ],
];

/// Unit-scope mode and capacity, plus two overrides that show inheritance:
/// a 4-hour cancellation cutoff for the pool facility, and a 50% refund on the
/// gym floor.
List<SettingEntry> seedSettings() => [
      for (final u in [
        SeedIds.pool1, SeedIds.pool3, SeedIds.pool4, SeedIds.pool5, SeedIds.pool6,
      ]) ...[
        SettingEntry(SettingKeys.bookingMode.name, BookingMode.shared, SettingScope.unit(u)),
        SettingEntry(SettingKeys.capacity.name, 8, SettingScope.unit(u)),
      ],
      // Lane 2 is small, so one slot in the seed is full.
      SettingEntry(SettingKeys.bookingMode.name, BookingMode.shared, const SettingScope.unit(SeedIds.pool2)),
      SettingEntry(SettingKeys.capacity.name, 3, const SettingScope.unit(SeedIds.pool2)),
      for (final u in [SeedIds.futsal1, SeedIds.futsal2]) ...[
        SettingEntry(SettingKeys.bookingMode.name, BookingMode.exclusive, SettingScope.unit(u)),
        SettingEntry(SettingKeys.maxParticipants.name, 22, SettingScope.unit(u)),
      ],
      SettingEntry(SettingKeys.bookingMode.name, BookingMode.shared, const SettingScope.unit(SeedIds.gym1)),
      SettingEntry(SettingKeys.capacity.name, 30, const SettingScope.unit(SeedIds.gym1)),
      for (final u in [SeedIds.tennis1, SeedIds.tennis2]) ...[
        SettingEntry(SettingKeys.bookingMode.name, BookingMode.exclusive, SettingScope.unit(u)),
        SettingEntry(SettingKeys.maxParticipants.name, 4, SettingScope.unit(u)),
      ],
      for (final u in [SeedIds.hall1, SeedIds.hall2])
        SettingEntry(SettingKeys.bookingMode.name, BookingMode.exclusive, SettingScope.unit(u)),
      for (final u in [SeedIds.room1, SeedIds.room2]) ...[
        SettingEntry(SettingKeys.bookingMode.name, BookingMode.shared, SettingScope.unit(u)),
        SettingEntry(SettingKeys.capacity.name, 6, SettingScope.unit(u)),
      ],
      SettingEntry(SettingKeys.cancellationCutoffHours.name, 4, const SettingScope.facility(SeedIds.poolFacility)),
      SettingEntry(SettingKeys.refundPercent.name, 50, const SettingScope.unit(SeedIds.gym1)),
    ];
