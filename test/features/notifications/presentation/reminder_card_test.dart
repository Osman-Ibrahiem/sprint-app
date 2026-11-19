import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/data/in_memory_data_layer.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/features/booking/presentation/lead_time_text.dart';
import 'package:sprint/features/booking/presentation/providers/my_bookings_providers.dart';
import 'package:sprint/features/notifications/data/notification_permission_store.dart';
import 'package:sprint/features/notifications/domain/notification_permission.dart';
import 'package:sprint/features/notifications/presentation/notifications_screen.dart';
import 'package:sprint/features/notifications/presentation/providers/reminder_providers.dart';
import 'package:sprint/features/settings/domain/setting_definition.dart';
import 'package:sprint/features/settings/domain/setting_registry.dart';

import '../../../helpers/pump_app.dart';

/// T063 (BR-39, BR-40): the reminder card decides its cancel action when it
/// is shown, with a clock the test moves.
void main() {
  late DateTime now;
  late InMemoryDataLayer layer;

  Future<void> open(WidgetTester t) async {
    CairoTime.ensureInitialized();
    now = CairoTime.atWallClock(2026, 11, 14, 8);
    layer = InMemoryDataLayer.create(
      clock: Clock(() => now),
      paymentDelay: Duration.zero,
    );
    await pumpSprintApp(
      t,
      size: const Size(400, 1400),
      overrides: [
        dataLayerProvider.overrideWithValue(layer),
        appClockProvider.overrideWithValue(Clock(() => now)),
      ],
    );
    final c = containerOf(t);
    await c.read(sessionProvider.notifier).actAs(SeedIds.bookerInternal);
    await c
        .read(notificationPermissionStoreProvider)
        .write(NotificationPermission.granted);
    await t.runAsync(
      () => c.read(reminderSchedulerProvider).forceReminder('bk-09'),
    );
    routerOf(t).go(AppPaths.notifications);
    await t.pumpAndSettle();
  }

  final card = find.byKey(NotificationsScreen.cardKey('rem-bk-09'));
  final cancelBtn = find.descendant(
    of: card,
    matching: find.byKey(reminderCancelKey),
  );

  testWidgets('before the cutoff it offers cancel, which opens the dialog', (
    t,
  ) async {
    await open(t);
    await t.ensureVisible(cancelBtn);
    expect(cancelBtn, findsOneWidget);
    await t.tap(cancelBtn);
    await t.pumpAndSettle();
    expect(find.text(ar.cancelDialogTitle), findsOneWidget);
  });

  testWidgets('after the cutoff the action goes, a line says so, the card '
      'opens the booking', (t) async {
    await open(t);
    final b = layer.bookings.allBookings.firstWhere((x) => x.id == 'bk-09');
    now = b.start.subtract(const Duration(hours: 1));
    await t.pump(const Duration(seconds: 16));
    await t.pumpAndSettle();
    expect(cancelBtn, findsNothing);
    expect(
      find.descendant(
        of: card,
        matching: find.textContaining(ar.notifReminderCutoffClosed),
      ),
      findsOneWidget,
    );
    await t.tap(card);
    await t.pumpAndSettle();
    expect(currentPath(t), AppPaths.bookingDetails('bk-09'));
  });

  testWidgets('a cancelled booking keeps its reminder without the action', (
    t,
  ) async {
    await open(t);
    final r = await t.runAsync(
      () => layer.bookings.cancel('bk-09', SeedIds.bookerInternal),
    );
    expect(r!.isOk, isTrue);
    // The repository write reaches the screen through the clock tick; read
    // the fresh details so the real-async rebuild has finished (test only).
    containerOf(t).invalidate(bookingDetailsProvider('bk-09'));
    await t.runAsync(
      () => containerOf(t).read(bookingDetailsProvider('bk-09').future),
    );
    await t.pump(const Duration(seconds: 16));
    await t.pumpAndSettle();
    expect(card, findsOneWidget);
    expect(cancelBtn, findsNothing);
  });

  testWidgets('the lead in words comes from reminderLeadMinutes', (t) async {
    await open(t);
    final l10n = ar;
    final base = leadTimeText(l10n, UnitSettings0.leadDefault);
    expect(
      find.textContaining(l10n.notifReminderBodyLead('SP-1009', base)),
      findsOneWidget,
    );
    await t.runAsync(
      () => layer.settings.set(
        SettingKeys.reminderLeadMinutes,
        180,
        const SettingScope.university(),
        actorId: SeedIds.superAdmin,
      ),
    );
    await t.pump(const Duration(seconds: 16));
    await t.pumpAndSettle();
    expect(
      find.textContaining(
        l10n.notifReminderBodyLead('SP-1009', leadTimeText(l10n, 180)),
      ),
      findsOneWidget,
    );
  });

  testWidgets('running the checker many times leaves one record', (t) async {
    await open(t);
    final c = containerOf(t);
    await t.runAsync(() async {
      for (var i = 0; i < 3; i++) {
        await c.read(reminderSchedulerProvider).forceReminder('bk-09');
        await c.read(reminderSchedulerProvider).run();
      }
    });
    final list = await t.runAsync(
      () => layer.notifications.list(SeedIds.bookerInternal),
    );
    expect(list!.where((n) => n.id == 'rem-bk-09'), hasLength(1));
  });
}

/// The registry default of `reminderLeadMinutes`, read once.
abstract final class UnitSettings0 {
  static final int leadDefault = defaultOf(SettingKeys.reminderLeadMinutes);
}
