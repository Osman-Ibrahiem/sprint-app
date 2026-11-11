import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprint/core/storage/preferences_provider.dart';

part 'theme_mode_notifier.g.dart';

/// Theme mode: follows the device unless the user picks light or dark.
/// Persisted; any storage failure falls back to the default (FR-010).
@Riverpod(keepAlive: true)
class ThemeModeNotifier extends _$ThemeModeNotifier {
  static const _key = 'themeMode';

  @override
  ThemeMode build() {
    try {
      final stored = ref.read(preferencesProvider)?.getString(_key);
      return ThemeMode.values.firstWhere(
        (m) => m.name == stored,
        orElse: () => ThemeMode.system,
      );
    } on Object {
      return ThemeMode.system;
    }
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    try {
      await ref.read(preferencesProvider)?.setString(_key, mode.name);
    } on Object {
      // Keep the in-memory choice; it just won't survive a relaunch.
    }
  }
}
