/// Ids of the placeholder seed data, so tests and the demo can name them.
///
/// Units `futsal2`, `tennis2`, `hall2`, `room2` and `pool6` carry no seeded
/// bookings, so tests can book them freely.
abstract final class SeedIds {
  // Owning units
  static const ouPe = 'ou-pe';
  static const ouEng = 'ou-eng';
  static const ouCentral = 'ou-central';

  // Facilities
  static const poolFacility = 'f-pool';
  static const futsalFacility = 'f-futsal';
  static const gymFacility = 'f-gym';
  static const tennisFacility = 'f-tennis';
  static const hallFacility = 'f-hall';
  static const academyFacility = 'f-academy';

  // Units
  static const pool1 = 'u-pool-1';
  static const pool2 = 'u-pool-2';
  static const pool3 = 'u-pool-3';
  static const pool4 = 'u-pool-4';
  static const pool5 = 'u-pool-5';
  static const pool6 = 'u-pool-6';
  static const futsal1 = 'u-futsal-1';
  static const futsal2 = 'u-futsal-2';
  static const gym1 = 'u-gym-1';
  static const tennis1 = 'u-tennis-1';
  static const tennis2 = 'u-tennis-2';
  static const hall1 = 'u-hall-1';
  static const hall2 = 'u-hall-2';
  static const room1 = 'u-room-1';
  static const room2 = 'u-room-2';

  // Users
  static const bookerInternal = 'usr-booker-int';
  static const bookerExternal = 'usr-booker-ext';
  static const trainer1 = 'usr-trainer-1';
  static const trainer2 = 'usr-trainer-2';
  static const trainer3 = 'usr-trainer-3';
  static const hallManager = 'usr-hall-manager';
  static const verifier = 'usr-verifier';
  static const unitAdmin = 'usr-unit-admin';
  static const superAdmin = 'usr-super';
  static const viewer = 'usr-viewer';
  static const userUnverified = 'usr-unverified';
  static const userExpired = 'usr-expired';

  // Trainers
  static const trainerRecord1 = 'tr-1';
  static const trainerRecord2 = 'tr-2';
  static const trainerRecord3 = 'tr-3';
}
