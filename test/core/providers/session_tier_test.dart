import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/identity/domain/verification.dart';
import 'package:sprint/features/verification/data/in_memory_verification_repository.dart';

/// FR-042: the tier in the session follows verification changes without
/// signing in again, including expiry through the scheduled timer (R9).
void main() {
  test('approval while signed in updates Session.tier', () {
    fakeAsync((async) {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(sessionProvider);
      async.flushMicrotasks();
      c.read(sessionProvider.notifier).actAs(SeedIds.userUnverified);
      async.flushMicrotasks();
      expect(c.read(currentSessionProvider).tier, PriceTier.external);
      expect(
        c.read(currentSessionProvider).verification?.status,
        VerificationStatus.pending,
      );

      c
          .read(verificationRepositoryProvider)
          .approve(SeedIds.verifier, SeedIds.verUnverified);
      async.flushMicrotasks();

      final s = c.read(currentSessionProvider);
      expect(s.user?.id, SeedIds.userUnverified, reason: 'no sign out');
      expect(s.verification?.status, VerificationStatus.approved);
      expect(s.tier, PriceTier.internal);
    });
  });

  test('passing expiresAt during a session turns the tier external', () {
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
      expect(c.read(currentSessionProvider).tier, PriceTier.internal);

      // Shorten the expiry to one hour ahead; the timer follows the change.
      final repo = c.read(
        verificationRepositoryProvider,
      ) as InMemoryVerificationRepository;
      repo.put(
        c
            .read(currentSessionProvider)
            .verification!
            .copyWith(expiresAt: start.add(const Duration(hours: 1))),
      );
      async.flushMicrotasks();
      async.elapse(const Duration(minutes: 59));
      async.flushMicrotasks();
      expect(c.read(currentSessionProvider).tier, PriceTier.internal);

      async.elapse(const Duration(minutes: 2));
      async.flushMicrotasks();
      final s = c.read(currentSessionProvider);
      expect(s.user?.id, SeedIds.bookerInternal);
      expect(s.tier, PriceTier.external);
    });
  });

  test('a far expiry is waited for in capped steps (web setTimeout wraps '
      'delays over about 24.8 days) and still turns the tier external', () {
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

      final repo = c.read(
        verificationRepositoryProvider,
      ) as InMemoryVerificationRepository;
      repo.put(
        c
            .read(currentSessionProvider)
            .verification!
            .copyWith(expiresAt: start.add(const Duration(days: 40))),
      );
      async.flushMicrotasks();
      // No timer may be longer than the cap (setTimeout takes 2^31 - 1 ms).
      for (final t in async.pendingTimers) {
        expect(
          t.duration,
          lessThanOrEqualTo(SessionNotifier.maxExpiryTimerWait),
        );
      }
      expect(
        SessionNotifier.maxExpiryTimerWait.inMilliseconds,
        lessThan(0x7fffffff),
      );

      async.elapse(const Duration(days: 39));
      async.flushMicrotasks();
      expect(c.read(currentSessionProvider).tier, PriceTier.internal);
      async.elapse(const Duration(days: 1, minutes: 1));
      async.flushMicrotasks();
      expect(c.read(currentSessionProvider).tier, PriceTier.external);
    });
  });
}
