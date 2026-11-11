import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprint/core/storage/preferences_provider.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

part 'locale_notifier.g.dart';

/// App language: Arabic by default whatever the system language is, English
/// the second. Persisted; failures fall back to Arabic (FR-013).
@Riverpod(keepAlive: true)
class LocaleNotifier extends _$LocaleNotifier {
  static const _key = 'locale';
  static const _default = Locale('ar');

  static bool _supported(String? code) => AppLocalizations.supportedLocales
      .any((l) => l.languageCode == code);

  @override
  Locale build() {
    try {
      final stored = ref.read(preferencesProvider)?.getString(_key);
      return _supported(stored) ? Locale(stored!) : _default;
    } on Object {
      return _default;
    }
  }

  Future<void> set(Locale locale) async {
    if (!_supported(locale.languageCode)) return;
    state = Locale(locale.languageCode);
    try {
      await ref.read(preferencesProvider)?.setString(_key, locale.languageCode);
    } on Object {
      // Keep the in-memory choice.
    }
  }
}
