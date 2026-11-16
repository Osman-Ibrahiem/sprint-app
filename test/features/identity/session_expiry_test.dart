import 'package:fake_async/fake_async.dart';
import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/identity/domain/verification.dart';

/// The session keeps the verification and derives the tier from it; one
/// timer at `expiresAt` makes expiry show during a session (research R9,
/// FR-042).
void main() {
  test('tier turns external when the verification expires mid-session', () {
    fakeAsync((async) {
      final start = DateTime.utc(2026, 11, 16, 9);
      final c = ProviderContainer(
        overrides: [
          appClockProvider.overrideWithValue(
            Clock(() => start.add(async.elapsed)),
          ),
        ],
      );
      addTearDown(c.dispose);

      c.read(sessionProvider);
      async.flushMicrotasks();
      c.read(sessionProvider.notifier).actAs(SeedIds.bookerInternal);
      async.flushMicrotasks();

      final live = c.read(currentSessionProvider);
      expect(live.tier, PriceTier.internal);
      expect(live.verification?.status, VerificationStatus.approved);
      final expiresAt = live.verification!.expiresAt!;

      async.elapse(expiresAt.difference(start) + const Duration(minutes: 1));
      async.flushMicrotasks();

      final after = c.read(currentSessionProvider);
      expect(after.user?.id, SeedIds.bookerInternal, reason: 'still signed in');
      expect(after.tier, PriceTier.external);
    });
  });

  test('signOut returns to a guest and drops the roles', () {
    fakeAsync((async) {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(sessionProvider);
      async.flushMicrotasks();
      final n = c.read(sessionProvider.notifier);
      n.actAs(SeedIds.trainer1);
      async.flushMicrotasks();
      expect(c.read(currentSessionProvider).roles, isNotEmpty);
      n.signOut();
      async.flushMicrotasks();
      expect(c.read(currentSessionProvider).isGuest, isTrue);
      expect(c.read(currentSessionProvider).roles, isEmpty);
    });
  });
}
