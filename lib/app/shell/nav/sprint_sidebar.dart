import 'package:flutter/material.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/app/shell/nav/nav_destinations_view.dart';
import 'package:sprint/core/a11y/focusable_tap.dart';
import 'package:sprint/core/l10n/directional_icon.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Sidebar for expanded and large windows (`sidebar-width`), with the Sprint
/// wordmark at the top (the SVG logo widget is feature 2).
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
                child: Text(l10n.appName, style: context.text.title),
              ),
              for (var i = 0; i < data.destinations.length; i++)
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    bottom: SprintSpacing.space1,
                  ),
                  child: _SidebarItem(
                    destination: data.destinations[i],
                    label: data.destinations[i].label(l10n),
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
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final ShellDestination destination;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = selected ? colors.onPrimarySoft : colors.ink;
    return FocusableTap(
      label: label,
      selected: selected,
      onTap: onTap,
      builder: (context, hovered) => DecoratedBox(
        decoration: BoxDecoration(
          color: selected
              ? colors.primarySoft
              : (hovered ? colors.surfaceSunken : Colors.transparent),
          borderRadius: SprintRadius.mdBorder,
        ),
        child: Padding(
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
                  label,
                  style: context.text.bodyStrong.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
