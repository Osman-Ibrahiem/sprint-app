import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/features/notifications/data/reminder_scheduler.dart';

part 'reminder_providers.g.dart';

/// One keepAlive scheduler for the signed-in person: it runs on build, every
/// 60 seconds and on app resume, writing at most one reminder per booking
/// (BR-39). `/demo` reads it to force a reminder.
@Riverpod(keepAlive: true)
ReminderScheduler reminderScheduler(Ref ref) {
  final user = ref.watch(currentSessionProvider).user;
  final scheduler = ReminderScheduler(
    userId: user?.id,
    bookings: ref.watch(bookingRepositoryProvider),
    notifications: ref.watch(notificationRepositoryProvider),
    settings: ref.watch(settingsRepositoryProvider),
    clock: ref.watch(appClockProvider),
  );
  scheduler.start();
  ref.onDispose(scheduler.dispose);
  return scheduler;
}
