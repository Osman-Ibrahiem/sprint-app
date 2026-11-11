import 'package:flutter/material.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/app/shell/nav/nav_destinations_view.dart';
import 'package:sprint/core/a11y/focusable_tap.dart';
import 'package:sprint/core/l10n/directional_icon.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Navigation rail for medium windows (`rail-width`).
class SprintNavRail extends StatelessWidget {
  const SprintNavRail({required this.data, super.key});

  final NavData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final showLabels = MediaQuery.textScalerOf(context).scale(1) <=
        SprintExtras.navLabelMaxTextScale;

    return Semantics(
      container: true,
      label: l10n.navMainLabel,
      child: Container(
        width: SprintSize.railWidth,
        decoration: BoxDecoration(
          color: colors.surface,
          border: BorderDirectional(end: BorderSide(color: colors.line)),
        ),
        child: SafeArea(
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
                    label: data.destinations[i].label(l10n),
                    selected: i == data.selectedIndex,
                    showLabel: showLabels,
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

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.destination,
    required this.label,
    required this.selected,
    required this.showLabel,
    required this.onTap,
  });

  final ShellDestination destination;
  final String label;
  final bool selected;
  final bool showLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = selected ? colors.onPrimarySoft : colors.inkMuted;
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
            vertical: SprintSpacing.space2,
            horizontal: SprintSpacing.space1,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DirectionalIcon(
                selected ? destination.selectedIcon : destination.icon,
                mirror: destination.mirrorInRtl,
                size: SprintSize.iconLg,
                color: color,
              ),
              if (showLabel) ...[
                const SizedBox(height: SprintSpacing.space1),
                Text(
                  label,
                  style: context.text.micro.copyWith(color: color),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
