import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/booking/domain/booking_path.dart';

import '../../../helpers/domain_builders.dart';

void main() {
  test('a paid facility without a trainer uses the slot path', () {
    expect(BookingPath.of(facility()), BookingPath.slot);
  });

  test('a free facility uses the range path (BR-08)', () {
    expect(BookingPath.of(facility(isFree: true)), BookingPath.range);
  });

  test('a trainer facility uses the trainer path (BR-09)', () {
    expect(
      BookingPath.of(facility(requiresTrainer: true)),
      BookingPath.trainer,
    );
  });

  test('a free facility that requires a trainer still goes trainer first', () {
    expect(
      BookingPath.of(facility(isFree: true, requiresTrainer: true)),
      BookingPath.trainer,
    );
  });
}
