import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint/core/adaptive/adaptive_sheet.dart';
import 'package:sprint/core/l10n/locale_notifier.dart';
import 'package:sprint/core/theme/theme_mode_notifier.dart';
import 'package:sprint/core/widgets/popover/popover.dart';
import 'package:sprint/core/window/window_size.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Language and appearance choices: a sheet on compact, a popover anchored to
/// the row from the medium class (FR-MYB-03). The choice applies at once.
Future<void> pickLanguage(BuildContext anchor, WidgetRef ref) async {
  final l10n = AppLocalizations.of(anchor);
  final current = ref.read(localeProvider).languageCode;
  final choice = await _choose<String>(
    anchor,
    title: l10n.languageTitle,
    options: [
      ('ar', l10n.languageAr, current == 'ar'),
      ('en', l10n.languageEn, current == 'en'),
    ],
  );
  if (choice != null) {
    await ref.read(localeProvider.notifier).set(Locale(choice));
  }
}

Future<void> pickAppearance(BuildContext anchor, WidgetRef ref) async {
  final l10n = AppLocalizations.of(anchor);
  final current = ref.read(themeModeProvider);
  final choice = await _choose<ThemeMode>(
    anchor,
    title: l10n.appearanceTitle,
    options: [
      (ThemeMode.system, l10n.appearanceSystem, current == ThemeMode.system),
      (ThemeMode.light, l10n.appearanceLight, current == ThemeMode.light),
      (ThemeMode.dark, l10n.appearanceDark, current == ThemeMode.dark),
    ],
  );
  if (choice != null) {
    await ref.read(themeModeProvider.notifier).set(choice);
  }
}

Future<T?> _choose<T>(
  BuildContext anchor, {
  required String title,
  required List<(T, String, bool)> options,
}) {
  if (WindowSize.of(anchor).isCompact) {
    return showSprintSheet<T>(
      context: anchor,
      title: title,
      cancelLabel: AppLocalizations.of(anchor).commonCancel,
      actions: [
        for (final o in options) SprintSheetAction<T>(label: o.$2, value: o.$1),
      ],
    );
  }
  return showSprintPopover<T>(
    anchorContext: anchor,
    options: [
      for (final o in options)
        PopoverOption<T>(value: o.$1, label: o.$2, selected: o.$3),
    ],
  );
}
