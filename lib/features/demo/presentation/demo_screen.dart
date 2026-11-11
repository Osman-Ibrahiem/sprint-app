import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint/app/shell/placeholders/placeholder_page.dart';
import 'package:sprint/core/adaptive/adaptive_app_bar.dart';
import 'package:sprint/core/l10n/locale_notifier.dart';
import 'package:sprint/core/theme/theme_mode_notifier.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/option_group.dart';
import 'package:sprint/core/window/window_size.dart';
import 'package:sprint/features/demo/presentation/adaptive_controls_demo.dart';
import 'package:sprint/features/demo/presentation/token_gallery.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Reviewer-only screen at `/demo`: token gallery, the five adaptive controls
/// and theme and language switchers (FR-020). Outside the shell and hidden
/// from navigation; reached from Profile. The user switcher and settings
/// inspector join it in US4 (T080).
class DemoScreen extends ConsumerWidget {
  const DemoScreen({super.key});

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
                  onSelected: (v) => ref.read(themeModeProvider.notifier).set(v),
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
                  options: [
                    ('ar', l10n.languageAr),
                    ('en', l10n.languageEn),
                  ],
                ),
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
