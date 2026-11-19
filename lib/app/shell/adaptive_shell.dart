import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/app/shell/shell_keys.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/widgets/app_navigation/app_navigation.dart';
import 'package:sprint/core/widgets/app_navigation/nav_destination.dart';
import 'package:sprint/core/window/display_feature_layout.dart';
import 'package:sprint/core/window/window_size.dart';
import 'package:sprint/features/notifications/presentation/providers/notification_providers.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The app shell: tab bar, rail or sidebar chosen by window width, around one
/// shared [StatefulNavigationShell] (FR-002 – FR-006).
///
/// The shell body lives under a [GlobalKey], so a change of form (resize, fold,
/// unfold) re-parents it instead of rebuilding it. The selected branch, typed
/// text and scroll positions therefore survive (FR-005).
class AdaptiveShell extends ConsumerStatefulWidget {
  const AdaptiveShell({
    required this.navigationShell,
    required this.destinations,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final List<ShellDestination> destinations;

  @override
  ConsumerState<AdaptiveShell> createState() => _AdaptiveShellState();
}

class _AdaptiveShellState extends ConsumerState<AdaptiveShell> {
  final _bodyKey = GlobalKey(debugLabel: 'shell-body');

  /// The last branch that is a tab in every form. The notifications
  /// destination has none on compact (the bell opens it), so while it is open
  /// the tab the person came from stays highlighted (R1).
  /// A direct load of `/notifications` has no earlier tab, so "الرئيسية" (the
  /// first branch) is the documented default.
  int _lastVisibleBranch = 0;

  void _rememberBranch() {
    final current = widget.navigationShell.currentIndex;
    if (widget.destinations[current].name != AppRouteNames.notifications) {
      _lastVisibleBranch = current;
    }
  }

  @override
  void initState() {
    super.initState();
    _rememberBranch();
  }

  @override
  void didUpdateWidget(AdaptiveShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    _rememberBranch();
  }

  void _select(int branch) {
    widget.navigationShell.goBranch(
      branch,
      initialLocation: branch == widget.navigationShell.currentIndex,
    );
  }

  /// Notifications is a destination only for a signed-in person on medium and
  /// up; on compact the bell opens it (FR-NTF-02).
  bool _isVisible(ShellDestination d, WindowSize size, bool guest) =>
      d.name != AppRouteNames.notifications || (!guest && !size.isCompact);

  @override
  Widget build(BuildContext context) {
    // The shell UI is built inside the layout's pane, so its size class
    // follows the pane's width when a hinge splits the screen.
    return DisplayFeatureLayout(start: Builder(builder: _buildUi));
  }

  Widget _buildUi(BuildContext context) {
    final size = WindowSize.of(context);
    final l10n = AppLocalizations.of(context);
    final guest = ref.watch(currentSessionProvider).isGuest;
    final unread = ref.watch(unreadCountProvider);
    final branches = [
      for (var i = 0; i < widget.destinations.length; i++)
        if (_isVisible(widget.destinations[i], size, guest)) i,
    ];
    final current = widget.navigationShell.currentIndex;
    final shown = branches.contains(current) ? current : _lastVisibleBranch;
    final selected = branches.indexOf(shown).clamp(0, branches.length - 1);
    final destinations = [
      for (final i in branches)
        NavDestination(
          label: widget.destinations[i].label(l10n),
          icon: widget.destinations[i].icon,
          selectedIcon: widget.destinations[i].selectedIcon,
          mirrorInRtl: widget.destinations[i].mirrorInRtl,
          badgeCount: widget.destinations[i].name == AppRouteNames.notifications
              ? unread
              : null,
        ),
    ];
    final form = AppNavigation.formFor(size);
    final navigation = AppNavigation(
      destinations: destinations,
      selected: selected,
      onSelected: (v) => _select(branches[v]),
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
