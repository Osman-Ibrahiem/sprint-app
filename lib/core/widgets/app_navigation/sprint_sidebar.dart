import 'package:flutter/material.dart';
import 'package:sprint/core/adaptive/adaptive_pressable.dart';
import 'package:sprint/core/l10n/directional_icon.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/app_navigation/nav_destination.dart';
import 'package:sprint/core/widgets/app_navigation/sprint_tab_bar.dart';
import 'package:sprint/core/widgets/sprint_logo/sprint_logo.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Sidebar for expanded and large windows (`sidebar-width`), topped with the
/// Sprint lockup.
class SprintSidebar extends StatelessWidget {
  const SprintSidebar({required this.data, super.key});

  final NavData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return Semantics(
      container: true,
      label: l10n.navMainLabel,
      child: Container(
        width: SprintSize.sidebarWidth,
        decoration: BoxDecoration(
          color: colors.surface,
          border: BorderDirectional(end: BorderSide(color: colors.line)),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: SprintSpacing.space3,
                  bottom: SprintSpacing.space6,
                ),
                child: SprintLogo(
                  variant: Localizations.localeOf(context).languageCode == 'ar'
                      ? LogoVariant.lockupAr
                      : LogoVariant.lockupEn,
                  size: SprintSize.iconLg,
                ),
              ),
              for (var i = 0; i < data.destinations.length; i++)
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    bottom: SprintSpacing.space1,
                  ),
                  child: _SidebarItem(
                    destination: data.destinations[i],
                    selected: i == data.selectedIndex,
                    onTap: () => data.onSelect(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
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
    final color = selected ? colors.onPrimarySoft : colors.ink;
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
          vertical: SprintSpacing.space3,
          horizontal: SprintSpacing.space3,
        ),
        child: Row(
          children: [
            DirectionalIcon(
              selected ? destination.selectedIcon : destination.icon,
              mirror: destination.mirrorInRtl,
              size: SprintSize.iconLg,
              color: color,
            ),
            const SizedBox(width: SprintSpacing.space3),
            Expanded(
              child: Text(
                destination.label,
                style: context.text.bodyStrong.copyWith(color: color),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (destination.hasBadge)
              NavigationBadge(count: destination.badgeCount!),
          ],
        ),
      ),
    );
  }
}
