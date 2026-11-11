import 'package:flutter/material.dart';
import 'package:sprint/core/l10n/role_labels.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/features/identity/domain/role_assignment.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Who is signed in: name, roles and price tier. Shown on Profile in place of
/// the guest prompt when a reviewer switches user (FR-031).
class UserCard extends StatelessWidget {
  const UserCard({required this.session, super.key});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final roles = {
      for (final a in session.roles)
        if (a.role != Role.booker || session.roles.length == 1) a.role,
    };
    return Container(
      padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: SprintRadius.lgBorder,
        border: Border.all(color: colors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.person_outline, size: SprintSize.iconLg, color: colors.ink),
          const SizedBox(width: SprintSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.user!.name, style: context.text.headline),
                const SizedBox(height: SprintSpacing.space1),
                Text(
                  l10n.profileRoles(
                    roles.map((r) => roleLabel(l10n, r)).join(' · '),
                  ),
                  style: context.text.body,
                ),
                Text(
                  l10n.profileTier(tierLabel(l10n, session.tier)),
                  style: context.text.body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
