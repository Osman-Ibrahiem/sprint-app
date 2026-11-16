import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/features/identity/domain/app_section.dart';
import 'package:sprint/features/verification/presentation/sheet_upload_screen.dart';
import 'package:sprint/features/verification/presentation/verification_queue_screen.dart';
import 'package:sprint/features/verification/presentation/verification_request_detail.dart';

const RouteAccess _reviewerAccess = RouteAccess(
  requiredSection: AppSection.verification,
);

/// The Verification destination for `VERIFIER` and `SUPER_ADMIN`
/// (FR-031, research R10), registered in `destinationRegistry`. Its detail
/// routes are `GatedRoute`s with the same access, so a request outside the
/// reviewer's scope or a missing role gets `NoAccessScreen` (FR-032).
final ShellDestination verificationDestination = ShellDestination(
  name: AppRouteNames.verification,
  path: AppPaths.verification,
  icon: PhosphorIconsRegular.sealCheck,
  selectedIcon: PhosphorIconsFill.sealCheck,
  label: (l) => l.verifRevSection,
  builder: VerificationQueueScreen.new,
  access: _reviewerAccess,
  routes: [
    // `upload` before `:id`, so it is never read as a request id.
    GatedRoute(
      path: 'upload',
      name: AppRouteNames.verificationUpload,
      access: _reviewerAccess,
      builder: (context, state) => const SheetUploadScreen(),
    ),
    GatedRoute(
      path: ':id',
      name: AppRouteNames.verificationDetail,
      access: _reviewerAccess,
      builder: (context, state) =>
          VerificationDetailRoute(id: state.pathParameters['id']!),
    ),
  ],
);
