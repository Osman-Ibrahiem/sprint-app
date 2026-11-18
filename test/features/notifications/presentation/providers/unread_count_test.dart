import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/data/in_memory_data_layer.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/features/notifications/domain/notification.dart';
import 'package:sprint/features/notifications/presentation/providers/notification_providers.dart';

/// T029: unread count and the list (BR-39, SC-005).
void main() {
  CairoTime.ensureInitialized();
  final now = CairoTime.atWallClock(2026, 11, 14, 8);
  late InMemoryDataLayer layer;
  late ProviderContainer c;

  setUp(() async {
    layer = InMemoryDataLayer.create(
      clock: Clock(() => now),
      paymentDelay: Duration.zero,
    );
    c = ProviderContainer(
      overrides: [
        dataLayerProvider.overrideWithValue(layer),
        appClockProvider.overrideWithValue(Clock(() => now)),
      ],
    );
    addTearDown(c.dispose);
    await c.read(sessionProvider.notifier).actAs(SeedIds.bookerInternal);
    c.listen(notificationsListProvider, (_, _) {});
    c.listen(unreadCountProvider, (_, _) {});
    await c.read(notificationsListProvider.future);
  });

  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 50));

  test('counts unread and skips records read on arrival', () async {
    final list = await c.read(notificationsListProvider.future);
    expect(
      c.read(unreadCountProvider),
      list.where((n) => n.readAt == null).length,
    );
    expect(list.any((n) => n.readAt != null), isTrue);
  });

  test('is null while loading and for a guest is zero', () async {
    final fresh = ProviderContainer(
      overrides: [dataLayerProvider.overrideWithValue(layer)],
    );
    addTearDown(fresh.dispose);
    expect(fresh.read(unreadCountProvider), isNull);
  });

  test('markAllRead clears it; a push raises it', () async {
    await layer.notifications.markAllRead(SeedIds.bookerInternal, now);
    await settle();
    expect(c.read(unreadCountProvider), 0);
    await layer.notifications.push(
      Notification(
        id: 'new-1',
        userId: SeedIds.bookerInternal,
        type: 'booking.confirmed',
        sentAt: now,
      ),
    );
    await settle();
    expect(c.read(unreadCountProvider), 1);
  });

  test('the badge hides at zero and caps at 99+', () {
    expect(badgeLabel(0), isNull);
    expect(badgeLabel(null), isNull);
    expect(badgeLabel(7), '7');
    expect(badgeLabel(99), '99');
    expect(badgeLabel(100), '99+');
  });
}
