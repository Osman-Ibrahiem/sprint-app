import 'package:flutter/widgets.dart' hide Notification;
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/widgets/notification_card/notification_card.dart';
import 'package:sprint/features/notifications/domain/notification.dart';
import 'package:sprint/features/notifications/domain/notification_kind.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Icon, tint, wording and destination of one notification (FR-NTF-02,
/// BR-41, BR-26). Wording comes from the record's payload; an unknown kind is
/// a plain card with no destination.
class NotificationCardData {
  const NotificationCardData({
    required this.icon,
    required this.tone,
    required this.title,
    required this.body,
    this.destination,
  });

  final IconData icon;
  final NotificationTone tone;
  final String title;
  final String body;
  final String? destination;

  factory NotificationCardData.of(BuildContext context, Notification n) {
    final l = AppLocalizations.of(context);
    final p = n.payload;
    final code = p['code'] ?? '';
    final booking = p['bookingId'];
    String? bookingPath() =>
        booking == null ? null : AppPaths.bookingDetails(booking);
    return switch (n.kind) {
      NotificationKind.bookingConfirmed => NotificationCardData(
        icon: PhosphorIconsRegular.checkCircle,
        tone: NotificationTone.success,
        title: l.notifBookingConfirmedTitle,
        body: l.notifBookingConfirmedBody(code),
        destination: bookingPath(),
      ),
      NotificationKind.bookingReminder => NotificationCardData(
        icon: PhosphorIconsRegular.hourglass,
        tone: NotificationTone.warning,
        title: l.notifReminderTitle,
        body: l.notifReminderBody(code),
        destination: bookingPath(),
      ),
      NotificationKind.bookingCancelledByAdmin => NotificationCardData(
        icon: PhosphorIconsRegular.xCircle,
        tone: NotificationTone.danger,
        title: l.notifAdminCancelTitle,
        body: l.notifAdminCancelBody(code),
        destination: bookingPath(),
      ),
      NotificationKind.bookingCancelledByOwner => NotificationCardData(
        icon: PhosphorIconsRegular.xCircle,
        tone: NotificationTone.primary,
        title: l.notifOwnerCancelTitle,
        body: l.notifOwnerCancelBody(code),
        destination: bookingPath(),
      ),
      NotificationKind.paymentRefundedAuto => NotificationCardData(
        icon: PhosphorIconsRegular.receipt,
        tone: NotificationTone.success,
        title: l.notifRefundTitle,
        body: l.notifRefundBody(
          SprintFormat.of(context).price(int.tryParse(p['amount'] ?? '') ?? 0),
        ),
        destination: bookingPath(),
      ),
      NotificationKind.verificationPending => NotificationCardData(
        icon: PhosphorIconsRegular.clock,
        tone: NotificationTone.warning,
        title: l.notifVerificationPendingTitle,
        body: l.notifVerificationPendingBody,
        destination: AppPaths.profileVerification,
      ),
      NotificationKind.verificationApproved => NotificationCardData(
        icon: PhosphorIconsRegular.shieldCheck,
        tone: NotificationTone.success,
        title: l.notifVerificationApprovedTitle,
        body: l.notifVerificationApprovedBody,
        destination: AppPaths.profile,
      ),
      NotificationKind.verificationRejected => NotificationCardData(
        icon: PhosphorIconsRegular.xCircle,
        tone: NotificationTone.danger,
        title: l.notifVerificationRejectedTitle,
        body: l.notifVerificationRejectedBody(p['reason'] ?? ''),
        destination: AppPaths.profileVerification,
      ),
      NotificationKind.unknown => NotificationCardData(
        icon: PhosphorIconsRegular.bell,
        tone: NotificationTone.primary,
        title: l.notifUnknownTitle,
        body: '',
      ),
    };
  }
}
