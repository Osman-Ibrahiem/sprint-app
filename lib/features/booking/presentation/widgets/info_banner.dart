import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';

/// An icon and a sentence on a soft warning surface, announced as a live
/// region. The one banner of the booking flow: the schedule's notices (with a
/// dismiss action as [trailing]) and the summary's "price changed" line.
///
/// Only the sentence is announced as the live region. [trailing] stays in the
/// semantics tree, so a screen reader can reach its action.
class InfoBanner extends StatelessWidget {
  const InfoBanner({required this.text, this.trailing, super.key});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsetsDirectional.only(
        start: SprintSpacing.space3,
        end: trailing == null ? SprintSpacing.space3 : 0,
        top: trailing == null ? SprintSpacing.space3 : SprintSpacing.space1,
        bottom: trailing == null ? SprintSpacing.space3 : SprintSpacing.space1,
      ),
      decoration: BoxDecoration(
        color: colors.warningSoft,
        borderRadius: SprintRadius.mdBorder,
      ),
      child: Row(
        children: [
          SprintIcon(
            PhosphorIconsRegular.info,
            size: SprintSize.iconMd,
            color: colors.ink,
          ),
          const SizedBox(width: SprintSpacing.space2),
          Expanded(
            child: Semantics(
              liveRegion: true,
              container: true,
              label: text,
              child: ExcludeSemantics(
                child: Text(text, style: context.text.body),
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
