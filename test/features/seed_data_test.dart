import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/seed/seed_data.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/domain/owning_unit.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/auth/domain/password_hasher.dart';
import 'package:sprint/features/auth/domain/validators.dart';
import 'package:sprint/features/identity/domain/role_assignment.dart';
import 'package:sprint/features/identity/domain/user.dart';
import 'package:sprint/features/identity/domain/verification.dart';
import 'package:sprint/features/verification/domain/national_id.dart';

/// FR-021, FR-022: realistic and complete seed data.
void main() {
  CairoTime.ensureInitialized();
  final seed = SeedData.build(CairoTime.atWallClock(2026, 11, 14, 8));

  test('facilities cover paid, free and with-trainer', () {
    expect(seed.facilities.any((f) => !f.isFree && !f.requiresTrainer), isTrue);
    expect(seed.facilities.any((f) => f.isFree), isTrue);
    expect(seed.facilities.any((f) => f.requiresTrainer), isTrue);
    expect(seed.facilities.length, greaterThanOrEqualTo(6));
  });

  test('at least a faculty and a central unit own facilities', () {
    expect(
      seed.owningUnits.any((o) => o.type == OwningUnitType.faculty),
      isTrue,
    );
    expect(
      seed.owningUnits.any((o) => o.type == OwningUnitType.central),
      isTrue,
    );
    for (final f in seed.facilities) {
      expect(seed.owningUnits.any((o) => o.id == f.owningUnitId), isTrue);
    }
  });

  test('every facility has at least one bookable unit; about 15 in all', () {
    for (final f in seed.facilities) {
      expect(seed.units.any((u) => u.facilityId == f.id), isTrue, reason: f.id);
    }
    expect(seed.units.length, inInclusiveRange(13, 17));
  });

  test('Arabic names and whole-pound prices in both tiers', () {
    final arabic = RegExp('[ء-ي]');
    for (final f in seed.facilities) {
      expect(arabic.hasMatch(f.name), isTrue, reason: f.id);
    }
    for (final f in seed.facilities.where((f) => !f.isFree)) {
      for (final u in seed.units.where((u) => u.facilityId == f.id)) {
        final p = seed.prices.where((p) => p.unitId == u.id).toList();
        final ext = p.firstWhere((x) => x.tier == PriceTier.external).amount;
        final int_ = p.firstWhere((x) => x.tier == PriceTier.internal).amount;
        expect(int_ / ext, inInclusiveRange(0.35, 0.55), reason: u.id);
      }
    }
    expect(
      seed.facilities
          .where((f) => f.isFree)
          .every(
            (f) => seed.units
                .where((u) => u.facilityId == f.id)
                .every((u) => !seed.prices.any((p) => p.unitId == u.id)),
          ),
      isTrue,
    );
  });

  test('users cover every role and both tiers', () {
    final roles = seed.roleAssignments.map((a) => a.role).toSet();
    for (final r in Role.values.where((r) => r != Role.guest)) {
      expect(roles, contains(r), reason: '$r');
    }
    expect(seed.users.length, greaterThanOrEqualTo(10));
    expect(seed.verifications.any((v) => v.status.name == 'approved'), isTrue);
  });

  test('bookings cover every status, past and future', () {
    final statuses = seed.bookings.map((b) => b.status).toSet();
    expect(statuses, containsAll(BookingStatus.values));
    final now = CairoTime.atWallClock(2026, 11, 14, 8);
    expect(seed.bookings.any((b) => b.end.isBefore(now)), isTrue);
    expect(seed.bookings.any((b) => b.start.isAfter(now)), isTrue);
    expect(seed.bookings.length, greaterThanOrEqualTo(18));
  });

  test('one slot is full in the seed (capacity case)', () {
    final byUnitStart = <String, int>{};
    for (final b in seed.bookings.where(
      (b) => b.status == BookingStatus.confirmed,
    )) {
      final k = '${b.unitId}@${b.start.toIso8601String()}';
      byUnitStart[k] = (byUnitStart[k] ?? 0) + b.seats;
    }
    expect(byUnitStart.values.any((n) => n >= 3), isTrue);
  });

  test('a hall is closed on one weekday and one closure is in the future', () {
    final hall = seed.facilities.firstWhere((f) => f.isFree);
    final days = seed.hours
        .where((h) => h.ownerId == hall.id)
        .map((h) => h.dayOfWeek)
        .toSet();
    expect(days.length, 6);
    expect(seed.closures, isNotEmpty);
    expect(
      seed.closures.first.from.isAfter(CairoTime.atWallClock(2026, 11, 14, 8)),
      isTrue,
    );
  });

  test('other sets are present', () {
    expect(seed.trainers.length, 3);
    expect(seed.trainerAvailability, isNotEmpty);
    expect(seed.notifications.length, greaterThanOrEqualTo(5));
    expect(seed.assets.length, greaterThanOrEqualTo(4));
    expect(seed.damageReports, isNotEmpty);
    expect(seed.offers.length, greaterThanOrEqualTo(2));
    expect(seed.auditLog, isNotEmpty);
  });

  test('all names, phones and emails are fictional', () {
    for (final u in seed.users) {
      expect(u.email, endsWith('@example.test'));
      expect(u.phone, startsWith('0100000'));
    }
    expect(seed.facilities.first.type, isA<FacilityType>());
  });

  group('auth and verification seed (FR-048)', () {
    test('emails, phones and national IDs are unique and IDs valid', () {
      final emails = seed.users.map((u) => u.email).toSet();
      final phones = seed.users.map((u) => u.phone).toSet();
      final ids = seed.users.map((u) => u.nationalId).whereType<String>();
      expect(emails.length, seed.users.length);
      expect(phones.length, seed.users.length);
      expect(ids.toSet().length, ids.length);
      for (final id in ids) {
        expect(validateNationalId(id).isValid, isTrue, reason: id);
      }
      for (final v in seed.verifications) {
        expect(validateNationalId(v.nationalId).isValid, isTrue, reason: v.id);
      }
    });

    test('every person has the demo password, hashed', () {
      expect(
        seed.credentials.map((c) => c.userId).toSet(),
        seed.users.map((u) => u.id).toSet(),
      );
      for (final c in seed.credentials) {
        expect(c.hash, isNot(SeedIds.demoPassword));
        expect(
          PasswordHasher.verify(
            SeedIds.demoPassword,
            salt: c.salt,
            hash: c.hash,
          ),
          isTrue,
        );
      }
    });

    test('statuses and requests cover the demo cases', () {
      User u(String id) => seed.users.firstWhere((x) => x.id == id);
      Verification v(String id) =>
          seed.verifications.firstWhere((x) => x.id == id);
      expect(u(SeedIds.userUnconfirmed).status, UserStatus.unconfirmed);
      expect(u(SeedIds.userSuspended).status, UserStatus.suspended);
      expect(v(SeedIds.verEngPending).status, VerificationStatus.pending);
      expect(v(SeedIds.verEngPending).owningUnitId, SeedIds.ouEng);
      expect(v(SeedIds.verUnverified).owningUnitId, SeedIds.ouPe);
      final rejected = v(SeedIds.verRejected);
      expect(rejected.status, VerificationStatus.rejected);
      expect((rejected.reason ?? '').length, greaterThanOrEqualTo(10));
      for (final x in seed.verifications) {
        expect(x.photoId, isNotNull, reason: x.id);
        expect(x.code, isNotEmpty);
      }
    });

    test('seed batch holds كريم\'s row and not دينا\'s', () {
      final batch = seed.sheetBatches.single;
      expect(batch.uploadedBy, SeedIds.verifier);
      expect(batch.owningUnitId, SeedIds.ouPe);
      final ids = seed.sheetRows.map((r) => r.nationalId);
      expect(ids, contains('29902020200022'));
      expect(ids, isNot(contains('30003030300033')));
      expect(seed.emailCodes, isEmpty);
    });

    test(
      'sample CSV: matches دينا, repeats كريم, one bad date, one stranger',
      () {
        final lines = File('assets/demo/verification_sheet_sample.csv')
            .readAsLinesSync()
            .skip(1)
            .where((l) => l.trim().isNotEmpty)
            .map((l) => l.split(','))
            .toList();
        expect(lines.length, 4);
        final results = {for (final c in lines) c[0]: validateNationalId(c[0])};
        expect(results['30003030300033']!.isValid, isTrue);
        expect(results['29902020200022']!.isValid, isTrue);
        expect(results['29311111500099']!.isValid, isTrue);
        expect(
          results['29902301200100'],
          const Invalid<String, NationalIdProblem>(
            NationalIdProblem.invalidBirthDate,
          ),
        );
        final dina = lines.firstWhere((c) => c[0] == '30003030300033');
        expect(dina[1], '20220002');
      },
    );
  });
}
