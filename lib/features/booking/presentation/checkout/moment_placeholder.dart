import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_colors.g.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';

/// Success or failure.
enum MomentKind { success, failure }

/// A static stand-in for the success and failure moments: an icon in a soft
/// circle, a title and an optional sentence. No animation; feature 11 swaps
/// it for the Lottie moment. The icon is decorative; the words carry the
/// meaning, and the title is announced once as a live region when [announce].
class MomentPlaceholder extends StatelessWidget {
  const MomentPlaceholder({
    required this.kind,
    required this.title,
    this.body,
    this.announce = false,
    super.key,
  });

  final MomentKind kind;
  final String title;
  final String? body;
  final bool announce;

  static const titleKey = ValueKey<String>('moment-title');
  static const successKey = ValueKey<String>('moment-success');

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final success = kind == MomentKind.success;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: success ? _successBadge(colors) : _failureBadge(colors),
        ),
        const SizedBox(height: SprintSpacing.space3),
        Semantics(
          liveRegion: announce,
          header: true,
          container: true,
          child: Text(
            title,
            key: titleKey,
            style: success ? context.text.display : context.text.title,
            textAlign: TextAlign.center,
          ),
        ),
        if (body != null) ...[
          const SizedBox(height: SprintSpacing.space2),
          Text(
            body!,
            style: context.text.body.copyWith(color: colors.inkMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// The failure moment's stand-in: a card in a `danger-soft` disc with a red
/// cross badge, as the design draws it.
Widget _failureBadge(SprintColors colors) => SizedBox(
  width: SprintExtras.momentOuter,
  height: SprintExtras.momentOuter,
  child: Stack(
    alignment: Alignment.center,
    children: [
      Container(
        key: const ValueKey<String>('moment-failure'),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.dangerSoft,
        ),
        alignment: Alignment.center,
        child: SprintIcon(
          PhosphorIconsRegular.creditCard,
          size: SprintExtras.momentIcon,
          color: colors.danger,
        ),
      ),
      PositionedDirectional(
        start: SprintExtras.momentBadgeInset,
        bottom: SprintExtras.momentBadgeInset,
        child: Container(
          width: SprintExtras.momentBadge,
          height: SprintExtras.momentBadge,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.danger,
          ),
          alignment: Alignment.center,
          child: SprintIcon(
            PhosphorIconsRegular.x,
            size: SprintSize.iconLg,
            color: colors.onDanger,
          ),
        ),
      ),
    ],
  ),
);

/// The success moment's stand-in: a check in a `success-soft` disc (decision
/// 19 of refactor 000). The last frame must read as "success" on its own,
/// because reduced motion shows only that frame; feature 11 draws the check
/// in once with Lottie.
Widget _successBadge(SprintColors colors) => Container(
  key: MomentPlaceholder.successKey,
  width: SprintExtras.momentOuter,
  height: SprintExtras.momentOuter,
  decoration: BoxDecoration(shape: BoxShape.circle, color: colors.successSoft),
  alignment: Alignment.center,
  child: SprintIcon(
    PhosphorIconsBold.check,
    size: SprintExtras.momentIcon,
    color: colors.success,
  ),
);
