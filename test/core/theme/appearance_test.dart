import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprint/core/storage/preferences_provider.dart';
import 'package:sprint/core/theme/theme_mode_notifier.dart';

import '../../helpers/pump_app.dart';

class _BrokenPrefs extends Mock implements SharedPreferences {}

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

  test('follows the device by default', () async {
    final c = await containerWith({});
    expect(c.read(themeModeProvider), ThemeMode.system);
  });

  test('an override is applied and survives a relaunch', () async {
    final c = await containerWith({});
    await c.read(themeModeProvider.notifier).set(ThemeMode.dark);
    expect(c.read(themeModeProvider), ThemeMode.dark);

    // "Relaunch": a new container over the same stored values.
    final prefs = await SharedPreferences.getInstance();
    final again = ProviderContainer(
      overrides: [preferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(again.dispose);
    expect(again.read(themeModeProvider), ThemeMode.dark);

    await again.read(themeModeProvider.notifier).set(ThemeMode.light);
    expect(again.read(themeModeProvider), ThemeMode.light);
    await again.read(themeModeProvider.notifier).set(ThemeMode.system);
    expect(again.read(themeModeProvider), ThemeMode.system);
  });

  test('an unknown stored value falls back to the default', () async {
    final c = await containerWith({'themeMode': 'purple'});
    expect(c.read(themeModeProvider), ThemeMode.system);
  });

  test('storage that cannot start falls back to defaults', () async {
    final c = ProviderContainer(); // preferences provider returns null
    addTearDown(c.dispose);
    expect(c.read(themeModeProvider), ThemeMode.system);
    await c.read(themeModeProvider.notifier).set(ThemeMode.dark);
    expect(c.read(themeModeProvider), ThemeMode.dark); // still works in memory
  });

  test('storage that throws on read or write does not crash', () async {
    final broken = _BrokenPrefs();
    when(() => broken.getString(any())).thenThrow(Exception('read'));
    when(() => broken.setString(any(), any())).thenThrow(Exception('write'));
    final c = ProviderContainer(
      overrides: [preferencesProvider.overrideWithValue(broken)],
    );
    addTearDown(c.dispose);
    expect(c.read(themeModeProvider), ThemeMode.system);
    await c.read(themeModeProvider.notifier).set(ThemeMode.light);
    expect(c.read(themeModeProvider), ThemeMode.light);
  });

  testWidgets('the app follows the chosen mode', (tester) async {
    await pumpSprintApp(tester);
    Brightness brightness() =>
        Theme.of(tester.element(find.text(ar.homeTitle))).brightness;

    containerOf(tester).read(themeModeProvider.notifier).set(ThemeMode.dark);
    await tester.pumpAndSettle();
    expect(brightness(), Brightness.dark);

    containerOf(tester).read(themeModeProvider.notifier).set(ThemeMode.light);
    await tester.pumpAndSettle();
    expect(brightness(), Brightness.light);
  });
}
