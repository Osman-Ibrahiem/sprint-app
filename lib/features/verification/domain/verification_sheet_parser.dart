import 'package:sprint/features/identity/domain/verification.dart';
import 'package:sprint/features/verification/domain/sheet_batch.dart';

/// A valid line of a sheet, before it is tagged with an uploader and batch.
class ParsedSheetRow {
  const ParsedSheetRow({
    required this.rowNumber,
    required this.nationalId,
    required this.code,
    required this.type,
  });

  final int rowNumber;
  final String nationalId;
  final String code;
  final VerificationType type;
}

class SheetParseResult {
  const SheetParseResult({
    required this.rows,
    required this.problems,
    required this.headerSkipped,
  });

  final List<ParsedSheetRow> rows;
  final List<SheetProblem> problems;
  final bool headerSkipped;
}

/// Reads a verification sheet. Pure; the real format from student affairs
/// replaces the P1 columns later (research R8, BRD section 11).
abstract interface class VerificationSheetParser {
  SheetParseResult parse(String csvText);
}
