import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/identity/domain/verification.dart';
import 'package:sprint/features/verification/data/csv_sheet_parser.dart';

/// FR-036, FR-038, research R8.
void main() {
  const parser = CsvSheetParser();
  const id1 = '29901011234567';
  const id2 = '30001151234567';

  test('rows without a header', () {
    final r = parser.parse('$id1,2021001,student\n$id2,ST-77,staff\n');
    expect(r.headerSkipped, isFalse);
    expect(r.problems, isEmpty);
    expect(r.rows.map((e) => (e.rowNumber, e.nationalId, e.code, e.type)), [
      (1, id1, '2021001', VerificationType.student),
      (2, id2, 'ST-77'.replaceAll('-', ''), VerificationType.staff),
    ]);
  });

  test('a header row is skipped and numbers stay file line numbers', () {
    final r = parser.parse('national_id,code,type\n$id1,2021001,faculty\n');
    expect(r.headerSkipped, isTrue);
    expect(r.rows.single.rowNumber, 2);
    expect(r.rows.single.type, VerificationType.faculty);
  });

  test(
    'a first row with a mistyped national ID is a problem, not a header',
    () {
      final r = parser.parse(
        '2990101123456,2021001,student\n$id2,2021002,staff\n',
      );
      expect(r.headerSkipped, isFalse);
      expect(r.problems.single.rowNumber, 1);
      expect(r.problems.single.reasonCode, startsWith('nationalId.'));
      expect(r.rows.single.rowNumber, 2);
    },
  );

  test('a UTF-8 BOM is stripped', () {
    final r = parser.parse('﻿$id1,2021001,student');
    expect(r.headerSkipped, isFalse);
    expect(r.rows, hasLength(1));
    expect(r.rows.single.nationalId, id1);
  });

  test('quoted cells with commas and quotes', () {
    final r = parser.parse('"$id1","20,21","student"\n');
    expect(r.rows, isEmpty);
    expect(r.problems.single.reasonCode, sheetReasonCode);
    final ok = parser.parse('"$id1","2021001","طالب"');
    expect(ok.rows.single.type, VerificationType.student);
  });

  test('CRLF and blank lines', () {
    final r = parser.parse('$id1,1,student\r\n\r\n$id2,2,staff\r\n');
    expect(r.rows.map((e) => e.rowNumber), [1, 3]);
  });

  test('Arabic type names', () {
    final r = parser.parse('$id1,1,طالب\n$id2,2,موظف\n$id1,3,عضو هيئة تدريس\n');
    expect(r.rows.map((e) => e.type), [
      VerificationType.student,
      VerificationType.staff,
      VerificationType.faculty,
    ]);
  });

  test('type names ignore case and spaces', () {
    final r = parser.parse('$id1,1, Student \n');
    expect(r.rows.single.type, VerificationType.student);
  });

  test('Arabic-Indic digits in the ID and the code', () {
    final r = parser.parse('٢٩٩٠١٠١١٢٣٤٥٦٧,٢٠٢١٠٠١,student');
    expect(r.rows.single.nationalId, id1);
    expect(r.rows.single.code, '2021001');
  });

  test('problems carry the row number and a reason code', () {
    final r = parser.parse(
      [
        '$id1,1,student',
        '29913011234567,1,student', // month 13
        '123,1,student',
        '$id1,,student',
        '$id1,1,teacher',
      ].join('\n'),
    );
    expect(r.rows, hasLength(1));
    expect(r.problems.map((p) => (p.rowNumber, p.reasonCode)), [
      (2, 'nationalId.invalidBirthDate'),
      (3, 'nationalId.notFourteenDigits'),
      (4, sheetReasonCode),
      (5, sheetReasonType),
    ]);
  });

  test('wrong column count is a problem of that row', () {
    final r = parser.parse('$id1,1\n$id1,1,student,extra\n$id2,2,staff,\n');
    expect(r.problems.map((p) => (p.rowNumber, p.reasonCode)), [
      (1, sheetReasonColumns),
      (2, sheetReasonColumns),
    ]);
    // A trailing comma is tolerated.
    expect(r.rows.single.rowNumber, 3);
  });

  test('an empty file and a header-only file have no rows', () {
    for (final text in ['', '   \n\n', '﻿', 'a,b,c\n']) {
      final r = parser.parse(text);
      expect(r.rows, isEmpty, reason: text);
      expect(r.problems, isEmpty, reason: text);
    }
    expect(parser.parse('a,b,c\n').headerSkipped, isTrue);
  });
}
