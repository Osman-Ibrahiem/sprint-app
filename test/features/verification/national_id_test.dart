import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/auth/domain/validators.dart';
import 'package:sprint/features/verification/domain/national_id.dart';

void main() {
  final now = DateTime(2026, 11, 16);
  NationalIdProblem? problem(String id) =>
      validateNationalId(id, now: now).reasonOrNull;

  test('valid 1900s and 2000s ids', () {
    expect(validateNationalId('29901011234567', now: now).isValid, isTrue);
    expect(validateNationalId('30501011234567', now: now).isValid, isTrue);
  });

  test('Arabic-Indic digits and separators are normalised', () {
    expect(
      validateNationalId('٢٩٩٠١٠١١٢٣٤٥٦٧', now: now).valueOrNull,
      '29901011234567',
    );
    expect(
      validateNationalId('2 990101 12 34567', now: now).valueOrNull,
      '29901011234567',
    );
  });

  test('length and characters', () {
    expect(problem(''), NationalIdProblem.empty);
    expect(problem('2990101123456'), NationalIdProblem.notFourteenDigits);
    expect(problem('299010112345678'), NationalIdProblem.notFourteenDigits);
    expect(problem('2990101123456x'), NationalIdProblem.notFourteenDigits);
  });

  test('century digit', () {
    expect(problem('19901011234567'), NationalIdProblem.invalidCentury);
    expect(problem('49901011234567'), NationalIdProblem.invalidCentury);
  });

  test('birth date', () {
    expect(problem('29913011234567'), NationalIdProblem.invalidBirthDate);
    expect(problem('29902301234567'), NationalIdProblem.invalidBirthDate);
    expect(problem('29902291234567'), NationalIdProblem.invalidBirthDate);
    expect(problem('30002291234567'), isNull);
    expect(problem('29900001234567'), NationalIdProblem.invalidBirthDate);
  });

  test('future birth date', () {
    expect(problem('32701011234567'), NationalIdProblem.futureBirthDate);
    expect(problem('32611171234567'), NationalIdProblem.futureBirthDate);
    expect(problem('32611161234567'), isNull);
  });

  test('governorate codes', () {
    String withGov(String g) => '2990101${g}34567';
    for (final ok in [
      '01',
      '02',
      '03',
      '04',
      '11',
      '15',
      '19',
      '21',
      '29',
      '31',
      '35',
      '88',
    ]) {
      expect(problem(withGov(ok)), isNull, reason: ok);
    }
    for (final bad in ['00', '05', '10', '20', '30', '36', '87', '89', '99']) {
      expect(
        problem(withGov(bad)),
        NationalIdProblem.invalidGovernorate,
        reason: bad,
      );
    }
  });

  test('masking keeps the last 4 digits only', () {
    expect(maskNationalId('29901011234567'), '**********4567');
    expect(maskNationalId('٢٩٩٠١٠١١٢٣٤٥٦٧'), '**********4567');
    expect(maskNationalId('12'), '**');
    expect(maskNationalId('29901011234567').contains('2990'), isFalse);
  });

  test('uses shared Validation type', () {
    expect(
      validateNationalId('x', now: now),
      isA<Invalid<String, NationalIdProblem>>(),
    );
  });
}
