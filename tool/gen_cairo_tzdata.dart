// Writes lib/core/time/cairo_tzdata.g.dart: a time zone database holding only
// Africa/Cairo, so the web build does not ship every zone (about 250 KB).
//
// Run: dart run tool/gen_cairo_tzdata.dart
// ignore_for_file: implementation_imports
import 'dart:convert';
import 'dart:io';

import 'package:timezone/data/latest.dart' as full;
import 'package:timezone/src/location_database.dart';
import 'package:timezone/src/tzdb.dart';
import 'package:timezone/timezone.dart' as tz;

const outPath = 'lib/core/time/cairo_tzdata.g.dart';

/// The generated source, from the full database.
String generateCairoTzdata() {
  full.initializeTimeZones();
  final db = LocationDatabase()..add(tz.getLocation('Africa/Cairo'));
  final bytes = tzdbSerialize(db);
  return '''// GENERATED CODE - DO NOT EDIT.
// Source: package:timezone (run `dart run tool/gen_cairo_tzdata.dart`).
// dart format off

/// A time zone database with only Africa/Cairo, base64 encoded.
const cairoTzdataBase64 = '${base64Encode(bytes)}';
''';
}

void main() {
  File(outPath).writeAsStringSync(generateCairoTzdata());
  stdout.writeln('Wrote $outPath');
}
