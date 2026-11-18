import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprint/core/data/demo_snapshot_store.dart';
import 'package:sprint/core/data/json_converters.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';

/// The P1 [DemoSnapshotStore] on `shared_preferences`: the snapshot as one JSON
/// string, each photo as base64 under `photo/<id>`. Every read tolerates
/// missing or corrupt values.
class PreferencesSnapshotStore implements DemoSnapshotStore {
  PreferencesSnapshotStore(this._prefs);

  static const snapshotKey = 'demo/snapshot';
  static const photoPrefix = 'photo/';

  final SharedPreferences? _prefs;

  @override
  Future<Map<String, Object?>?> load() async {
    try {
      final text = _prefs?.getString(snapshotKey);
      if (text == null) return null;
      final decoded = jsonDecode(text);
      return decoded is Map ? Map<String, Object?>.from(decoded) : null;
    } on Object {
      return null;
    }
  }

  @override
  Future<void> save(Map<String, Object?> snapshot) async {
    try {
      await _prefs?.setString(snapshotKey, jsonEncode(snapshot));
    } on Object {
      // Losing a save only loses persistence, never the running session.
    }
  }

  @override
  Future<Uint8List?> loadPhoto(String id) async {
    try {
      return bytesFromBase64(_prefs?.getString('$photoPrefix$id'));
    } on Object {
      return null;
    }
  }

  @override
  Future<Result<void>> savePhoto(String id, Uint8List bytes) async {
    try {
      final ok = await _prefs?.setString(
        '$photoPrefix$id',
        bytesToBase64(bytes),
      );
      return ok == false ? const Err(StorageFull()) : const Ok<void>(null);
    } on Object {
      return const Err(StorageFull());
    }
  }

  @override
  Future<void> deletePhoto(String id) async {
    try {
      await _prefs?.remove('$photoPrefix$id');
    } on Object {
      // Nothing to remove, or the platform refused; the photo simply stays.
    }
  }

  @override
  Future<void> clear() async {
    final prefs = _prefs;
    if (prefs == null) return;
    try {
      await prefs.remove(snapshotKey);
      for (final k in prefs.getKeys().where((k) => k.startsWith(photoPrefix))) {
        await prefs.remove(k);
      }
    } on Object {
      // Nothing more to clear.
    }
  }
}
