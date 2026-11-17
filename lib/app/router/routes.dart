import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/app/shell/placeholders/bookings_placeholder.dart';
import 'package:sprint/app/shell/placeholders/no_access_screen.dart';
import 'package:sprint/app/shell/placeholders/profile_placeholder.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/features/booking/domain/schedule_notice.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';
import 'package:sprint/features/booking/presentation/checkout/checkout_coming_soon_screen.dart';
import 'package:sprint/features/booking/presentation/done/booking_done_screen.dart';
import 'package:sprint/features/booking/presentation/schedule/schedule_screen.dart';
import 'package:sprint/features/booking/presentation/summary/booking_summary_screen.dart';
import 'package:sprint/features/catalogue/domain/facility_link.dart';
import 'package:sprint/features/catalogue/presentation/facilities/facilities_screen.dart';
import 'package:sprint/features/catalogue/presentation/facilities/facility_not_found.dart';
import 'package:sprint/features/catalogue/presentation/home/home_screen.dart';
import 'package:sprint/features/identity/domain/app_section.dart';
import 'package:sprint/features/verification/presentation/verification_request_screen.dart';
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
  static String facilityDetails(String id) => FacilityLink.path(id);

  /// The schedule of a facility, with the selection in the address
  /// (contracts/routes.md). Built only through [ScheduleSelection.toQuery].
  static String facilitySchedule(String id, [ScheduleSelection? selection]) =>
      _withQuery('${FacilityLink.path(id)}/schedule', selection?.toQuery());

  /// The booking summary; [shown] is the amount the schedule displayed.
  static String bookingSummary(
    String id,
    ScheduleSelection selection, {
    int? shown,
  }) => _withQuery('${FacilityLink.path(id)}/schedule/summary', {
    ...selection.toQuery(),
    if (shown != null) 'shown': '$shown',
  });

  static String bookingCheckout(String id, ScheduleSelection selection) =>
      _withQuery(
        '${FacilityLink.path(id)}/schedule/checkout',
        selection.toQuery(),
      );

  static String bookingDone(String id, String bookingId) =>
      '${FacilityLink.path(id)}/schedule/done/$bookingId';

  static String _withQuery(String path, Map<String, String>? query) =>
      query == null || query.isEmpty
      ? path
      : Uri(path: path, queryParameters: query).toString();
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
  static const facilityDetails = 'facilityDetails';
  static const facilitySchedule = 'facilitySchedule';
  static const bookingSummary = 'bookingSummary';
  static const bookingCheckout = 'bookingCheckout';
  static const bookingDone = 'bookingDone';
}

/// Marks an auth route pushed on top of a screen by the account gate
/// (`requireAccount`, research R6). Such a route pops with `true` when the
/// person is signed in, instead of going to `from`, and the router does not
/// redirect it away, so the screen underneath keeps its state. Passed as the
/// route's `extra`, so a browser refresh falls back to the plain flow.
class GateExtra {
  const GateExtra();
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
    super.redirect,
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
    this.subRoutes = const [],
    this.mirrorInRtl = false,
    this.access = RouteAccess.open,
  });

  final String name;
  final String path;
  final IconData icon;
  final IconData selectedIcon;
  final String Function(AppLocalizations l10n) label;
  final Widget Function() builder;

  /// Routes nested under this destination, so they stay inside the shell and
  /// the tab keeps its own back stack (contracts/routes.md): detail routes
  /// such as `/facilities/:id` or `/verification/:id`. A gated child (for
  /// example `/profile/verification`) is a `GatedRoute` with its own access.
  final List<RouteBase> subRoutes;

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
    builder: HomeScreen.new,
  ),
  ShellDestination(
    name: AppRouteNames.facilities,
    path: AppPaths.facilities,
    icon: PhosphorIconsRegular.squaresFour,
    selectedIcon: PhosphorIconsFill.squaresFour,
    label: (l) => l.navFacilities,
    builder: FacilitiesScreen.new,
    subRoutes: [
      GoRoute(
        path: ':id',
        name: AppRouteNames.facilityDetails,
        builder: (context, state) =>
            FacilitiesScreen(selectedId: state.pathParameters['id']),
        routes: [
          GoRoute(
            path: 'schedule',
            name: AppRouteNames.facilitySchedule,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              final selection = ScheduleSelection.fromQuery(
                state.uri.queryParameters,
              );
              return FacilitiesScreen(
                selectedId: id,
                paneBuilder: (_) => ScheduleScreen(
                  facilityId: id,
                  selection: selection,
                  notFound: (_) => const FacilityNotFound(),
                  initialNotice: state.extra is ScheduleNotice
                      ? state.extra! as ScheduleNotice
                      : null,
                ),
              );
            },
            routes: [
              // The next three need an account; a guest is sent to sign in
              // and back to the same location (contracts/routes.md).
              GatedRoute(
                path: 'summary',
                name: AppRouteNames.bookingSummary,
                access: const RouteAccess(requiresAccount: true),
                redirect: _needsCompleteSelection,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return FacilitiesScreen(
                    selectedId: id,
                    paneBuilder: (_) => BookingSummaryScreen(
                      facilityId: id,
                      selection: ScheduleSelection.fromQuery(
                        state.uri.queryParameters,
                      ),
                      shown: int.tryParse(
                        state.uri.queryParameters['shown'] ?? '',
                      ),
                    ),
                  );
                },
              ),
              GatedRoute(
                path: 'checkout',
                name: AppRouteNames.bookingCheckout,
                access: const RouteAccess(requiresAccount: true),
                redirect: _needsCompleteSelection,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return FacilitiesScreen(
                    selectedId: id,
                    paneBuilder: (_) => CheckoutComingSoonScreen(
                      facilityId: id,
                      selection: ScheduleSelection.fromQuery(
                        state.uri.queryParameters,
                      ),
                    ),
                  );
                },
              ),
              GatedRoute(
                path: 'done/:bookingId',
                name: AppRouteNames.bookingDone,
                access: const RouteAccess(requiresAccount: true),
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return FacilitiesScreen(
                    selectedId: id,
                    paneBuilder: (_) => BookingDoneScreen(
                      facilityId: id,
                      bookingId: state.pathParameters['bookingId']!,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
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
    subRoutes: [
      // `/profile/verification`: needs an account (contracts/routes.md).
      GatedRoute(
        path: 'verification',
        name: AppRouteNames.profileVerification,
        access: const RouteAccess(requiresAccount: true),
        builder: (context, state) => const VerificationRequestScreen(),
      ),
    ],
  ),
];

/// `summary` and `checkout` need a whole selection; without one the person is
/// sent to the schedule with whatever is valid (contracts/routes.md).
String? _needsCompleteSelection(BuildContext context, GoRouterState state) {
  final selection = ScheduleSelection.fromQuery(state.uri.queryParameters);
  if (selection.isComplete) return null;
  return AppPaths.facilitySchedule(state.pathParameters['id']!, selection);
}
