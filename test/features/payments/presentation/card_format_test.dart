import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/payments/presentation/card_format.dart';

void main() {
  final now = DateTime(2026, 11, 17);

  test('published test numbers pass Luhn', () {
    for (final n in [
      '4242 4242 4242 4242',
      '4000056655665556',
      '5555555555554444',
      '378282246310005',
    ]) {
      expect(CardFormat.isValidNumber(n), isTrue, reason: n);
    }
  });

  test('a wrong digit, a short or an empty number fails', () {
    expect(CardFormat.isValidNumber('4242 4242 4242 4241'), isFalse);
    expect(CardFormat.isValidNumber('4242'), isFalse);
    expect(CardFormat.isValidNumber(''), isFalse);
    expect(CardFormat.isValidNumber('abcd efgh ijkl mnop'), isFalse);
  });

  test('Arabic-Indic digits are read as digits', () {
    expect(CardFormat.digits('٤٢٤٢ ٤٢٤٢'), '42424242');
    expect(CardFormat.isValidNumber('٤٢٤٢ ٤٢٤٢ ٤٢٤٢ ٤٢٤٢'), isTrue);
  });

  test('grouping', () {
    expect(CardFormat.groupNumber('4242424242424242'), '4242 4242 4242 4242');
    expect(CardFormat.groupNumber('42424'), '4242 4');
    expect(CardFormat.groupExpiry('0828'), '08/28');
    expect(CardFormat.groupExpiry('0'), '0');
    expect(CardFormat.groupExpiry('08289'), '08/28');
  });

  test('expiry: real month, not in the past', () {
    expect(CardFormat.isValidExpiry('11/26', now), isTrue, reason: 'this month');
    expect(CardFormat.isValidExpiry('10/26', now), isFalse);
    expect(CardFormat.isValidExpiry('01/27', now), isTrue);
    expect(CardFormat.isValidExpiry('13/28', now), isFalse);
    expect(CardFormat.isValidExpiry('00/28', now), isFalse);
    expect(CardFormat.isValidExpiry('1/2', now), isFalse);
  });

  test('cvc is 3 or 4 digits, the name is not empty', () {
    expect(CardFormat.isValidCvc('123'), isTrue);
    expect(CardFormat.isValidCvc('1234'), isTrue);
    expect(CardFormat.isValidCvc('12'), isFalse);
    expect(CardFormat.isValidCvc('12345'), isFalse);
    expect(CardFormat.isValidName('  '), isFalse);
    expect(CardFormat.isValidName('منى عبد الله'), isTrue);
  });

  test('last4 is the only thing that leaves', () {
    expect(CardFormat.last4('4242 4242 4242 4242'), '4242');
    expect(CardFormat.last4('12'), '12');
  });
}
