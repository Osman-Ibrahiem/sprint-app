import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/identity/domain/user.dart';
import 'package:sprint/features/identity/domain/verification.dart';
import 'package:sprint/features/verification/domain/tier.dart';

import '../../helpers/domain_builders.dart';

/// FR-040, BR-21, BR-24, BR-25: the tier is derived, never stored.
void main() {
  final now = DateTime.utc(2026, 11, 14);
  final later = now.add(const Duration(days: 30));

  test('no verification is external', () {
    expect(tierFor(user(), null, now), PriceTier.external);
  });

  test('guest is external', () {
    expect(
      tierFor(null, verification(expiresAt: later), now),
      PriceTier.external,
    );
  });

  test('pending is external', () {
    final v = verification(status: VerificationStatus.pending);
    expect(tierFor(user(), v, now), PriceTier.external);
  });

  test('rejected is external', () {
    final v = verification(
      status: VerificationStatus.rejected,
      reason: 'صورة غير واضحة تماما',
    );
    expect(tierFor(user(), v, now), PriceTier.external);
  });

  test('approved and unexpired is internal', () {
    expect(
      tierFor(user(), verification(expiresAt: later), now),
      PriceTier.internal,
    );
  });

  test('approved and expired is external, derived not stored', () {
    final v = verification(expiresAt: now.subtract(const Duration(days: 1)));
    expect(v.status, VerificationStatus.approved);
    expect(v.isExpiredAt(now), isTrue);
    expect(tierFor(user(), v, now), PriceTier.external);
  });

  test('expiry is exclusive at the instant', () {
    final v = verification(expiresAt: now);
    expect(v.isExpiredAt(now), isTrue);
    expect(tierFor(user(), v, now), PriceTier.external);
  });

  test('a suspended user is external even when approved', () {
    final u = user(status: UserStatus.suspended);
    expect(tierFor(u, verification(expiresAt: later), now), PriceTier.external);
  });

  test('an unconfirmed user is external', () {
    final u = user(status: UserStatus.unconfirmed);
    expect(tierFor(u, verification(expiresAt: later), now), PriceTier.external);
  });
}
