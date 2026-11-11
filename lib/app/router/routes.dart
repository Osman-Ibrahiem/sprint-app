import 'package:flutter/material.dart';
import 'package:sprint/app/shell/placeholders/bookings_placeholder.dart';
import 'package:sprint/app/shell/placeholders/facilities_placeholder.dart';
import 'package:sprint/app/shell/placeholders/home_placeholder.dart';
import 'package:sprint/app/shell/placeholders/profile_placeholder.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Route paths. Screens never build path strings by hand.
abstract final class AppPaths {
  static const root = '/';
  static const home = '/home';
  static const facilities = '/facilities';
  static const bookings = '/bookings';
  static const profile = '/profile';
  static const demo = '/demo';
}

/// Route names.
abstract final class AppRouteNames {
  static const home = 'home';
  static const facilities = 'facilities';
  static const bookings = 'bookings';
  static const profile = 'profile';
  static const demo = 'demo';
}

/// One top-level shell destination. The shell and the router are built from a
/// list of these, so role-specific destinations later arrive as data (FR-007).
class ShellDestination {
  const ShellDestination({
    required this.name,
    required this.path,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.builder,
    this.mirrorInRtl = false,
  });

  final String name;
  final String path;
  final IconData icon;
  final IconData selectedIcon;
  final String Function(AppLocalizations l10n) label;
  final Widget Function() builder;

  /// Only directional icons mirror in RTL; none of the base four do.
  final bool mirrorInRtl;
}

/// The four destinations every guest and booker sees, in order (the first is
/// at the start edge: right in Arabic). Icons are Material for now; the
/// Phosphor set arrives with the design-system widgets (feature 2).
final List<ShellDestination> baseDestinations = <ShellDestination>[
  ShellDestination(
    name: AppRouteNames.home,
    path: AppPaths.home,
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
    label: (l) => l.navHome,
    builder: HomePlaceholder.new,
  ),
  ShellDestination(
    name: AppRouteNames.facilities,
    path: AppPaths.facilities,
    icon: Icons.fitness_center_outlined,
    selectedIcon: Icons.fitness_center,
    label: (l) => l.navFacilities,
    builder: FacilitiesPlaceholder.new,
  ),
  ShellDestination(
    name: AppRouteNames.bookings,
    path: AppPaths.bookings,
    icon: Icons.confirmation_number_outlined,
    selectedIcon: Icons.confirmation_number,
    label: (l) => l.navBookings,
    builder: BookingsPlaceholder.new,
  ),
  ShellDestination(
    name: AppRouteNames.profile,
    path: AppPaths.profile,
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
    label: (l) => l.navProfile,
    builder: ProfilePlaceholder.new,
  ),
];
