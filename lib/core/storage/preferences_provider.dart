import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'preferences_provider.g.dart';

/// Local key-value storage, or null when it could not start. `main` overrides
/// this with the real instance; every reader tolerates null and failures
/// (FR-010, research R4). Only theme mode and locale are stored.
@Riverpod(keepAlive: true)
SharedPreferences? preferences(Ref ref) => null;
