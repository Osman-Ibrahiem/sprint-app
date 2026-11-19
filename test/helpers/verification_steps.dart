import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' as rp;
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/adaptive/photo_source.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_units.dart';
import 'package:sprint/features/verification/presentation/id_card_photo_picker.dart';
import 'package:sprint/features/verification/presentation/sheet_file_picker.dart';

import 'pump_app.dart';
import 'sign_up_steps.dart';

/// A picker the test drives: no platform plugin is involved.
class FakeIdCardSource implements PhotoSourcePicker {
  FakeIdCardSource({Uint8List? bytes})
    : bytes =
          bytes ??
          File('assets/demo/id_card_placeholder.jpg').readAsBytesSync();

  /// What the next pick returns; null stands for backing out.
  Uint8List? bytes;
  Object? failWith;
  int calls = 0;
  PhotoSource? lastSource;

  @override
  Future<Uint8List?> pick(PhotoSource source) async {
    calls++;
    lastSource = source;
    if (failWith != null) throw failWith!;
    return bytes;
  }
}

/// Keeps the pipeline synchronous in widget tests (the real one uses an
/// isolate); the encoder has its own test.
List<rp.Override> fakePhotoOverrides(FakeIdCardSource source) => [
  photoSourceProvider.overrideWithValue(source),
  idCardEncoderProvider.overrideWithValue((b) async => b),
];

/// Signs in as [userId] with the demo switcher and opens the request screen.
Future<void> openVerificationAs(
  WidgetTester tester,
  String userId, {
  String path = '/profile/verification',
}) async {
  await tester.runAsync(
    () => containerOf(tester).read(sessionProvider.notifier).actAs(userId),
  );
  await tester.pumpAndSettle();
  routerOf(tester).go(path);
  await tester.pumpAndSettle();
}

String unitName(String id) =>
    seedOwningUnits.firstWhere((u) => u.id == id).name;

Future<void> enterRequestFields(
  WidgetTester tester, {
  String? nationalId,
  String? code,
}) async {
  final fields = find.byType(TextField);
  if (nationalId != null) await tester.enterText(fields.at(0), nationalId);
  if (code != null) await tester.enterText(fields.at(1), code);
  await tester.pump();
}

/// Picks the first source on offer (the gallery on every platform) and waits.
Future<void> pickIdCardPhoto(WidgetTester tester, String galleryLabel) async {
  final button = find.byKey(IdCardPhotoPicker.buttonKey);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
  await tapText(tester, galleryLabel);
}

/// A sheet picker the test drives: no file chooser is opened.
class FakeSheetPicker implements SheetFilePicker {
  FakeSheetPicker({this.name = 'sheet.csv', this.text});

  String name;

  /// What the next pick returns; null stands for backing out.
  String? text;
  Object? failWith;
  int calls = 0;

  @override
  Future<PickedSheet?> pick() async {
    calls++;
    if (failWith != null) throw failWith!;
    final t = text;
    return t == null ? null : PickedSheet(name: name, text: t);
  }
}

List<rp.Override> fakeSheetOverrides(FakeSheetPicker picker) => [
  sheetFilePickerProvider.overrideWithValue(picker),
];

/// The sample sheet shipped for the demo.
String sampleSheetText() =>
    File('assets/demo/verification_sheet_sample.csv').readAsStringSync();

/// Acts as [userId] and opens [path] (the reviewer screens).
Future<void> openReviewerAs(WidgetTester tester, String userId, String path) =>
    openVerificationAs(tester, userId, path: path);
