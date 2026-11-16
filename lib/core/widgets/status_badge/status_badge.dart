import 'package:flutter/material.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/reduced_motion.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_motion.g.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/status_badge/sprint_status.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';

/// A small icon-and-word status pill, never pressable (StatusBadge README,
/// FR-032 – FR-034).
class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.status, super.key});

  final SprintStatus status;

  static const wordKey = ValueKey<String>('status-badge-word');
  static const containerKey = ValueKey<String>('status-badge');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final (foreground, background) = status.colors(colors);
    final word = status.label(l10n);
    final duration = ReducedMotion.fade(context, SprintMotion.durationBase);

    return Semantics(
      liveRegion: true,
      label: l10n.statusSpoken(word),
      child: ExcludeSemantics(
        child: Container(
          key: containerKey,
          constraints: const BoxConstraints(
            minHeight: SprintExtras.statusBadgeHeight,
          ),
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: SprintSpacing.space3,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: SprintRadius.fullBorder,
          ),
          child: AnimatedSwitcher(
            duration: duration,
            child: Row(
              key: ValueKey<SprintStatus>(status),
              mainAxisSize: MainAxisSize.min,
              children: [
                SprintIcon(status.icon, size: SprintSize.iconSm, color: foreground),
                const SizedBox(width: SprintSpacing.space1),
                Flexible(
                  child: Text(
                    word,
                    key: wordKey,
                    style: context.text.micro.copyWith(color: foreground),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
