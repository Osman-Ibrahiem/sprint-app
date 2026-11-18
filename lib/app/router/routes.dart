import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/app/shell/placeholders/bookings_placeholder.dart';
import 'package:sprint/app/shell/placeholders/no_access_screen.dart';
import 'package:sprint/app/shell/placeholders/pending_screen.dart';
import 'package:sprint/app/shell/placeholders/profile_placeholder.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';
import 'package:sprint/features/booking/presentation/checkout/checkout_screen.dart';
import 'package:sprint/features/booking/presentation/confirmed/booking_confirmed_screen.dart';
import 'package:sprint/features/booking/presentation/widgets/booking_owner_gate.dart';
import 'package:sprint/features/booking/presentation/schedule/schedule_screen.dart';
import 'package:sprint/features/booking/presentation/summary/booking_summary_screen.dart';
import 'package:sprint/features/catalogue/domain/facility_link.dart';
import 'package:sprint/features/catalogue/presentation/facilities/facilities_screen.dart';
import 'package:sprint/features/catalogue/presentation/facilities/facility_not_found.dart';
import 'package:sprint/features/catalogue/presentation/home/home_screen.dart';
import 'package:sprint/features/identity/domain/app_section.dart';
import 'package:sprint/features/payments/presentation/receipt/receipt_screen.dart';
import 'package:sprint/features/verification/presentation/verification_request_screen.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Route paths. Screens never build path strings by hand.
abstract final class AppPaths {
  static const root = '/';
  static const home = '/home';
  static const facilities = '/facilities';
  static const bookings = '/bookings';
  static const notifications = '/notifications';
  static const profile = '/profile';
  static const profileEdit = '/profile/edit';
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

  /// 005's checkout address, kept as a redirect to the summary: a booking now
  /// exists before payment, so checkout is addressed by its booking id
  /// ([bookingCheckoutFor]).
  static String bookingCheckout(String id, ScheduleSelection selection) =>
      _withQuery(
        '${FacilityLink.path(id)}/schedule/checkout',
        selection.toQuery(),
      );

  /// Checkout of one booking: holding, processing, failed, expired and the
  /// rest, all from the booking and its payment (feature 006).
  static String bookingCheckoutFor(String id, String bookingId) =>
      '${FacilityLink.path(id)}/schedule/checkout/$bookingId';

  /// 005's success address, kept as a redirect to [bookingConfirmed].
  static String bookingDone(String id, String bookingId) =>
      '${FacilityLink.path(id)}/schedule/done/$bookingId';

  /// The simulated provider page (fake provider only), outside the shell.
  static const fakeGatewayPattern = '/pay/sandbox/:sessionId';
  static String fakeGateway(String sessionId) =>
      '/pay/sandbox/${Uri.encodeComponent(sessionId)}';

  /// The confirmation ticket and the receipt, under the bookings destination.
  static String bookingConfirmed(String bookingId) =>
      '$bookings/$bookingId/confirmed';
  static String bookingDetails(String bookingId) => '$bookings/$bookingId';
  static String bookingCancelled(String bookingId) =>
      '$bookings/$bookingId/cancelled';
  static String bookingReceipt(String bookingId) =>
      '$bookings/$bookingId/receipt';

  /// The payment flow's own screens (checkout, the confirmation ticket and the
  /// receipt). On compact they hide the tab bar, as the design does, so the
  /// only ways out are the screen's own (BR-47).
  static bool isPaymentFlow(String path) =>
      path.contains('/schedule/checkout/') ||
      RegExp(r'^/bookings/[^/]+/(confirmed|receipt)$').hasMatch(path);

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
  static const notifications = 'notifications';
  static const bookingDetails = 'bookingDetails';
  static const bookingCancelled = 'bookingCancelled';
  static const profileEdit = 'profileEdit';
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
  static const bookingCheckoutLegacy = 'bookingCheckoutLegacy';
  static const fakeGateway = 'fakeGateway';
  static const bookingConfirmed = 'bookingConfirmed';
  static const bookingReceipt = 'bookingReceipt';
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
              // 005's `checkout?<selection>` now lands on the summary: a
              // booking exists before payment, so checkout is addressed by
              // its id (feature 006, contracts/routes.md).
              GatedRoute(
                path: 'checkout',
                name: AppRouteNames.bookingCheckoutLegacy,
                access: const RouteAccess(requiresAccount: true),
                redirect: (context, state) => _withSameQuery(
                  '${FacilityLink.path(state.pathParameters['id']!)}/schedule/summary',
                  state,
                ),
                builder: (context, state) => const SizedBox.shrink(),
              ),
              GatedRoute(
                path: 'done/:bookingId',
                name: AppRouteNames.bookingDone,
                access: const RouteAccess(requiresAccount: true),
                redirect: (context, state) => AppPaths.bookingConfirmed(
                  state.pathParameters['bookingId']!,
                ),
                builder: (context, state) => const SizedBox.shrink(),
              ),
            ],
          ),
          // Checkout is a sibling of the schedule, not a child: a child would
          // keep the schedule alive beneath it, reacting to the booking's own
          // Hold (the place looks taken) and rewriting the address.
          GatedRoute(
            path: 'schedule/checkout/:bookingId',
            name: AppRouteNames.bookingCheckout,
            access: const RouteAccess(requiresAccount: true),
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              final bookingId = state.pathParameters['bookingId']!;
              // The whole content area, not the facility pane: the
              // two-column layout needs the width (design-pack
              // adaptive.md); compact is full screen either way.
              return BookingOwnerGate(
                bookingId: bookingId,
                child: CheckoutScreen(facilityId: id, bookingId: bookingId),
              );
            },
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
    subRoutes: [
      // Details and the result of a cancel (feature 007). The owner only.
      GatedRoute(
        path: ':bookingId',
        name: AppRouteNames.bookingDetails,
        access: const RouteAccess(requiresAccount: true),
        builder: (context, state) {
          final id = state.pathParameters['bookingId']!;
          return BookingOwnerGate(
            bookingId: id,
            child: PendingScreen(title: id),
          );
        },
        routes: [
          GatedRoute(
            path: 'cancelled',
            name: AppRouteNames.bookingCancelled,
            access: const RouteAccess(requiresAccount: true),
            builder: (context, state) {
              final id = state.pathParameters['bookingId']!;
              return BookingOwnerGate(
                bookingId: id,
                child: PendingScreen(title: id),
              );
            },
          ),
        ],
      ),
      // The confirmation ticket and the receipt need an account; another
      // person's booking shows `NoAccessScreen` (contracts/routes.md).
      GatedRoute(
        path: ':bookingId/confirmed',
        name: AppRouteNames.bookingConfirmed,
        access: const RouteAccess(requiresAccount: true),
        builder: (context, state) {
          final id = state.pathParameters['bookingId']!;
          return BookingOwnerGate(
            bookingId: id,
            child: BookingConfirmedScreen(bookingId: id),
          );
        },
      ),
      GatedRoute(
        path: ':bookingId/receipt',
        name: AppRouteNames.bookingReceipt,
        access: const RouteAccess(requiresAccount: true),
        builder: (context, state) {
          final id = state.pathParameters['bookingId']!;
          return BookingOwnerGate(
            bookingId: id,
            child: ReceiptScreen(bookingId: id),
          );
        },
      ),
    ],
  ),
  ShellDestination(
    name: AppRouteNames.notifications,
    path: AppPaths.notifications,
    icon: PhosphorIconsRegular.bell,
    selectedIcon: PhosphorIconsFill.bell,
    label: (l) => l.navNotifications,
    builder: () => const PendingScreen(title: 'notifications'),
    access: const RouteAccess(requiresAccount: true),
  ),
  ShellDestination(
    name: AppRouteNames.profile,
    path: AppPaths.profile,
    icon: PhosphorIconsRegular.user,
    selectedIcon: PhosphorIconsFill.user,
    label: (l) => l.navProfile,
    builder: ProfilePlaceholder.new,
    subRoutes: [
      GatedRoute(
        path: 'edit',
        name: AppRouteNames.profileEdit,
        access: const RouteAccess(requiresAccount: true),
        builder: (context, state) => const PendingScreen(title: 'edit'),
      ),
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

/// [path] with the query of [state] unchanged.
String _withSameQuery(String path, GoRouterState state) => Uri(
  path: path,
  queryParameters: state.uri.queryParameters.isEmpty
      ? null
      : state.uri.queryParameters,
).toString();

/// `summary` needs a whole selection; without one the person is
/// sent to the schedule with whatever is valid (contracts/routes.md).
String? _needsCompleteSelection(BuildContext context, GoRouterState state) {
  final selection = ScheduleSelection.fromQuery(state.uri.queryParameters);
  if (selection.isComplete) return null;
  return AppPaths.facilitySchedule(state.pathParameters['id']!, selection);
}
