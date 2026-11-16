import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sprint/app/shell/placeholders/no_access_screen.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/features/identity/domain/app_section.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
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
  static const demoComponents = '/demo/components';

  // Feature 003 (contracts/routes.md).
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const confirmEmail = '/confirm-email';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const profileVerification = '/profile/verification';
  static const verification = '/verification';
  static const verificationUpload = '/verification/upload';

  /// Route pattern for one request; build a location with
  /// [verificationDetailFor].
  static const verificationDetail = '/verification/:id';
  static const demoMailbox = '/demo/mailbox';

  static String verificationDetailFor(String id) =>
      '$verification/${Uri.encodeComponent(id)}';

  /// The guest-only auth routes, which a signed-in person leaves at once.
  static const authEntry = {signIn, signUp};

  /// Every auth route: never a valid `from` target (no loops).
  static const auth = {
    signIn,
    signUp,
    confirmEmail,
    forgotPassword,
    resetPassword,
  };

  /// `/sign-in` with the place to return to after signing in.
  static String signInFrom(String from) =>
      Uri(path: signIn, queryParameters: {'from': from}).toString();

  /// `/reset-password` for [identifier], keeping `from`.
  static String resetFor(String identifier, String? from) => Uri(
    path: resetPassword,
    queryParameters: {
      'identifier': identifier,
      if (from != null && from.isNotEmpty) 'from': from,
    },
  ).toString();

  /// [path] keeping the place to return to (`from`), when there is one.
  static String keepingFrom(String path, String? from, {String? email}) => Uri(
    path: path,
    queryParameters: {
      'email': ?email,
      if (from != null && from.isNotEmpty) 'from': from,
    },
  ).toString();
}

/// Route names.
abstract final class AppRouteNames {
  static const home = 'home';
  static const facilities = 'facilities';
  static const bookings = 'bookings';
  static const profile = 'profile';
  static const demo = 'demo';
  static const demoComponents = 'demoComponents';
  static const signIn = 'signIn';
  static const signUp = 'signUp';
  static const confirmEmail = 'confirmEmail';
  static const forgotPassword = 'forgotPassword';
  static const resetPassword = 'resetPassword';
  static const profileVerification = 'profileVerification';
  static const verification = 'verification';
  static const verificationDetail = 'verificationDetail';
  static const verificationUpload = 'verificationUpload';
  static const demoMailbox = 'demoMailbox';
}

/// What a route needs from the person (contracts/routes.md rule 2). A guest
/// is sent to sign in; a signed-in person without [requiredSection] sees
/// `NoAccessScreen` at the same location.
class RouteAccess {
  const RouteAccess({this.requiresAccount = false, this.requiredSection});

  static const open = RouteAccess();

  /// A signed-in account is needed. Implied by [requiredSection].
  final bool requiresAccount;
  final AppSection? requiredSection;

  bool get needsAccount => requiresAccount || requiredSection != null;

  bool allows(Session session) =>
      requiredSection == null ||
      sectionsFor(session.roles).contains(requiredSection);
}

/// A route with an access rule. The router's redirect reads [access]; the
/// body shows `NoAccessScreen` for a signed-in person without the section.
class GatedRoute extends GoRoute {
  GatedRoute({
    required super.path,
    super.name,
    required Widget Function(BuildContext, GoRouterState) builder,
    this.access = RouteAccess.open,
    super.routes,
  }) : super(
         builder: (context, state) => access.requiredSection == null
             ? builder(context, state)
             : Consumer(
                 builder: (context, ref, _) =>
                     access.allows(ref.watch(currentSessionProvider))
                     ? builder(context, state)
                     : const NoAccessScreen(),
               ),
       );

  final RouteAccess access;
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
    this.access = RouteAccess.open,
  });

  final String name;
  final String path;
  final IconData icon;
  final IconData selectedIcon;
  final String Function(AppLocalizations l10n) label;
  final Widget Function() builder;

  /// Only directional icons mirror in RTL; none of the base four do.
  final bool mirrorInRtl;

  /// Who may open it; a staff destination sets `requiredSection`.
  final RouteAccess access;
}

/// The four destinations every guest and booker sees, in order (the first is
/// at the start edge: right in Arabic). Icons are Phosphor Regular, with Fill
/// for the active item (FR-012, research R4).
final List<ShellDestination> baseDestinations = <ShellDestination>[
  ShellDestination(
    name: AppRouteNames.home,
    path: AppPaths.home,
    icon: PhosphorIconsRegular.house,
    selectedIcon: PhosphorIconsFill.house,
    label: (l) => l.navHome,
    builder: HomePlaceholder.new,
  ),
  ShellDestination(
    name: AppRouteNames.facilities,
    path: AppPaths.facilities,
    icon: PhosphorIconsRegular.squaresFour,
    selectedIcon: PhosphorIconsFill.squaresFour,
    label: (l) => l.navFacilities,
    builder: FacilitiesPlaceholder.new,
  ),
  ShellDestination(
    name: AppRouteNames.bookings,
    path: AppPaths.bookings,
    icon: PhosphorIconsRegular.ticket,
    selectedIcon: PhosphorIconsFill.ticket,
    label: (l) => l.navBookings,
    builder: BookingsPlaceholder.new,
  ),
  ShellDestination(
    name: AppRouteNames.profile,
    path: AppPaths.profile,
    icon: PhosphorIconsRegular.user,
    selectedIcon: PhosphorIconsFill.user,
    label: (l) => l.navProfile,
    builder: ProfilePlaceholder.new,
  ),
];
