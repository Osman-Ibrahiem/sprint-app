import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/app/shell/placeholders/sign_in_prompt.dart';
import 'package:sprint/app/shell/root_header.dart';
import 'package:sprint/core/l10n/locale_notifier.dart';
import 'package:sprint/core/l10n/ltr_isolate.dart';
import 'package:sprint/core/l10n/role_labels.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/theme/theme_mode_notifier.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/avatar/avatar.dart';
import 'package:sprint/core/widgets/settings_row/settings_row.dart';
import 'package:sprint/features/account/presentation/pickers.dart';
import 'package:sprint/features/account/presentation/sign_out_flow.dart';
import 'package:sprint/features/auth/domain/masking.dart';
import 'package:sprint/features/auth/presentation/account_card.dart';
import 'package:sprint/features/identity/domain/role_assignment.dart';
import 'package:sprint/features/identity/presentation/profile_photo_provider.dart';
import 'package:sprint/features/notifications/data/notification_permission_store.dart';
import 'package:sprint/features/notifications/domain/notification_permission.dart';
import 'package:sprint/features/notifications/presentation/permission_dialog.dart';
import 'package:sprint/features/verification/presentation/verification_notice.dart';
import 'package:sprint/features/verification/presentation/verification_slot.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// "حسابي" (US-14, FR-MYB-03): the person, the verification state, and the
/// settings rows. A guest gets the sign-in card with language and appearance.
/// No national ID or ID photo is shown anywhere here (NFR-06).
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  static const personalKey = ValueKey<String>('account-personal');
  static const notificationsKey = ValueKey<String>('account-notifications');

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final session = ref.watch(currentSessionProvider);
    final user = session.user;
    final locale = ref.watch(localeProvider);
    final mode = ref.watch(themeModeProvider);
    final permission = ref.watch(notificationPermissionStoreProvider).read();

    final modeLabel = switch (mode) {
      ThemeMode.system => l10n.appearanceSystem,
      ThemeMode.light => l10n.appearanceLight,
      ThemeMode.dark => l10n.appearanceDark,
    };

    Widget card(List<Widget> rows) => Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: SprintRadius.lgBorder,
      ),
      child: Column(children: rows),
    );

    final photo = user?.avatarId == null
        ? null
        : ref.watch(profilePhotoProvider(user!.id)).value;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(
          SprintSpacing.space4,
          SprintSpacing.space4,
          SprintSpacing.space4,
          SprintExtras.screenBottomPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RootHeader(
              title: Text(l10n.accountTitle, style: context.text.titleLg),
            ),
            const SizedBox(height: SprintSpacing.space5),
            if (user == null)
              SignInPrompt(reason: l10n.gateReasonProfile)
            else ...[
              Container(
                padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: SprintRadius.lgBorder,
                ),
                child: Row(
                  children: [
                    Avatar(name: user.name, photo: photo),
                    const SizedBox(width: SprintSpacing.space4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name, style: context.text.headline),
                          LtrIsolate(
                            child: Text(
                              maskPhone(user.phone),
                              style: context.text.caption.copyWith(
                                color: colors.inkMuted,
                              ),
                            ),
                          ),
                          LtrIsolate(
                            child: Text(
                              maskEmail(user.email),
                              style: context.text.caption.copyWith(
                                color: colors.inkMuted,
                              ),
                            ),
                          ),
                          Text(
                            l10n.profileRoles(
                              {
                                for (final a in session.roles)
                                  if (a.role != Role.booker ||
                                      session.roles.length == 1)
                                    a.role,
                              }.map((r) => roleLabel(l10n, r)).join(' · '),
                            ),
                            style: context.text.caption.copyWith(
                              color: colors.inkMuted,
                            ),
                          ),
                          Text(
                            l10n.profileTier(tierLabel(l10n, session.tier)),
                            style: context.text.caption.copyWith(
                              color: colors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SprintSpacing.space3),
              const VerificationNotice(),
              VerificationSlot(session: session, showNationalId: false),
              const SizedBox(height: SprintSpacing.space4),
            ],
            card([
              if (user != null)
                SettingsRow(
                  key: AccountScreen.personalKey,
                  label: l10n.accountPersonalData,
                  icon: PhosphorIconsRegular.user,
                  onTap: () => context.go(AppPaths.profileEdit),
                ),
              Builder(
                builder: (anchor) => SettingsRow(
                  label: l10n.languageTitle,
                  type: SettingsRowType.value,
                  value: locale.languageCode == 'ar'
                      ? l10n.languageAr
                      : l10n.languageEn,
                  icon: PhosphorIconsRegular.globe,
                  onTap: () => pickLanguage(anchor, ref),
                ),
              ),
              Builder(
                builder: (anchor) => SettingsRow(
                  label: l10n.appearanceTitle,
                  type: SettingsRowType.value,
                  value: modeLabel,
                  icon: PhosphorIconsRegular.moon,
                  onTap: () => pickAppearance(anchor, ref),
                ),
              ),
              if (user != null)
                SettingsRow(
                  key: AccountScreen.notificationsKey,
                  label: l10n.accountNotifications,
                  type: SettingsRowType.value,
                  value: permission == NotificationPermission.granted
                      ? l10n.accountNotificationsOn
                      : l10n.accountNotificationsOff,
                  icon: PhosphorIconsRegular.bell,
                  onTap: () async {
                    await askNotificationPermission(context, ref);
                    if (mounted) setState(() {});
                  },
                ),
              SettingsRow(
                label: l10n.demoEntry,
                icon: PhosphorIconsRegular.flask,
                onTap: () => context.push(AppPaths.demo),
              ),
            ]),
            if (user != null) ...[
              const SizedBox(height: SprintSpacing.space4),
              card([
                SettingsRow(
                  key: AccountCard.signOutKey,
                  label: l10n.signOutConfirm,
                  type: SettingsRowType.destructive,
                  onTap: () => confirmSignOut(context, ref),
                ),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}
