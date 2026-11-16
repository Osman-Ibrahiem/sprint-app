import 'package:csv/csv.dart';
import 'package:sprint/features/auth/domain/validators.dart';
import 'package:sprint/features/identity/domain/verification.dart';
import 'package:sprint/features/verification/domain/national_id.dart';
import 'package:sprint/features/verification/domain/sheet_batch.dart';
import 'package:sprint/features/verification/domain/verification_sheet_parser.dart';

/// The reason code of a line that does not have the three columns.
const String sheetReasonColumns = 'columns';

/// The reason code of an unusable university or staff code.
const String sheetReasonCode = 'code';

/// The reason code of an unknown type.
const String sheetReasonType = 'type';

/// The reason code of a bad national ID: `nationalId.<NationalIdProblem>`.
String sheetReasonNationalId(NationalIdProblem p) => 'nationalId.${p.name}';

final RegExp _codePattern = RegExp(r'^[A-Z0-9]{1,20}$');

/// The code as stored and compared: digits normalised, spaces and dashes
/// removed, upper case; null when it is not 1 to 20 letters or digits
/// (data-model: Verification.code).
String? normalizeVerificationCode(String input) {
  final code = normalizeDigits(input).toUpperCase();
  return _codePattern.hasMatch(code) ? code : null;
}

/// The type from its English or Arabic name (research R8), or null.
VerificationType? parseVerificationType(String input) {
  final t = input.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  return switch (t) {
    'student' || 'طالب' => VerificationType.student,
    'staff' || 'موظف' => VerificationType.staff,
    'faculty' || 'عضو هيئة تدريس' => VerificationType.faculty,
    _ => null,
  };
}

/// P1 sheet format (research R8, FR-036): UTF-8, comma separated, columns
/// national ID, code, type, with or without a header row. Pure.
class CsvSheetParser implements VerificationSheetParser {
  const CsvSheetParser();

  static final Csv _csv = Csv(
    fieldDelimiter: ',',
    autoDetect: false,
    skipEmptyLines: false,
  );

  @override
  SheetParseResult parse(String csvText) {
    final text = csvText.startsWith('﻿') ? csvText.substring(1) : csvText;
    final lines = text.trim().isEmpty
        ? const <List<dynamic>>[]
        : _csv.decode(text);

    final rows = <ParsedSheetRow>[];
    final problems = <SheetProblem>[];
    var headerSkipped = false;
    var seenFirst = false;

    for (var i = 0; i < lines.length; i++) {
      final cells = [for (final c in lines[i]) '$c'.trim()];
      if (cells.every((c) => c.isEmpty)) continue;
      final rowNumber = i + 1;

      // A header names the columns: its first cell has no digit at all. A
      // first row with digits is data, so a typo in its national ID is
      // reported like any other row instead of being taken for a header.
      if (!seenFirst) {
        seenFirst = true;
        if (!RegExp(r'\d').hasMatch(normalizeDigits(cells.first))) {
          headerSkipped = true;
          continue;
        }
      }

      // Extra empty trailing cells (a trailing comma) are tolerated.
      var n = cells.length;
      while (n > 3 && cells[n - 1].isEmpty) {
        n--;
      }
      if (n != 3) {
        problems.add(
          SheetProblem(rowNumber: rowNumber, reasonCode: sheetReasonColumns),
        );
        continue;
      }

      final id = validateNationalId(cells[0]);
      if (id case Invalid(:final reason)) {
        problems.add(
          SheetProblem(
            rowNumber: rowNumber,
            reasonCode: sheetReasonNationalId(reason),
          ),
        );
        continue;
      }
      final code = normalizeVerificationCode(cells[1]);
      if (code == null) {
        problems.add(
          SheetProblem(rowNumber: rowNumber, reasonCode: sheetReasonCode),
        );
        continue;
      }
      final type = parseVerificationType(cells[2]);
      if (type == null) {
        problems.add(
          SheetProblem(rowNumber: rowNumber, reasonCode: sheetReasonType),
        );
        continue;
      }
      rows.add(
        ParsedSheetRow(
          rowNumber: rowNumber,
          nationalId: id.valueOrNull!,
          code: code,
          type: type,
        ),
      );
    }
    return SheetParseResult(
      rows: rows,
      problems: problems,
      headerSkipped: headerSkipped,
    );
  }
}
