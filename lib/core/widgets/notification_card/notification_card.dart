import 'package:flutter/material.dart';
import 'package:sprint/core/adaptive/adaptive_pressable.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_colors.g.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';

/// The tint of the kind tile (NotificationCard README).
enum NotificationTone { success, warning, danger, primary }

/// One notification: a kind icon tile, title, body line, time and an unread
/// dot. Plain values only; the caller decides wording, destination and the
/// optional [actions] (FR-NTF-02, BR-39, BR-41).
class NotificationCard extends StatelessWidget {
  const NotificationCard({
    required this.icon,
    required this.tone,
    required this.title,
    required this.body,
    required this.time,
    required this.unread,
    this.onTap,
    this.actions,
    this.semanticLabel,
    super.key,
  });

  final IconData icon;
  final NotificationTone tone;
  final String title;
  final String body;
  final String time;
  final bool unread;
  final VoidCallback? onTap;

  /// Buttons under the text (a reminder's "إلغاء الحجز").
  final Widget? actions;
  final String? semanticLabel;

  static const dotKey = ValueKey<String>('notification-card-dot');

  (Color, Color) _tint(SprintColors c) => switch (tone) {
    NotificationTone.success => (c.successSoft, c.success),
    NotificationTone.warning => (c.warningSoft, c.warning),
    NotificationTone.danger => (c.dangerSoft, c.danger),
    NotificationTone.primary => (c.primarySoft, c.onPrimarySoft),
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final (tile, glyph) = _tint(colors);

    final content = Padding(
      padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: SprintExtras.notificationIconTile,
            height: SprintExtras.notificationIconTile,
            decoration: BoxDecoration(color: tile, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: SprintIcon(icon, size: SprintSize.iconMd, color: glyph),
          ),
          const SizedBox(width: SprintSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (unread) ...[
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          top: SprintSpacing.space2,
                        ),
                        child: Container(
                          key: dotKey,
                          width: SprintExtras.unreadDot,
                          height: SprintExtras.unreadDot,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: SprintSpacing.space2),
                    ],
                    Expanded(
                      child: Text(
                        title,
                        style: text.headline.copyWith(
                          color: colors.ink,
                          fontWeight: unread
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: SprintSpacing.space2),
                    Text(
                      time,
                      style: text.caption.copyWith(color: colors.inkMuted),
                    ),
                  ],
                ),
                const SizedBox(height: SprintSpacing.space1),
                Text(body, style: text.body.copyWith(color: colors.inkMuted)),
                if (actions != null) ...[
                  const SizedBox(height: SprintSpacing.space3),
                  actions!,
                ],
              ],
            ),
          ),
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: SprintRadius.lgBorder,
      ),
      child: onTap == null
          ? content
          : AdaptivePressable(
              label: semanticLabel ?? '$title. $body. $time',
              onTap: onTap,
              borderRadius: SprintRadius.lgBorder,
              expand: true,
              builder: (context, _) => content,
            ),
    );
  }
}
