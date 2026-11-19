import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprint/features/catalogue/data/recent_searches_store.dart';
import 'package:sprint/features/notifications/data/notification_permission_store.dart';
import 'package:sprint/features/notifications/domain/notification_permission.dart';

class _ThrowingPrefs extends Mock implements SharedPreferences {}

void main() {
  Future<SharedPreferences> prefsWith([Map<String, Object> values = const {}]) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  group('RecentSearchesStore', () {
    test('keeps at most five terms, newest first', () async {
      final store = RecentSearchesStore(await prefsWith());

      for (final term in ['واحد', 'اثنان', 'ثلاثة', 'أربعة', 'خمسة', 'ستة']) {
        await store.add(term);
      }

      expect(
        store.read(),
        ['ستة', 'خمسة', 'أربعة', 'ثلاثة', 'اثنان'],
      );
    });

    test('deduplicates by normalised form, keeping the newest spelling',
        () async {
      final store = RecentSearchesStore(await prefsWith());

      await store.add('ملعب');
      await store.add('احمد');
      await store.add('مَلْعَب');

      expect(store.read(), ['مَلْعَب', 'احمد']);

      await store.add('أحمد');
      expect(store.read(), ['أحمد', 'مَلْعَب']);
    });

    test('ignores blank terms', () async {
      final store = RecentSearchesStore(await prefsWith());

      await store.add('   ');
      await store.add('');
      await store.add('نادي');

      expect(store.read(), ['نادي']);
    });

    test('clear empties the stored list', () async {
      final prefs = await prefsWith();
      final store = RecentSearchesStore(prefs);
      await store.add('نادي');

      await store.clear();

      expect(store.read(), isEmpty);
      expect(prefs.getString('recentSearches'), isNull);
    });

    test('reads an older stored list', () async {
      final prefs = await prefsWith({
        'recentSearches': jsonEncode(['ستاد', 'مسبح']),
      });

      expect(RecentSearchesStore(prefs).read(), ['ستاد', 'مسبح']);
    });

    test('a malformed stored value reads as empty', () async {
      final prefs = await prefsWith({'recentSearches': 'not json'});

      expect(RecentSearchesStore(prefs).read(), isEmpty);
    });

    test('without storage it reads empty and writes do not throw', () async {
      final store = RecentSearchesStore(null);

      expect(store.read(), isEmpty);
      await store.add('نادي');
      await store.clear();
    });

    test('a failing store reads empty and writes do not throw', () async {
      final prefs = _ThrowingPrefs();
      when(() => prefs.getString(any())).thenThrow(StateError('broken'));
      when(() => prefs.setString(any(), any())).thenThrow(StateError('broken'));
      when(() => prefs.remove(any())).thenThrow(StateError('broken'));
      final store = RecentSearchesStore(prefs);

      expect(store.read(), isEmpty);
      await store.add('نادي');
      await store.clear();
    });
  });

  group('NotificationPermissionStore', () {
    test('stores granted and denied as text', () async {
      final prefs = await prefsWith();
      final store = NotificationPermissionStore(prefs);
      expect(store.read(), isNull);

      await store.write(NotificationPermission.granted);
      expect(store.read(), NotificationPermission.granted);
      expect(prefs.getString('notifPermission'), 'granted');

      await store.write(NotificationPermission.denied);
      expect(store.read(), NotificationPermission.denied);
      expect(prefs.getString('notifPermission'), 'denied');
    });

    test('reads an older answer and clears it', () async {
      final prefs = await prefsWith({'notifPermission': 'denied'});
      final store = NotificationPermissionStore(prefs);
      expect(store.read(), NotificationPermission.denied);

      await store.clear();

      expect(store.read(), isNull);
      expect(prefs.getString('notifPermission'), isNull);
    });

    test('an unknown stored value reads as never asked', () async {
      final prefs = await prefsWith({'notifPermission': 'maybe'});

      expect(NotificationPermissionStore(prefs).read(), isNull);
    });

    test('without storage it reads absent and writes do not throw', () async {
      final store = NotificationPermissionStore(null);

      expect(store.read(), isNull);
      await store.write(NotificationPermission.granted);
      await store.clear();
    });

    test('a failing store reads absent and writes do not throw', () async {
      final prefs = _ThrowingPrefs();
      when(() => prefs.getString(any())).thenThrow(StateError('broken'));
      when(() => prefs.setString(any(), any())).thenThrow(StateError('broken'));
      when(() => prefs.remove(any())).thenThrow(StateError('broken'));
      final store = NotificationPermissionStore(prefs);

      expect(store.read(), isNull);
      await store.write(NotificationPermission.denied);
      await store.clear();
    });
  });
}
