import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/notifications/presentation/providers/reminder_providers.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Two on-demand branches for the recording (feature 007): a reminder for the
/// next confirmed booking, and a facility cancel of it (BR-32, BR-39).
class Demo007Section extends ConsumerStatefulWidget {
  const Demo007Section({super.key});

  static const reminderKey = ValueKey<String>('demo-show-reminder');
  static const adminCancelKey = ValueKey<String>('demo-admin-cancel');

  @override
  ConsumerState<Demo007Section> createState() => _Demo007SectionState();
}

class _Demo007SectionState extends ConsumerState<Demo007Section> {
  String? _message;

  Future<Booking?> _next() async {
    final user = ref.read(currentSessionProvider).user;
    if (user == null) return null;
    final now = ref.read(appClockProvider).now();
    final mine = await ref.read(bookingRepositoryProvider).listForUser(user.id);
    final list = [
      for (final b in mine)
        if (b.status == BookingStatus.confirmed && b.end.isAfter(now)) b,
    ]..sort((a, b) => a.start.compareTo(b.start));
    return list.isEmpty ? null : list.first;
  }

  Future<void> _run(Future<void> Function(Booking b) action) async {
    final l10n = AppLocalizations.of(context);
    final b = await _next();
    if (b != null) await action(b);
    if (mounted) {
      setState(() => _message = b == null ? l10n.demo007NoBooking : l10n.demo007Done);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.demo007Section, style: context.text.title),
        const SizedBox(height: SprintSpacing.space3),
        Wrap(
          spacing: SprintSpacing.space2,
          runSpacing: SprintSpacing.space2,
          children: [
            SprintButton(
              key: Demo007Section.reminderKey,
              label: l10n.demo007ShowReminder,
              variant: SprintButtonVariant.secondary,
              onPressed: () => _run(
                (b) => ref.read(reminderSchedulerProvider).forceReminder(b.id),
              ),
            ),
            SprintButton(
              key: Demo007Section.adminCancelKey,
              label: l10n.demo007AdminCancel,
              variant: SprintButtonVariant.secondary,
              onPressed: () => _run((b) async {
                // The super admin stands in for the facility (BR-32).
                await ref.read(bookingRepositoryProvider).cancel(
                  b.id,
                  SeedIds.superAdmin,
                  reason: l10n.demo007AdminCancel,
                );
              }),
            ),
          ],
        ),
        if (_message != null) ...[
          const SizedBox(height: SprintSpacing.space2),
          Text(
            _message!,
            style: context.text.caption.copyWith(color: context.colors.inkMuted),
          ),
        ],
      ],
    );
  }
}
