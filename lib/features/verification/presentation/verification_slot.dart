import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/l10n/ltr_isolate.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/features/verification/domain/national_id.dart';
import 'package:sprint/features/verification/domain/verification_state.dart';
import 'package:sprint/features/verification/presentation/verification_status_badge.dart';
import 'package:sprint/features/verification/presentation/verification_texts.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The verification block of the Profile account card (FR-029): the status
/// as word and icon, what it means (expiry date or the rejection reason), the
/// national ID masked to its last four digits, and the next action, which
/// opens the request screen (FR-030).
class VerificationSlot extends ConsumerWidget {
  const VerificationSlot({
    required this.session,
    this.showNationalId = true,
    super.key,
  });

  final Session session;

  /// The masked national ID line; the account screen turns it off (FR-023,
  /// NFR-06). The old account card and the review screens keep it.
  final bool showNationalId;

  static const actionKey = ValueKey<String>('verification-action');
  static const bodyKey = ValueKey<String>('verification-body');
  static const reasonKey = ValueKey<String>('verification-reason');
  static const nationalIdKey = ValueKey<String>('verification-national-id');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final format = SprintFormat.of(context);
    final now = ref.watch(appClockProvider).now();
    final v = session.verification;
    final state = verificationStateOf(v, now);
    final expires = v?.expiresAt;
    final nationalId = session.user?.nationalId ?? v?.nationalId;

    final body = switch (state) {
      VerificationState.none => l10n.verifNoneBody,
      VerificationState.underReview => l10n.verifPendingBody,
      VerificationState.approved =>
        expires == null
            ? l10n.statusVerified
            : l10n.verifApprovedUntil(format.dateWithYear(expires)),
      VerificationState.rejected => l10n.verifRejectedBody,
      VerificationState.expired =>
        expires == null
            ? l10n.verifStatusExpired
            : l10n.verifExpiredBody(format.dateWithYear(expires)),
    };
    final (actionLabel, actionVariant) = switch (state.nextAction) {
      VerificationNextAction.request => (
        l10n.verifActionRequest,
        SprintButtonVariant.tonal,
      ),
      VerificationNextAction.renew => (
        l10n.verifActionRenew,
        SprintButtonVariant.tonal,
      ),
      VerificationNextAction.requestAgain => (
        l10n.verifActionAgain,
        SprintButtonVariant.tonal,
      ),
      VerificationNextAction.wait ||
      VerificationNextAction.none => (null, SprintButtonVariant.tonal),
    };
    final reason = state == VerificationState.rejected ? v?.reason : null;

    return Semantics(
      container: true,
      label: l10n.verifCardSpoken(verificationStateWord(l10n, state)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l10n.verifCardTitle, style: context.text.headline),
              ),
              VerificationStatusBadge(state: state),
            ],
          ),
          const SizedBox(height: SprintSpacing.space2),
          Text(body, key: bodyKey, style: context.text.body),
          if (reason != null && reason.isNotEmpty) ...[
            const SizedBox(height: SprintSpacing.space1),
            Text(
              l10n.verifReasonLabel(verificationReasonText(l10n, reason)),
              key: reasonKey,
              style: context.text.body.copyWith(color: colors.ink),
            ),
          ],
          if (showNationalId &&
              nationalId != null &&
              nationalId.isNotEmpty) ...[
            const SizedBox(height: SprintSpacing.space1),
            Text(
              l10n.verifNationalIdMasked(
                ltrIsolate(maskNationalId(nationalId)),
              ),
              key: nationalIdKey,
              style: context.text.caption.copyWith(color: colors.inkMuted),
            ),
          ],
          if (state == VerificationState.underReview) ...[
            const SizedBox(height: SprintSpacing.space2),
            Text(
              l10n.verifActionWait,
              style: context.text.label.copyWith(color: colors.inkMuted),
            ),
          ],
          if (actionLabel != null) ...[
            const SizedBox(height: SprintSpacing.space3),
            SprintButton(
              key: actionKey,
              label: actionLabel,
              variant: actionVariant,
              onPressed: () => context.push(AppPaths.profileVerification),
            ),
          ],
        ],
      ),
    );
  }
}
