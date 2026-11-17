import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final success = kind == MomentKind.success;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: Container(
            width: SprintSize.controlHeight,
            height: SprintSize.controlHeight,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: success ? colors.successSoft : colors.dangerSoft,
            ),
            alignment: Alignment.center,
            child: SprintIcon(
              success ? PhosphorIconsRegular.checkCircle : PhosphorIconsRegular.xCircle,
              size: SprintSize.iconLg,
              color: success ? colors.success : colors.danger,
            ),
          ),
        ),
        const SizedBox(height: SprintSpacing.space3),
        Semantics(
          liveRegion: announce,
          header: true,
          container: true,
          child: Text(
            title,
            key: titleKey,
            style: context.text.titleLg,
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
