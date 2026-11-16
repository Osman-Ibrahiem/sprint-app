import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/app/shell/placeholders/no_access_screen.dart';
import 'package:sprint/core/adaptive/adaptive_app_bar.dart';
import 'package:sprint/core/adaptive/adaptive_dialog.dart';
import 'package:sprint/core/l10n/ltr_isolate.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/motion/skeleton.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/core/window/window_size.dart';
import 'package:sprint/features/identity/domain/verification.dart';
import 'package:sprint/features/verification/data/in_memory_verification_repository.dart'
    show minRejectReasonLength;
import 'package:sprint/features/verification/domain/verification_state.dart';
import 'package:sprint/features/verification/presentation/verification_providers.dart';
import 'package:sprint/features/verification/presentation/verification_queue_screen.dart';
import 'package:sprint/features/verification/presentation/verification_request_screen.dart';
import 'package:sprint/features/verification/presentation/verification_status_badge.dart';
import 'package:sprint/features/verification/presentation/verification_texts.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// `/verification/:id`. On expanded windows the request opens beside the list
/// (the queue with this request selected); on compact and medium it is its
/// own page, so the back gesture follows the platform (FR-039).
class VerificationDetailRoute extends StatelessWidget {
  const VerificationDetailRoute({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context) => WindowSize.of(context).isWide
      ? VerificationQueueScreen(selectedId: id)
      : VerificationRequestDetail(id: id);
}

/// One request for a reviewer: the person's details, the full national ID in
/// an LTR isolate and the ID card photo (visible only here and only to
/// `VERIFIER` and `SUPER_ADMIN` in scope, FR-033, NFR-06), with approve and
/// reject (FR-034, FR-035). A request outside the reviewer's scope, or any
/// request for someone without the role, shows `NoAccessScreen` as a page
/// and a short notice in a pane (FR-032).
class VerificationRequestDetail extends ConsumerStatefulWidget {
  const VerificationRequestDetail({
    required this.id,
    this.embedded = false,
    super.key,
  });

  final String id;

  /// In the side pane of the expanded layout: no app bar of its own.
  final bool embedded;

  static const nationalIdKey = ValueKey<String>('review-national-id');
  static const photoKey = ValueKey<String>('review-photo');
  static const approveKey = ValueKey<String>('review-approve');
  static const rejectKey = ValueKey<String>('review-reject');
  static const messageKey = ValueKey<String>('review-message');
  static const decidedKey = ValueKey<String>('review-decided');

  @override
  ConsumerState<VerificationRequestDetail> createState() =>
      _VerificationRequestDetailState();
}

class _VerificationRequestDetailState
    extends ConsumerState<VerificationRequestDetail> {
  bool _busy = false;
  String? _message;

  Future<void> _approve(String reviewerId) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    final result = await ref
        .read(verificationRepositoryProvider)
        .approve(reviewerId, widget.id);
    _finish(result);
  }

  Future<void> _reject(String reviewerId) async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    final reason = await showSprintInputDialog(
      context: context,
      title: l10n.verifRevRejectTitle,
      fieldLabel: l10n.verifRevReasonLabel,
      helper: l10n.verifRevReasonHelper,
      confirmLabel: l10n.verifRevReasonConfirm,
      cancelLabel: l10n.verifRevReasonCancel,
      minLength: minRejectReasonLength,
    );
    if (reason == null || !mounted) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    final result = await ref
        .read(verificationRepositoryProvider)
        .reject(reviewerId, widget.id, reason);
    _finish(result);
  }

  void _finish(Result<Verification> result) {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = false;
      _message = switch (result) {
        Ok() => null,
        Err(:final failure) => switch (failure) {
          AlreadyDecided() => l10n.verifRevAlreadyDecided,
          OwnRequest() => l10n.verifRevOwnRequest,
          _ => l10n.signInUnexpected,
        },
      };
    });
    // The request now reads as decided; refresh it after a refusal too.
    ref.invalidate(verificationRequestProvider(widget.id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final request = ref.watch(verificationRequestProvider(widget.id));
    final reviewerId = ref.watch(reviewerIdProvider);

    Widget frame(Widget body) => widget.embedded
        ? body
        : Scaffold(
            appBar: AdaptiveAppBar(title: l10n.verifRevDetailTitle),
            body: SafeArea(child: body),
          );

    return request.when(
      loading: () => frame(
        const Padding(
          padding: EdgeInsetsDirectional.all(SprintSpacing.space4),
          child: Skeleton(height: SprintSize.controlHeight * 4),
        ),
      ),
      error: (_, _) => frame(Text(l10n.signInUnexpected)),
      data: (result) => switch (result) {
        Err() =>
          widget.embedded ? _PaneNoAccess(l10n: l10n) : const NoAccessScreen(),
        Ok(:final value) => frame(
          _DetailBody(
            verification: value,
            reviewerId: reviewerId,
            busy: _busy,
            message: _message,
            onApprove: () => _approve(reviewerId!),
            onReject: () => _reject(reviewerId!),
          ),
        ),
      },
    );
  }
}

class _PaneNoAccess extends StatelessWidget {
  const _PaneNoAccess({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsetsDirectional.all(SprintSpacing.space6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_outline,
            size: SprintSize.iconLg,
            color: context.colors.inkMuted,
          ),
          const SizedBox(height: SprintSpacing.space3),
          Text(l10n.noAccessTitle, style: context.text.title),
          Text(l10n.noAccessBody, style: context.text.body),
        ],
      ),
    ),
  );
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({
    required this.verification,
    required this.reviewerId,
    required this.busy,
    required this.message,
    required this.onApprove,
    required this.onReject,
  });

  final Verification verification;
  final String? reviewerId;
  final bool busy;
  final String? message;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final format = SprintFormat.of(context);
    final v = verification;
    final person = ref.watch(verificationPersonProvider(v.userId)).value;
    final units = ref.watch(owningUnitsProvider).value ?? const [];
    final unit = units.where((u) => u.id == v.owningUnitId).firstOrNull?.name;
    final now = ref.watch(appClockProvider).now();
    final pending = v.status == VerificationStatus.pending;
    final own = v.userId == reviewerId;

    Widget row(String label, Widget value) => Padding(
      padding: const EdgeInsetsDirectional.only(bottom: SprintSpacing.space3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.text.caption.copyWith(color: colors.inkMuted),
          ),
          value,
        ],
      ),
    );

    final decided = switch (v.status) {
      VerificationStatus.approved => l10n.verifRevDecidedApproved,
      VerificationStatus.rejected => l10n.verifRevDecidedRejected,
      VerificationStatus.pending => null,
    };

    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: SprintExtras.authFormMaxWidth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      person?.name ?? '',
                      style: context.text.titleLg,
                    ),
                  ),
                  VerificationStatusBadge(state: verificationStateOf(v, now)),
                ],
              ),
              const SizedBox(height: SprintSpacing.space4),
              row(
                l10n.verifRevType,
                Text(
                  verificationTypeLabel(l10n, v.type),
                  style: context.text.body,
                ),
              ),
              row(
                l10n.verifRevCode,
                LtrIsolate(child: Text(v.code, style: context.text.body)),
              ),
              if (unit != null)
                row(l10n.verifRevUnit, Text(unit, style: context.text.body)),
              row(
                l10n.verifRevSubmitted,
                Text(
                  '${format.dateWithYear(v.submittedAt)} · '
                  '${format.time(v.submittedAt)}',
                  style: context.text.body,
                ),
              ),
              row(
                l10n.verifRevNationalId,
                LtrIsolate(
                  child: Text(
                    v.nationalId,
                    key: VerificationRequestDetail.nationalIdKey,
                    style: context.text.headline,
                  ),
                ),
              ),
              row(
                l10n.verifRevPhoto,
                _Photo(photoId: v.photoId, name: person?.name ?? ''),
              ),
              if (decided != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    bottom: SprintSpacing.space3,
                  ),
                  child: Semantics(
                    liveRegion: true,
                    container: true,
                    child: Text(
                      decided,
                      key: VerificationRequestDetail.decidedKey,
                      style: context.text.body,
                    ),
                  ),
                ),
              if (v.status == VerificationStatus.rejected &&
                  (v.reason ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    bottom: SprintSpacing.space3,
                  ),
                  child: Text(
                    l10n.verifReasonLabel(
                      verificationReasonText(l10n, v.reason!),
                    ),
                    style: context.text.body,
                  ),
                ),
              if (own)
                Text(
                  l10n.verifRevOwnRequest,
                  style: context.text.body.copyWith(color: colors.inkMuted),
                ),
              if (message != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    bottom: SprintSpacing.space3,
                  ),
                  child: Semantics(
                    liveRegion: true,
                    container: true,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: SprintSize.iconMd,
                          color: colors.danger,
                        ),
                        const SizedBox(width: SprintSpacing.space2),
                        Expanded(
                          child: Text(
                            message!,
                            key: VerificationRequestDetail.messageKey,
                            style: context.text.body,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (pending && !own && reviewerId != null) ...[
                SprintButton(
                  key: VerificationRequestDetail.approveKey,
                  label: l10n.verifRevApprove,
                  loading: busy,
                  icon: const SprintButtonIcon(PhosphorIconsRegular.check),
                  onPressed: busy ? null : onApprove,
                ),
                const SizedBox(height: SprintSpacing.space3),
                SprintButton(
                  key: VerificationRequestDetail.rejectKey,
                  label: l10n.verifRevReject,
                  variant: SprintButtonVariant.secondary,
                  icon: const SprintButtonIcon(PhosphorIconsRegular.x),
                  onPressed: busy ? null : onReject,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The ID card photo, loaded only for a reviewer in scope (FR-033).
class _Photo extends ConsumerWidget {
  const _Photo({required this.photoId, required this.name});

  final String? photoId;
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    Widget missing() => Text(
      l10n.verifRevPhotoMissing,
      style: context.text.body.copyWith(color: colors.inkMuted),
    );
    if (photoId == null) return missing();
    final photo = ref.watch(verificationPhotoProvider(photoId!));
    return photo.when(
      loading: () => const Skeleton(height: SprintExtras.idCardPreviewHeight),
      error: (_, _) => missing(),
      data: (result) => switch (result) {
        Err() => missing(),
        Ok(:final value) => Semantics(
          image: true,
          label: l10n.verifRevPhotoSpoken(name),
          child: ClipRRect(
            borderRadius: SprintRadius.mdBorder,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: SprintExtras.idCardPreviewHeight * 2,
              ),
              child: Image.memory(
                value,
                key: VerificationRequestDetail.photoKey,
                fit: BoxFit.contain,
                excludeFromSemantics: true,
                errorBuilder: (_, _, _) => missing(),
              ),
            ),
          ),
        ),
      },
    );
  }
}
