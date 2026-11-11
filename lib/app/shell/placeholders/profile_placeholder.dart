import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/widgets/option_group.dart';
import 'package:sprint/app/shell/placeholders/placeholder_page.dart';
import 'package:sprint/app/shell/placeholders/sign_in_prompt.dart';
import 'package:sprint/core/a11y/focusable_tap.dart';
import 'package:sprint/core/l10n/directional_icon.dart';
import 'package:sprint/core/l10n/locale_notifier.dart';
import 'package:sprint/core/theme/theme_mode_notifier.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Profile placeholder: the guest sign-in prompt, plus Appearance and
/// Language, which work for everyone, and the link to the reviewer demo.
class ProfilePlaceholder extends ConsumerWidget {
  const ProfilePlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final mode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return PlaceholderPage(
      title: l10n.navProfile,
      showNote: false,
      blocks: 0,
      leading: [
        const SizedBox(height: SprintSpacing.space4),
        const SignInPrompt(),
        const SizedBox(height: SprintSpacing.space6),
        OptionGroup<ThemeMode>(
          title: l10n.appearanceTitle,
          selected: mode,
          onSelected: (m) => ref.read(themeModeProvider.notifier).set(m),
          options: [
            (ThemeMode.system, l10n.appearanceSystem),
            (ThemeMode.light, l10n.appearanceLight),
            (ThemeMode.dark, l10n.appearanceDark),
          ],
        ),
        const SizedBox(height: SprintSpacing.space6),
        OptionGroup<String>(
          title: l10n.languageTitle,
          selected: locale.languageCode,
          onSelected: (code) =>
              ref.read(localeProvider.notifier).set(Locale(code)),
          options: [
            ('ar', l10n.languageAr),
            ('en', l10n.languageEn),
          ],
        ),
        const SizedBox(height: SprintSpacing.space6),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: SprintRadius.lgBorder,
            border: Border.all(color: colors.line),
          ),
          child: FocusableTap(
            label: l10n.demoEntry,
            selected: false,
            onTap: () => context.push(AppPaths.demo),
            builder: (context, hovered) => Container(
              constraints:
                  const BoxConstraints(minHeight: SprintSize.controlHeight),
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: SprintSpacing.space4,
                vertical: SprintSpacing.space2,
              ),
              decoration: BoxDecoration(
                color: hovered ? colors.surfaceSunken : Colors.transparent,
                borderRadius: SprintRadius.lgBorder,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(l10n.demoEntry, style: context.text.body),
                  ),
                  DirectionalIcon(
                    Icons.chevron_right,
                    size: SprintSize.iconMd,
                    color: colors.inkMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
