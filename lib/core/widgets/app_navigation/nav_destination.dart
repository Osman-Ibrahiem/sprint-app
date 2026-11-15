import 'package:flutter/widgets.dart';

/// One navigation destination. Labels are already localized; icons are data so
/// the icon set can change without touching the navigation forms.
@immutable
class NavDestination {
  const NavDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.mirrorInRtl = false,
    this.badgeCount,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;

  /// Only directional icons mirror in RTL.
  final bool mirrorInRtl;

  /// Unread or pending count; hidden at 0 and capped by the form.
  final int? badgeCount;

  bool get hasBadge => (badgeCount ?? 0) > 0;
}

/// The three forms the same destinations can take.
enum NavigationForm { tabBar, rail, sidebar }

/// What every navigation form needs: the list, the selection and a callback.
class NavData {
  const NavData({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<NavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
}
