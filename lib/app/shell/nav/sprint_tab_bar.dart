import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/app/shell/nav/nav_destinations_view.dart';
import 'package:sprint/app/shell/nav/nav_item_frame.dart';
import 'package:sprint/core/adaptive/platform.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Bottom tab bar for compact windows. Solid `surface` on Android and the web,
/// translucent with a blur on Apple platforms (adaptive.md). It extends behind
/// the bottom safe area while its items stay inside it.
class SprintTabBar extends StatelessWidget {
  const SprintTabBar({required this.data, super.key});

  final NavData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final apple = isApplePlatform(context);
    final showLabels = MediaQuery.textScalerOf(context).scale(1) <=
        SprintExtras.navLabelMaxTextScale;

    Widget bar = DecoratedBox(
      decoration: BoxDecoration(
        color: apple
            ? colors.surface.withValues(alpha: SprintExtras.tabBarTranslucentAlpha)
            : colors.surface,
        border: BorderDirectional(
          top: BorderSide(color: colors.line),
        ),
      ),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: SprintSize.tabbarHeight),
          child: Row(
            children: [
              for (var i = 0; i < data.destinations.length; i++)
                Expanded(
                  child: _TabItem(
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

    if (apple) {
      bar = ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: SprintExtras.tabBarBlurSigma,
            sigmaY: SprintExtras.tabBarBlurSigma,
          ),
          child: bar,
        ),
      );
    }

    return Semantics(
      container: true,
      label: l10n.navMainLabel,
      child: bar,
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
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
    final color = selected ? colors.primary : colors.inkMuted;
    return NavItemFrame(
      label: label,
      selected: selected,
      onTap: onTap,
      builder: (context, hovered) => ColoredBox(
        color: hovered ? colors.surfaceSunken : Colors.transparent,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            vertical: SprintSpacing.space2,
            horizontal: SprintSpacing.space1,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? destination.selectedIcon : destination.icon,
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
