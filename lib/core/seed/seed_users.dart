import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/features/catalogue/domain/trainer.dart';
import 'package:sprint/features/catalogue/domain/trainer_availability.dart';
import 'package:sprint/features/identity/domain/role_assignment.dart';
import 'package:sprint/features/identity/domain/user.dart';

// All people are fictional: example.test addresses and 0100000xxxx numbers.

/// When the seed people signed up (fixed, so snapshots stay comparable).
final _joined = DateTime.utc(2026, 9, 1);

final seedUsers = <User>[
  User(id: SeedIds.bookerInternal, name: 'منى عبد الله', phone: '01000000001', email: 'mona@example.test', createdAt: _joined, nationalId: '29901010100011'),
  User(id: SeedIds.bookerExternal, name: 'كريم السيد', phone: '01000000002', email: 'karim@example.test', createdAt: _joined, nationalId: '29902020200022'),
  User(id: SeedIds.trainer1, name: 'الكابتن هشام فؤاد', phone: '01000000003', email: 'hisham@example.test', createdAt: _joined),
  User(id: SeedIds.trainer2, name: 'الكابتن نهى سعيد', phone: '01000000004', email: 'noha@example.test', createdAt: _joined),
  User(id: SeedIds.trainer3, name: 'الكابتن طارق حسين', phone: '01000000005', email: 'tarek@example.test', createdAt: _joined),
  User(id: SeedIds.hallManager, name: 'سامي رمضان', phone: '01000000006', email: 'sami@example.test', createdAt: _joined),
  User(id: SeedIds.verifier, name: 'ريم مصطفى', phone: '01000000007', email: 'reem@example.test', createdAt: _joined),
  User(id: SeedIds.unitAdmin, name: 'د. عادل منصور', phone: '01000000008', email: 'adel@example.test', createdAt: _joined),
  User(id: SeedIds.superAdmin, name: 'د. هالة إبراهيم', phone: '01000000009', email: 'hala@example.test', createdAt: _joined),
  User(id: SeedIds.viewer, name: 'أ. ياسر جمال', phone: '01000000010', email: 'yasser@example.test', createdAt: _joined),
  User(id: SeedIds.userUnverified, name: 'دينا محمود', phone: '01000000011', email: 'dina@example.test', createdAt: _joined, nationalId: '30003030300033'),
  User(id: SeedIds.userExpired, name: 'عمر شوقي', phone: '01000000012', email: 'omar@example.test', createdAt: _joined, nationalId: '29804040400044'),
  User(id: SeedIds.userEngPending, name: 'ليلى حسن', phone: '01000000013', email: 'laila@example.test', createdAt: _joined, nationalId: '30101011100055'),
  User(id: SeedIds.userRejected, name: 'ياسمين طارق', phone: '01000000014', email: 'yasmin@example.test', createdAt: _joined, nationalId: '29705051400066'),
  User(id: SeedIds.userUnconfirmed, name: 'أحمد رضا', phone: '01000000015', email: 'ahmed@example.test', createdAt: _joined, nationalId: '29606061200077', status: UserStatus.unconfirmed),
  User(id: SeedIds.userSuspended, name: 'هبة فتحي', phone: '01000000016', email: 'heba@example.test', createdAt: _joined, nationalId: '29507071300088', status: UserStatus.suspended),
];

List<RoleAssignment> seedRoleAssignments() {
  RoleAssignment r(String user, Role role, RoleScopeType scope, [String? id]) =>
      RoleAssignment(userId: user, role: role, scopeType: scope, scopeId: id);
  const uni = RoleScopeType.university;
  return [
    // Everyone can book.
    for (final u in seedUsers) r(u.id, Role.booker, uni),
    r(SeedIds.trainer1, Role.trainer, RoleScopeType.facility, SeedIds.academyFacility),
    r(SeedIds.trainer2, Role.trainer, RoleScopeType.facility, SeedIds.academyFacility),
    r(SeedIds.trainer3, Role.trainer, RoleScopeType.facility, SeedIds.academyFacility),
    r(SeedIds.hallManager, Role.facilityManager, RoleScopeType.facility, SeedIds.hallFacility),
    r(SeedIds.verifier, Role.verifier, RoleScopeType.owningUnit, SeedIds.ouPe),
    r(SeedIds.unitAdmin, Role.unitAdmin, RoleScopeType.owningUnit, SeedIds.ouPe),
    r(SeedIds.superAdmin, Role.superAdmin, uni),
    r(SeedIds.viewer, Role.viewer, RoleScopeType.owningUnit, SeedIds.ouPe),
  ];
}

const seedTrainers = <Trainer>[
  Trainer(
    id: SeedIds.trainerRecord1,
    userId: SeedIds.trainer1,
    facilityIds: [SeedIds.academyFacility],
    bio: 'مدرب لياقة بدنية، خبرة ١٠ سنين.',
    trainerCapacity: 3,
  ),
  Trainer(
    id: SeedIds.trainerRecord2,
    userId: SeedIds.trainer2,
    facilityIds: [SeedIds.academyFacility],
    bio: 'مدربة جمباز وإطالة.',
    trainerCapacity: 4,
  ),
  Trainer(
    id: SeedIds.trainerRecord3,
    userId: SeedIds.trainer3,
    facilityIds: [SeedIds.academyFacility],
    bio: 'مدرب كرة سلة.',
    trainerCapacity: 2,
  ),
];

/// Days are 1 (Monday) to 7 (Sunday): Saturday is 6.
final seedTrainerAvailability = <TrainerAvailability>[
  for (final d in [6, 7, 1, 2, 3])
    TrainerAvailability(
      trainerId: SeedIds.trainerRecord1,
      unitId: SeedIds.room1,
      dayOfWeek: d,
      fromMinutes: 10 * 60,
      toMinutes: 14 * 60,
    ),
  for (final d in [6, 7, 1, 2, 3])
    TrainerAvailability(
      trainerId: SeedIds.trainerRecord2,
      unitId: SeedIds.room2,
      dayOfWeek: d,
      fromMinutes: 16 * 60,
      toMinutes: 20 * 60,
    ),
  for (final d in [4, 5])
    TrainerAvailability(
      trainerId: SeedIds.trainerRecord3,
      unitId: SeedIds.room1,
      dayOfWeek: d,
      fromMinutes: 12 * 60,
      toMinutes: 16 * 60,
    ),
];
