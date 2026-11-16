import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprint/app/app.dart';
import 'package:sprint/core/data/preferences_snapshot_store.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/storage/preferences_provider.dart';
import 'package:sprint/core/time/cairo_time.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  CairoTime.ensureInitialized();

  // Storage is optional: if it cannot start, defaults apply (FR-010).
  SharedPreferences? prefs;
  try {
    prefs = await SharedPreferences.getInstance();
  } on Object {
    prefs = null;
  }

  // The demo data is saved on the device and restored here (research R1).
  final snapshotStore = PreferencesSnapshotStore(prefs);
  final snapshot = await snapshotStore.load();

  runApp(
    ProviderScope(
      overrides: [
        preferencesProvider.overrideWithValue(prefs),
        snapshotStoreProvider.overrideWithValue(snapshotStore),
        initialSnapshotProvider.overrideWithBuild((ref, notifier) => snapshot),
      ],
      child: const SprintApp(),
    ),
  );
}
