import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A chosen sheet: its file name and its text (FR-036).
class PickedSheet {
  const PickedSheet({required this.name, required this.text});

  final String name;
  final String text;
}

/// Where the sheet comes from. Injectable, so tests hand over a CSV text
/// instead of opening the platform's file chooser.
abstract interface class SheetFilePicker {
  /// The chosen `.csv` file read as UTF-8, or null when the person backed
  /// out. Throws when the file cannot be read.
  Future<PickedSheet?> pick();
}

/// `file_selector`: the platform's file chooser on every platform, `.csv`
/// only (research R8).
class FileSelectorSheetPicker implements SheetFilePicker {
  const FileSelectorSheetPicker();

  static const _csv = XTypeGroup(
    label: 'CSV',
    extensions: ['csv'],
    mimeTypes: ['text/csv'],
    uniformTypeIdentifiers: ['public.comma-separated-values-text'],
  );

  @override
  Future<PickedSheet?> pick() async {
    final file = await openFile(acceptedTypeGroups: const [_csv]);
    if (file == null) return null;
    final text = utf8.decode(await file.readAsBytes());
    // A byte order mark is not part of the first cell.
    return PickedSheet(
      name: file.name,
      text: text.startsWith('﻿') ? text.substring(1) : text,
    );
  }
}

final sheetFilePickerProvider = Provider<SheetFilePicker>(
  (ref) => const FileSelectorSheetPicker(),
);
