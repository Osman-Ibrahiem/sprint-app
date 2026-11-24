import 'package:flutter/material.dart';
import 'package:sprint/core/adaptive/adaptive_pressable.dart';
import 'package:sprint/core/l10n/directional_icon.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/app_navigation/nav_destination.dart';
import 'package:sprint/core/widgets/app_navigation/sprint_tab_bar.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Navigation rail for medium windows (`rail-width`).
class SprintNavRail extends StatelessWidget {
  const SprintNavRail({required this.data, super.key});

  final NavData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return Semantics(
      container: true,
      label: l10n.navMainLabel,
      child: Container(
        width: SprintSize.railWidth,
        decoration: BoxDecoration(
          color: colors.surface,
          border: BorderDirectional(end: BorderSide(color: colors.line)),
        ),
        // Labels stay visible; their scale stops at `navLabelMaxTextScale`
        // (decision T2 of refactor 000).
        child: SafeArea(
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: SprintExtras.navLabelMaxTextScale,
            child: ListView(
              padding: const EdgeInsetsDirectional.symmetric(
                vertical: SprintSpacing.space4,
                horizontal: SprintSpacing.space2,
              ),
              children: [
                for (var i = 0; i < data.destinations.length; i++)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      bottom: SprintSpacing.space2,
                    ),
                    child: _RailItem(
                      destination: data.destinations[i],
                      selected: i == data.selectedIndex,
                      onTap: () => data.onSelect(i),
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

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final NavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final color = selected ? colors.onPrimarySoft : colors.inkMuted;
    return AdaptivePressable(
      label: SprintTabBar.spokenLabel(destination, l10n),
      selected: selected,
      liveRegion: destination.hasBadge,
      onTap: onTap,
      restingColor: selected ? colors.primarySoft : Colors.transparent,
      hoverColor: colors.surfaceSunken,
      pressedColor: colors.surfaceSunken,
      borderRadius: SprintRadius.mdBorder,
      builder: (context, state) => Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          vertical: SprintSpacing.space2,
          horizontal: SprintSpacing.space1,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DirectionalIcon(
                  selected ? destination.selectedIcon : destination.icon,
                  mirror: destination.mirrorInRtl,
                  size: SprintSize.iconLg,
                  color: color,
                ),
                if (destination.hasBadge) ...[
                  const SizedBox(width: SprintSpacing.space1),
                  NavigationBadge(count: destination.badgeCount!),
                ],
              ],
            ),
            const SizedBox(height: SprintSpacing.space1),
            Text(
              destination.label,
              style: context.text.micro.copyWith(color: color),
              textAlign: TextAlign.center,
              // A long label ("My bookings" in a narrow item) takes a second
              // line instead of an ellipsis (decision T1 of refactor 000).
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
