import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint/core/l10n/role_labels.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/option_group.dart';
import 'package:sprint/features/identity/domain/role_assignment.dart';
import 'package:sprint/features/identity/domain/user.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Reviewer-only: act as any seeded user, or as a guest, without signing in
/// (FR-031). Hidden from release builds with `HIDE_DEMO_TOOLS`.
class DemoUserSwitcher extends ConsumerWidget {
  const DemoUserSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(currentSessionProvider);
    final users = ref.watch(_usersProvider).value ?? const <User>[];

    String labelOf(User u) {
      final staff = ref.watch(_rolesProvider(u.id)).value ?? const <RoleAssignment>[];
      final roles = {
        for (final a in staff)
          if (a.role != Role.booker) a.role,
      };
      final suffix = roles.isEmpty
          ? roleLabel(l10n, Role.booker)
          : roles.map((r) => roleLabel(l10n, r)).join(' · ');
      return '${u.name} — $suffix';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.demoUserNote,
          style: context.text.caption.copyWith(color: context.colors.inkMuted),
        ),
        const SizedBox(height: SprintSpacing.space2),
        OptionGroup<String>(
          title: l10n.demoUserTitle,
          selected: session.user?.id ?? '',
          onSelected: (id) => ref
              .read(sessionProvider.notifier)
              .selectUser(id.isEmpty ? null : id),
          options: [
            ('', l10n.demoGuest),
            for (final u in users) (u.id, labelOf(u)),
          ],
        ),
      ],
    );
  }
}

final _usersProvider = FutureProvider<List<User>>(
  (ref) => ref.watch(identityRepositoryProvider).users(),
);

final _rolesProvider = FutureProvider.family<List<RoleAssignment>, String>(
  (ref, id) => ref.watch(identityRepositoryProvider).roleAssignments(id),
);
