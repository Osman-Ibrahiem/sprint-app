import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';

/// The hourglass in a `warning-soft` disc that opens the waiting and the
/// expired states (decorative; the words carry the meaning).
class StateIconDisc extends StatelessWidget {
  const StateIconDisc({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: ExcludeSemantics(
        child: Container(
          width: SprintExtras.stateDisc,
          height: SprintExtras.stateDisc,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.warningSoft,
          ),
          alignment: Alignment.center,
          child: SprintIcon(
            PhosphorIconsRegular.hourglass,
            size: SprintExtras.stateDiscIcon,
            color: colors.warning,
          ),
        ),
      ),
    );
  }
}
