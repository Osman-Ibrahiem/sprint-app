import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/auth/domain/auth_limits.dart';
import 'package:sprint/features/auth/domain/validators.dart';

void main() {
  test('auth limits', () {
    expect(AuthLimits.codeLength, 6);
    expect(AuthLimits.codeLife, const Duration(minutes: 15));
    expect(AuthLimits.maxCodeTries, 5);
    expect(AuthLimits.resendWait, const Duration(seconds: 60));
    expect(AuthLimits.maxPasswordFailures, 5);
    expect(AuthLimits.lockoutDuration, const Duration(minutes: 5));
  });

  group('normalizeDigits', () {
    test('converts Arabic-Indic and Persian digits, strips spaces/dashes', () {
      expect(normalizeDigits('٠١٢٣٤٥٦٧٨٩'), '0123456789');
      expect(normalizeDigits('۰۱۲۳۴۵۶۷۸۹'), '0123456789');
      expect(normalizeDigits(' 12-34 5 '), '12345');
    });
  });

  group('normalizePhone', () {
    for (final input in [
      '01012345678',
      '+201012345678',
      '00201012345678',
      '201012345678',
      '+20 10 1234 5678',
      '010-1234-5678',
      '٠١٠١٢٣٤٥٦٧٨',
      '+20١٠١٢٣٤٥٦٧٨',
      '1012345678',
    ]) {
      test('accepts $input', () {
        expect(normalizePhone(input).valueOrNull, '01012345678');
      });
    }
    for (final p in ['010', '011', '012', '015']) {
      test('accepts prefix $p', () {
        expect(normalizePhone('${p}12345678').valueOrNull, '${p}12345678');
      });
    }
    test('rejects bad prefix, lengths, letters', () {
      for (final bad in [
        '01312345678',
        '0101234567',
        '010123456789',
        '0201012345678',
        'abc',
        '+441012345678',
      ]) {
        expect(
          normalizePhone(bad).reasonOrNull,
          PhoneProblem.invalid,
          reason: bad,
        );
      }
    });
    test('empty', () {
      expect(normalizePhone('  ').reasonOrNull, PhoneProblem.empty);
    });
  });

  group('normalizeEmail', () {
    test('trims and lower-cases', () {
      expect(normalizeEmail('  Ali@Mail.COM ').valueOrNull, 'ali@mail.com');
    });
    test('rejects invalid', () {
      for (final bad in [
        'a@b',
        'a b@c.com',
        'a@@b.com',
        '@b.com',
        'a@.com',
        'a@b.',
        'plain',
      ]) {
        expect(
          normalizeEmail(bad).reasonOrNull,
          EmailProblem.invalid,
          reason: bad,
        );
      }
      expect(normalizeEmail(' ').reasonOrNull, EmailProblem.empty);
    });
    test('accepts subdomains and plus', () {
      expect(normalizeEmail('a+b@x.edu.eg').isValid, isTrue);
    });
  });

  group('validateName', () {
    test('accepts Arabic and Latin two words, collapses spaces', () {
      expect(validateName('  كريم   السيد ').valueOrNull, 'كريم السيد');
      expect(validateName("Sara O'Neil").valueOrNull, "Sara O'Neil");
    });
    test('boundary lengths', () {
      expect(validateName('a').reasonOrNull, NameProblem.tooShort);
      expect(validateName('a b').isValid, isTrue);
      final sixty = '${'a' * 29} ${'b' * 30}';
      expect(sixty.length, 60);
      expect(validateName(sixty).isValid, isTrue);
      expect(validateName('${sixty}c').reasonOrNull, NameProblem.tooLong);
    });
    test('needs two words', () {
      expect(validateName('كريم').reasonOrNull, NameProblem.needsTwoWords);
    });
    test('invalid characters', () {
      expect(validateName('Ali 2').reasonOrNull, NameProblem.invalidCharacters);
      expect(validateName('Ali #').reasonOrNull, NameProblem.invalidCharacters);
      expect(validateName('علي ١').reasonOrNull, NameProblem.invalidCharacters);
    });
    test('empty', () {
      expect(validateName('   ').reasonOrNull, NameProblem.empty);
    });
  });

  group('validatePassword', () {
    test('accepts 8 chars with letter and digit', () {
      expect(validatePassword('abcdefg1').isValid, isTrue);
    });
    test('reasons', () {
      expect(validatePassword('').reasonOrNull, PasswordProblem.empty);
      expect(validatePassword('abc123').reasonOrNull, PasswordProblem.tooShort);
      expect(
        validatePassword('abcdefgh').reasonOrNull,
        PasswordProblem.needsDigit,
      );
      expect(
        validatePassword('12345678').reasonOrNull,
        PasswordProblem.needsLetter,
      );
    });
    test('is not trimmed', () {
      expect(validatePassword('  abc123 ').valueOrNull, '  abc123 ');
    });
  });

  group('identifier', () {
    test('kind', () {
      expect(identifierKind('a@b.com'), IdentifierKind.email);
      expect(identifierKind('0101234567'), IdentifierKind.phone);
    });
    test('normalizeIdentifier', () {
      expect(normalizeIdentifier(' A@B.com '), 'a@b.com');
      expect(normalizeIdentifier('+20 10 1234 5678'), '01012345678');
    });
  });
}
