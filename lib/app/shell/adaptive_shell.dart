import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/app/shell/shell_keys.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/widgets/app_navigation/app_navigation.dart';
import 'package:sprint/core/widgets/app_navigation/nav_destination.dart';
import 'package:sprint/core/window/display_feature_layout.dart';
import 'package:sprint/core/window/window_size.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The app shell: tab bar, rail or sidebar chosen by window width, around one
/// shared [StatefulNavigationShell] (FR-002 – FR-006).
///
/// The shell body lives under a [GlobalKey], so a change of form (resize, fold,
/// unfold) re-parents it instead of rebuilding it. The selected branch, typed
/// text and scroll positions therefore survive (FR-005).
class AdaptiveShell extends StatefulWidget {
  const AdaptiveShell({
    required this.navigationShell,
    required this.destinations,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final List<ShellDestination> destinations;

  @override
  State<AdaptiveShell> createState() => _AdaptiveShellState();
}

class _AdaptiveShellState extends State<AdaptiveShell> {
  final _bodyKey = GlobalKey(debugLabel: 'shell-body');

  void _select(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    // The shell UI is built inside the layout's pane, so its size class
    // follows the pane's width when a hinge splits the screen.
    return DisplayFeatureLayout(start: Builder(builder: _buildUi));
  }

  Widget _buildUi(BuildContext context) {
    final size = WindowSize.of(context);
    final l10n = AppLocalizations.of(context);
    final destinations = [
      for (final destination in widget.destinations)
        NavDestination(
          label: destination.label(l10n),
          icon: destination.icon,
          selectedIcon: destination.selectedIcon,
          mirrorInRtl: destination.mirrorInRtl,
        ),
    ];
    final form = AppNavigation.formFor(size);
    final navigation = AppNavigation(
      destinations: destinations,
      selected: widget.navigationShell.currentIndex,
      onSelected: _select,
      form: form,
    );

    final body = KeyedSubtree(key: _bodyKey, child: widget.navigationShell);
    final Widget content = size == WindowSize.large
        ? Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: SprintSize.contentMax,
              ),
              child: SizedBox.expand(key: shellContentKey, child: body),
            ),
          )
        : SizedBox.expand(key: shellContentKey, child: body);

    // Checkout, the ticket and the receipt stand alone on compact: no tab
    // bar to leave the payment by (BR-47); the rail and sidebar stay.
    final path = GoRouter.of(context)
        .routerDelegate
        .currentConfiguration
        .uri
        .path;
    final standAlone = AppPaths.isPaymentFlow(path);
    return switch (form) {
      NavigationForm.tabBar => Scaffold(
        body: content,
        bottomNavigationBar: standAlone ? null : navigation,
      ),
      NavigationForm.rail => Scaffold(
        body: Row(
          children: [
            navigation,
            Expanded(child: content),
          ],
        ),
      ),
      NavigationForm.sidebar => Scaffold(
        body: Row(
          children: [
            navigation,
            Expanded(child: content),
          ],
        ),
      ),
    };
  }
}
