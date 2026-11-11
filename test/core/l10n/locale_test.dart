import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprint/core/l10n/locale_notifier.dart';
import 'package:sprint/core/storage/preferences_provider.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

import '../../helpers/pump_app.dart';

void main() {
  Future<ProviderContainer> containerWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    final prefs = await SharedPreferences.getInstance();
    final c = ProviderContainer(
      overrides: [preferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('Arabic is the default', () async {
    final c = await containerWith({});
    expect(c.read(localeProvider), const Locale('ar'));
  });

  test('the choice persists across a relaunch', () async {
    final c = await containerWith({});
    await c.read(localeProvider.notifier).set(const Locale('en'));
    expect(c.read(localeProvider), const Locale('en'));

    final prefs = await SharedPreferences.getInstance();
    final again = ProviderContainer(
      overrides: [preferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(again.dispose);
    expect(again.read(localeProvider), const Locale('en'));
  });

  test('an unsupported stored language falls back to Arabic', () async {
    final c = await containerWith({'locale': 'fr'});
    expect(c.read(localeProvider), const Locale('ar'));
  });

  test('without storage the default applies and changes work in memory',
      () async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(localeProvider), const Locale('ar'));
    await c.read(localeProvider.notifier).set(const Locale('en'));
    expect(c.read(localeProvider), const Locale('en'));
  });

  testWidgets('switching to English flips direction and text', (tester) async {
    await pumpSprintApp(tester);
    TextDirection dir() =>
        Directionality.of(tester.element(find.byType(Scaffold).first));
    expect(dir(), TextDirection.rtl);
    expect(find.text(ar.homeTitle), findsOneWidget);

    await containerOf(tester)
        .read(localeProvider.notifier)
        .set(const Locale('en'));
    await tester.pumpAndSettle();

    final en = lookupAppLocalizations(const Locale('en'));
    expect(dir(), TextDirection.ltr);
    expect(find.text(en.homeTitle), findsOneWidget);
    expect(find.text(ar.homeTitle), findsNothing);
  });
}
