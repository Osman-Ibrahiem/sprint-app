import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprint/core/storage/preferences_provider.dart';
import 'package:sprint/features/catalogue/domain/arabic_normalizer.dart';

part 'recent_searches_store.g.dart';

/// The last few search terms, newest first, kept on the device (data-model).
/// Storage failures simply mean no recents, never an error (FR-010).
class RecentSearchesStore {
  const RecentSearchesStore(this._prefs);

  final SharedPreferences? _prefs;

  static const key = 'recentSearches';
  static const maxTerms = 5;

  /// Raw terms as typed, newest first, at most [maxTerms].
  List<String> read() {
    try {
      final raw = _prefs?.getString(key);
      if (raw == null) return const [];
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return [
        for (final term in decoded)
          if (term is String && term.trim().isNotEmpty) term,
      ].take(maxTerms).toList(growable: false);
    } on Object {
      return const [];
    }
  }

  /// Puts [term] first, dropping an older spelling of the same normalised
  /// term and anything past the fifth.
  Future<void> add(String term) async {
    final trimmed = term.trim();
    if (trimmed.isEmpty) return;
    final normalized = ArabicNormalizer.normalize(trimmed);
    final next = [
      trimmed,
      ...read().where((t) => ArabicNormalizer.normalize(t) != normalized),
    ].take(maxTerms).toList(growable: false);
    try {
      await _prefs?.setString(key, jsonEncode(next));
    } on Object {
      // Keep the app usable without storage.
    }
  }

  Future<void> clear() async {
    try {
      await _prefs?.remove(key);
    } on Object {
      // Nothing to clear.
    }
  }
}

@Riverpod(keepAlive: true)
RecentSearchesStore recentSearchesStore(Ref ref) =>
    RecentSearchesStore(ref.watch(preferencesProvider));
