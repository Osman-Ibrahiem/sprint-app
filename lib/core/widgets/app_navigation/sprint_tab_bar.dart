import 'package:flutter/material.dart';
import 'package:sprint/core/adaptive/adaptive_bar_surface.dart';
import 'package:sprint/core/adaptive/adaptive_haptics.dart';
import 'package:sprint/core/adaptive/adaptive_pressable.dart';
import 'package:sprint/core/adaptive/adaptive_sheet.dart';
import 'package:sprint/core/adaptive/adaptive_traits.dart';
import 'package:sprint/core/l10n/directional_icon.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/app_navigation/nav_destination.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';

/// Bottom tab bar for compact windows. Solid `surface` on Android and the web,
/// translucent with a blur on Apple platforms (adaptive.md). It extends behind
/// the bottom safe area while its items stay inside it.
class SprintTabBar extends StatelessWidget {
  const SprintTabBar({required this.data, super.key});

  final NavData data;

  /// At most five items; a sixth onward becomes four plus "المزيد".
  static const maxVisible = 5;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final showLabels = MediaQuery.textScalerOf(context).scale(1) <=
        SprintExtras.navLabelMaxTextScale;
    final overflow = data.destinations.length > maxVisible;

    final bar = AdaptiveBarSurface(
      border: BorderDirectional(top: BorderSide(color: colors.line)),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: SprintSize.tabbarHeight),
          child: SizedBox(
            height: SprintSize.tabbarHeight,
            child: Row(
              children: [
                for (var i = 0;
                    i <
                        (overflow
                            ? maxVisible - 1
                            : data.destinations.length);
                    i++)
                  Expanded(
                    child: _TabItem(
                      destination: data.destinations[i],
                      selected: i == data.selectedIndex,
                      showLabel: showLabels,
                      onTap: () => data.onSelect(i),
                    ),
                  ),
                if (overflow)
                  Expanded(
                    child: _MoreItem(
                      showLabel: showLabels,
                      onTap: () => _openMore(context, l10n),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    return Semantics(
      container: true,
      label: l10n.navMainLabel,
      child: bar,
    );
  }

  Future<void> _openMore(BuildContext context, AppLocalizations l10n) async {
    final start = maxVisible - 1;
    final picked = await showSprintSheet<int>(
      context: context,
      title: l10n.navMore,
      cancelLabel: l10n.navMore,
      actions: [
        for (var i = start; i < data.destinations.length; i++)
          SprintSheetAction<int>(
            label: _spoken(data.destinations[i], l10n),
            value: i,
          ),
      ],
    );
    if (picked != null) data.onSelect(picked);
  }

  static String _spoken(NavDestination destination, AppLocalizations l10n) {
    if (!destination.hasBadge) return destination.label;
    final count = destination.badgeCount!;
    final capped =
        count > SprintExtras.navigationBadgeCap ? SprintExtras.navigationBadgeCap : count;
    return '${destination.label}، ${l10n.navBadgeSpoken(capped)}';
  }

  /// The title an item exposes to assistive technology and to the gallery.
  static String spokenLabel(NavDestination destination, AppLocalizations l10n) =>
      _spoken(destination, l10n);
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.destination,
    required this.selected,
    required this.showLabel,
    required this.onTap,
  });

  final NavDestination destination;
  final bool selected;
  final bool showLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final traits = AdaptiveTraits.of(context);
    final color = selected ? colors.primary : colors.inkMuted;

    return AdaptivePressable(
      label: SprintTabBar.spokenLabel(destination, l10n),
      selected: selected,
      liveRegion: destination.hasBadge,
      onTap: () {
        AdaptiveHaptics.selection(context);
        onTap();
      },
      restingColor: Colors.transparent,
      hoverColor: colors.surfaceSunken,
      borderRadius: SprintRadius.mdBorder,
      builder: (context, state) => Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          vertical: SprintSpacing.space2,
          horizontal: SprintSpacing.space1,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: SprintSpacing.space3,
              ),
              decoration: BoxDecoration(
                color: selected && traits.tabBarPill
                    ? colors.primarySoft
                    : Colors.transparent,
                borderRadius: SprintRadius.fullBorder,
              ),
              child: Row(
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
            ),
            if (showLabel) ...[
              const SizedBox(height: SprintSpacing.space1),
              Text(
                destination.label,
                style: context.text.micro.copyWith(color: color),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MoreItem extends StatelessWidget {
  const _MoreItem({required this.showLabel, required this.onTap});

  final bool showLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return AdaptivePressable(
      label: l10n.navMore,
      onTap: onTap,
      restingColor: Colors.transparent,
      hoverColor: colors.surfaceSunken,
      borderRadius: SprintRadius.mdBorder,
      builder: (context, state) => Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          vertical: SprintSpacing.space2,
          horizontal: SprintSpacing.space1,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SprintIcon(
              Icons.more_horiz,
              size: SprintSize.iconLg,
              color: colors.inkMuted,
            ),
            if (showLabel) ...[
              const SizedBox(height: SprintSpacing.space1),
              Text(
                l10n.navMore,
                style: context.text.micro.copyWith(color: colors.inkMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The "99+" badge, in `danger` with `on-danger`.
class NavigationBadge extends StatelessWidget {
  const NavigationBadge({required this.count, super.key});

  final int count;

  static const textKey = ValueKey<String>('navigation-badge-text');

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cap = SprintExtras.navigationBadgeCap;
    final text = count > cap ? '$cap+' : '$count';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.danger,
        borderRadius: SprintRadius.fullBorder,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: SprintSpacing.space1,
        ),
        child: Text(
          text,
          key: textKey,
          style: context.text.micro.copyWith(color: colors.onDanger),
        ),
      ),
    );
  }
}
