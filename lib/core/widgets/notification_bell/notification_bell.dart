import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/adaptive/adaptive_pressable.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The bell of the compact header (NotificationBell README, FR-NTF-02): a 48
/// circle with the unread count as a badge, hidden at 0 and capped at 99+.
/// Pass `unread: null` while the count is loading (no badge).
class NotificationBell extends StatelessWidget {
  const NotificationBell({
    required this.unread,
    required this.onTap,
    super.key,
  });

  final int? unread;
  final VoidCallback onTap;

  static const badgeKey = ValueKey<String>('notification-bell-badge');
  static const cap = 99;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final count = unread ?? 0;
    final label = count > cap ? '$cap+' : '$count';
    final spoken = count > 0
        ? l10n.notificationBellLabelUnread(count)
        : l10n.notificationBellLabel;

    return AdaptivePressable(
      label: spoken,
      onTap: onTap,
      borderRadius: SprintRadius.fullBorder,
      restingColor: colors.surface,
      builder: (context, _) => SizedBox(
        width: SprintSize.controlHeight,
        height: SprintSize.controlHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SprintIcon(
              PhosphorIconsRegular.bell,
              size: SprintSize.iconLg,
              color: colors.ink,
            ),
            if (count > 0)
              PositionedDirectional(
                top: SprintExtras.bellBadgeTop,
                start: SprintExtras.bellBadgeOffset,
                child: ExcludeSemantics(
                  child: Container(
                    key: badgeKey,
                    constraints: const BoxConstraints(
                      minWidth: SprintExtras.bellBadgeMinWidth,
                    ),
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: SprintExtras.bellBadgePaddingX,
                    ),
                    decoration: BoxDecoration(
                      color: colors.danger,
                      borderRadius: SprintRadius.fullBorder,
                    ),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: context.text.micro.copyWith(
                        color: colors.onDanger,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
