import 'package:flutter/widgets.dart';
import 'package:sprint/app/router/routes.dart';

/// What every navigation form needs: the list, the selection and a callback.
class NavData {
  const NavData({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<ShellDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
}
