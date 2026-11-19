import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/widgets.dart' hide Notification;
import 'package:sprint/core/result/result.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/booking_repository.dart';
import 'package:sprint/features/booking/domain/unit_settings.dart';
import 'package:sprint/features/notifications/domain/notification.dart';
import 'package:sprint/features/notifications/domain/notification_kind.dart';
import 'package:sprint/features/notifications/domain/notification_repository.dart';
import 'package:sprint/features/notifications/domain/reminder_policy.dart';
import 'package:sprint/features/settings/domain/settings_repository.dart';

/// Runs [ReminderPolicy] for the signed-in person on build, every [period]
/// and when the app comes back to the foreground (BR-39). One deterministic
/// record per booking, so a second run writes nothing new.
class ReminderScheduler with WidgetsBindingObserver {
  ReminderScheduler({
    required this.userId,
    required this.bookings,
    required this.notifications,
    required this.settings,
    required this.clock,
    this.period = const Duration(seconds: 60),
    this.binding,
    this.policy = const ReminderPolicy(),
  });

  /// Null for a guest: [run] does nothing.
  final String? userId;
  final BookingRepository bookings;
  final NotificationRepository notifications;
  final SettingsRepository settings;
  final Clock clock;
  final Duration period;

  final WidgetsBinding? binding;
  final ReminderPolicy policy;

  Timer? _timer;
  bool _started = false;
  bool _running = false;

  WidgetsBinding get _observedBinding => binding ?? WidgetsBinding.instance;

  void start() {
    if (_started) return;
    _started = true;
    _observedBinding.addObserver(this);
    unawaited(run());
    _timer = Timer.periodic(period, (_) => unawaited(run()));
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    if (_started) {
      _observedBinding.removeObserver(this);
      _started = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(run());
  }

  Future<void> run() async {
    final uid = userId;
    if (uid == null || _running) return;
    _running = true;
    try {
      final mine = await bookings.listForUser(uid);
      final existing = {
        for (final n in await notifications.list(uid))
          if (n.kind == NotificationKind.bookingReminder) n.id,
      };
      final leads = <String, int>{};
      for (final b in mine) {
        if (b.status != BookingStatus.confirmed) continue;
        final key = '${b.unitId}|${b.facilityId}';
        if (leads.containsKey(key)) continue;
        final cfg = await UnitSettings.resolve(
          settings,
          unitId: b.unitId,
          facilityId: b.facilityId,
        );
        leads[key] = cfg.reminderLeadMinutes;
      }

      final now = clock.now();
      final due = policy.due(
        bookings: mine,
        existingReminderIds: existing,
        now: now,
        leadMinutesFor: (b) =>
            leads['${b.unitId}|${b.facilityId}'] ?? 0,
      );
      for (final b in due) {
        await _push(b, now);
      }
    } finally {
      _running = false;
    }
  }

  /// The `/demo` action: the same record, with no window check.
  Future<void> forceReminder(String bookingId) async {
    final r = await bookings.get(bookingId);
    if (r is! Ok<Booking>) return;
    await _push(r.value, clock.now());
  }

  Future<void> _push(Booking b, DateTime at) => notifications.push(
        Notification(
          id: ReminderPolicy.reminderId(b),
          userId: b.userId,
          type: NotificationKind.bookingReminder.wire,
          payload: {'bookingId': b.id, 'code': b.code},
          sentAt: at,
        ),
      );
}
