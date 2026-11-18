import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/catalogue/domain/bookable_unit.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/payments/domain/payment.dart';

/// A receipt, derived from a `succeeded` payment and its booking; never
/// stored (data-model.md). It carries values only: the words around them are
/// built in presentation from the ARB files, so this file imports no Flutter.
class Receipt {
  const Receipt({
    required this.number,
    required this.bookingCode,
    required this.paidAt,
    required this.facilityName,
    required this.unitName,
    required this.tier,
    required this.cardLast4,
    required this.isTest,
    required this.amount,
  });

  /// `RC-yyMMdd-NNNN`.
  final String number;
  final String bookingCode;

  /// UTC; shown in Cairo time.
  final DateTime paidAt;
  final String facilityName;
  final String unitName;
  final PriceTier tier;

  /// Exactly four digits: the only card data the app ever holds.
  final String cardLast4;

  /// True for the fake and sandbox providers (P1).
  final bool isTest;

  /// Whole Egyptian pounds.
  final int amount;

  /// Null unless [payment] succeeded and carries a receipt number, a paid
  /// time and four card digits.
  static Receipt? fromPayment(
    Payment payment,
    Booking booking,
    Facility facility,
    BookableUnit unit,
  ) {
    final number = payment.receiptNumber;
    final paidAt = payment.paidAt;
    final last4 = payment.cardLast4;
    if (payment.status != PaymentStatus.succeeded ||
        number == null ||
        paidAt == null ||
        last4 == null ||
        !RegExp(r'^\d{4}$').hasMatch(last4)) {
      return null;
    }
    return Receipt(
      number: number,
      bookingCode: booking.code,
      paidAt: paidAt,
      facilityName: facility.name,
      unitName: unit.name,
      tier: booking.tierAtBooking,
      cardLast4: last4,
      isTest: const {'FAKE', 'SANDBOX'}.contains(payment.provider.toUpperCase()),
      amount: payment.amount,
    );
  }
}
