import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sprint/core/adaptive/adaptive_traits.dart';
import 'package:sprint/core/widgets/app_navigation/nav_destination.dart';
import 'package:sprint/core/widgets/app_navigation/sprint_nav_rail.dart';
import 'package:sprint/core/widgets/app_navigation/sprint_sidebar.dart';
import 'package:sprint/core/widgets/app_navigation/sprint_tab_bar.dart';
import 'package:sprint/core/window/window_size.dart';

/// One navigation component, three forms: tab bar on compact windows, rail on
/// medium and sidebar on expanded and large. The form follows the available
/// width, so a hinge pane gets the form for its own width (FR-048 – FR-056).
class AppNavigation extends StatelessWidget {
  const AppNavigation({
    required this.destinations,
    required this.selected,
    required this.onSelected,
    this.form,
    super.key,
  }) : assert(destinations.length >= 2, 'navigation needs two destinations');

  final List<NavDestination> destinations;
  final int selected;
  final ValueChanged<int> onSelected;

  /// Forces a form for the gallery; the shell leaves it null.
  final NavigationForm? form;

  /// The form a width class uses.
  static NavigationForm formFor(WindowSize size) => switch (size) {
        WindowSize.compact => NavigationForm.tabBar,
        WindowSize.medium => NavigationForm.rail,
        WindowSize.expanded || WindowSize.large => NavigationForm.sidebar,
      };

  @override
  Widget build(BuildContext context) {
    final data = NavData(
      destinations: destinations,
      selectedIndex: selected,
      onSelect: onSelected,
    );
    final chosen = form ?? formFor(WindowSize.of(context));
    final navigation = switch (chosen) {
      NavigationForm.tabBar => SprintTabBar(data: data),
      NavigationForm.rail => SprintNavRail(data: data),
      NavigationForm.sidebar => SprintSidebar(data: data),
    };

    final traits = AdaptiveTraits.of(context);
    if (!traits.numberShortcuts) return navigation;

    final bindings = <SingleActivator, VoidCallback>{};
    for (var i = 0;
        i < destinations.length && i < _numberKeys.length;
        i++) {
      bindings[SingleActivator(_numberKeys[i])] = () => onSelected(i);
    }
    return CallbackShortcuts(bindings: bindings, child: navigation);
  }

  static const _numberKeys = <LogicalKeyboardKey>[
    LogicalKeyboardKey.digit1,
    LogicalKeyboardKey.digit2,
    LogicalKeyboardKey.digit3,
    LogicalKeyboardKey.digit4,
    LogicalKeyboardKey.digit5,
  ];
}
