import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint/core/adaptive/adaptive_dialog.dart';
import 'package:sprint/core/l10n/ltr_isolate.dart';
import 'package:sprint/core/l10n/role_labels.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/features/auth/domain/masking.dart';
import 'package:sprint/features/identity/domain/role_assignment.dart';
import 'package:sprint/features/verification/presentation/verification_notice.dart';
import 'package:sprint/features/verification/presentation/verification_slot.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Profile's account block for a signed-in person: name, masked phone and
/// email in LTR isolates, roles, tier, and sign out behind a confirmation
/// (FR-016, FR-019, US-03), and the verification slot with its status and next
/// action (FR-029, US-04).
class AccountCard extends ConsumerWidget {
  const AccountCard({required this.session, super.key});

  final Session session;

  static const signOutKey = ValueKey<String>('account-sign-out');

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showSprintDialog<bool>(
      context: context,
      title: l10n.signOutTitle,
      message: l10n.signOutBody,
      actions: [
        SprintDialogAction(label: l10n.signOutKeep, value: false),
        SprintDialogAction(
          label: l10n.signOutConfirm,
          value: true,
          isDestructive: true,
          isDefault: true,
        ),
      ],
    );
    if (confirmed ?? false) {
      await ref.read(sessionProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final user = session.user!;
    final roles = {
      for (final a in session.roles)
        if (a.role != Role.booker || session.roles.length == 1) a.role,
    };
    final tier = tierLabel(l10n, session.tier);
    return Container(
      padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: SprintRadius.lgBorder,
        border: Border.all(color: colors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            container: true,
            label: l10n.accountCardSpoken(user.name, tier),
            excludeSemantics: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.person_outline,
                  size: SprintSize.iconLg,
                  color: colors.ink,
                ),
                const SizedBox(width: SprintSpacing.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: context.text.headline),
                      const SizedBox(height: SprintSpacing.space1),
                      LtrIsolate(
                        child: Text(
                          maskPhone(user.phone),
                          style: context.text.body,
                        ),
                      ),
                      LtrIsolate(
                        child: Text(
                          maskEmail(user.email),
                          style: context.text.body,
                        ),
                      ),
                      Text(
                        l10n.profileRoles(
                          roles.map((r) => roleLabel(l10n, r)).join(' · '),
                        ),
                        style: context.text.body,
                      ),
                      Text(l10n.profileTier(tier), style: context.text.body),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SprintSpacing.space4),
          Divider(height: SprintExtras.hairlineWidth, color: colors.line),
          const SizedBox(height: SprintSpacing.space4),
          const VerificationNotice(),
          VerificationSlot(session: session),
          const SizedBox(height: SprintSpacing.space4),
          SprintButton(
            key: signOutKey,
            label: l10n.signOutConfirm,
            variant: SprintButtonVariant.secondary,
            onPressed: () => _confirmSignOut(context, ref),
          ),
        ],
      ),
    );
  }
}
