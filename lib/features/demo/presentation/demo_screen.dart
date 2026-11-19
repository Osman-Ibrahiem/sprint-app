import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/app/shell/placeholders/placeholder_page.dart';
import 'package:sprint/core/adaptive/adaptive_app_bar.dart';
import 'package:sprint/core/adaptive/adaptive_dialog.dart';
import 'package:sprint/core/l10n/locale_notifier.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/theme/theme_mode_notifier.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/option_group.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/core/window/window_size.dart';
import 'package:sprint/features/demo/demo_flags.dart';
import 'package:sprint/features/demo/presentation/adaptive_controls_demo.dart';
import 'package:sprint/features/demo/presentation/demo_007_section.dart';
import 'package:sprint/features/demo/presentation/demo_payment_section.dart';
import 'package:sprint/features/demo/presentation/demo_user_switcher.dart';
import 'package:sprint/features/demo/presentation/gate_demo.dart';
import 'package:sprint/features/demo/presentation/settings_inspector.dart';
import 'package:sprint/features/demo/presentation/token_gallery.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Reviewer-only screen at `/demo`: token gallery, the five adaptive controls
/// theme and language switchers, the user switcher and the settings inspector
/// (FR-020, FR-031). Outside the shell and hidden from navigation; reached
/// from Profile.
class DemoScreen extends ConsumerWidget {
  const DemoScreen({this.showToolLinks = demoToolsEnabled, super.key});

  /// Reviewer controls (user switcher, settings, gallery) can be compiled out
  /// with `HIDE_DEMO_TOOLS=true`; tests pass this explicitly.
  final bool showToolLinks;

  static const resetKey = ValueKey<String>('demo-reset-data');

  /// "إرجاع الداتا التجريبية" (FR-013b): after a confirmation, clears the saved
  /// data, rebuilds every repository from the seed, signs out and goes home.
  /// Theme and language are separate preferences and stay.
  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final router = GoRouter.of(context);
    final confirmed = await showSprintDialog<bool>(
      context: context,
      title: l10n.demoResetTitle,
      message: l10n.demoResetBody,
      actions: [
        SprintDialogAction(label: l10n.demoResetKeep, value: false),
        SprintDialogAction(
          label: l10n.demoResetConfirm,
          value: true,
          isDestructive: true,
          isDefault: true,
        ),
      ],
    );
    if (!(confirmed ?? false)) return;
    await ref.read(resetDemoDataProvider)();
    // The session listens to the old repositories; start it again on the new.
    ref.invalidate(sessionProvider);
    await ref.read(sessionProvider.future);
    router.go(AppPaths.home);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final m = PlaceholderPage.margin(WindowSize.of(context));
    final mode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AdaptiveAppBar(title: l10n.demoTitle),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: SprintSize.contentMax),
            child: ListView(
              key: const PageStorageKey<String>('demo-screen'),
              padding: EdgeInsetsDirectional.fromSTEB(
                m,
                SprintSpacing.space4,
                m,
                SprintSpacing.space8,
              ),
              children: [
                Text(l10n.demoAppearance, style: context.text.title),
                const SizedBox(height: SprintSpacing.space3),
                OptionGroup<ThemeMode>(
                  title: l10n.appearanceTitle,
                  selected: mode,
                  onSelected: (v) =>
                      ref.read(themeModeProvider.notifier).set(v),
                  options: [
                    (ThemeMode.system, l10n.appearanceSystem),
                    (ThemeMode.light, l10n.appearanceLight),
                    (ThemeMode.dark, l10n.appearanceDark),
                  ],
                ),
                const SizedBox(height: SprintSpacing.space4),
                OptionGroup<String>(
                  title: l10n.languageTitle,
                  selected: locale.languageCode,
                  onSelected: (v) =>
                      ref.read(localeProvider.notifier).set(Locale(v)),
                  options: [('ar', l10n.languageAr), ('en', l10n.languageEn)],
                ),
                if (showToolLinks) ...[
                  const SizedBox(height: SprintSpacing.space6),
                  const DemoUserSwitcher(),
                  const SizedBox(height: SprintSpacing.space6),
                  const SettingsInspector(),
                  const SizedBox(height: SprintSpacing.space6),
                  const DemoPaymentSection(),
                  const SizedBox(height: SprintSpacing.space6),
                  const Demo007Section(),
                  const SizedBox(height: SprintSpacing.space6),
                  const GateDemo(),
                  const SizedBox(height: SprintSpacing.space6),
                  SprintButton(
                    label: l10n.mailboxTitle,
                    variant: SprintButtonVariant.secondary,
                    icon: const SprintButtonIcon(Icons.mail_outline),
                    onPressed: () => context.push(AppPaths.demoMailbox),
                  ),
                  const SizedBox(height: SprintSpacing.space3),
                  SprintButton(
                    label: l10n.galleryOpenFromDemo,
                    variant: SprintButtonVariant.secondary,
                    icon: const SprintButtonIcon(Icons.widgets_outlined),
                    onPressed: () => context.push(AppPaths.demoComponents),
                  ),
                  const SizedBox(height: SprintSpacing.space3),
                  SprintButton(
                    key: resetKey,
                    label: l10n.demoResetButton,
                    variant: SprintButtonVariant.secondary,
                    icon: const SprintButtonIcon(Icons.restart_alt),
                    onPressed: () => _confirmReset(context, ref),
                  ),
                ],
                const SizedBox(height: SprintSpacing.space6),
                Text(l10n.demoControls, style: context.text.title),
                const SizedBox(height: SprintSpacing.space3),
                const AdaptiveControlsDemo(),
                const TokenGallery(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
