import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/payments/domain/receipt.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// A receipt as words: the title, its rows and the total, built once from a
/// [Receipt] and the ARB strings, then drawn by the screen, the PDF and the
/// text share (FR-PAY-03). It carries at most the last four card digits.
class ReceiptDocument {
  const ReceiptDocument({
    required this.title,
    required this.rows,
    required this.totalLabel,
    required this.total,
    required this.number,
    required this.isTest,
    required this.testTag,
    this.refundLabel,
    this.refund,
  });

  /// "إيصال دفع".
  final String title;

  /// Label and value, in the order the screen shows them.
  final List<(String label, String value)> rows;
  final String totalLabel;
  final String total;

  /// `RC-yyMMdd-NNNN`, for the file name.
  final String number;
  final bool isTest;
  final String testTag;

  /// The refund line, shown after the total only when money came back.
  final String? refundLabel;
  final String? refund;

  factory ReceiptDocument.of(
    AppLocalizations l10n,
    SprintFormat format,
    Receipt r,
  ) {
    final tier = r.tier == PriceTier.internal
        ? l10n.checkoutTierInternal
        : l10n.checkoutTierExternal;
    return ReceiptDocument(
      title: l10n.receiptTitle,
      rows: [
        (l10n.receiptNumber, r.number),
        (l10n.receiptBookingCode, r.bookingCode),
        (l10n.receiptDate, '${format.date(r.paidAt)} ${format.time(r.paidAt)}'),
        (l10n.receiptUnit, '${r.facilityName} · ${r.unitName}'),
        (l10n.receiptTier, tier),
        (l10n.receiptMethod, l10n.receiptMethodCard(r.cardLast4)),
      ],
      totalLabel: l10n.receiptTotalPaid,
      total: format.price(r.amount),
      number: r.number,
      isTest: r.isTest,
      testTag: l10n.checkoutSandboxTag,
      refundLabel: r.refundAmount == null ? null : l10n.receiptRefund,
      refund: r.refundAmount == null ? null : format.price(r.refundAmount!),
    );
  }

  /// The plain-text form, for sharing when the PDF cannot be made or the
  /// platform shares text only.
  String toText() {
    final b = StringBuffer(title);
    if (isTest) b.write('\n$testTag');
    for (final (label, value) in rows) {
      b.write('\n$label: $value');
    }
    b.write('\n$totalLabel: $total');
    if (refund != null) b.write('\n$refundLabel: $refund');
    return b.toString();
  }
}
