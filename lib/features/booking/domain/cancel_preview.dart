/// The four refund cases the cancel dialog and the result screen show, plus
/// the two reasons no cancel can happen (BR-30 – BR-32, BR-48).
enum CancelKind {
  /// Everything paid comes back.
  full,

  /// Part of what was paid comes back (`refundPercent` between 1 and 99).
  partial,

  /// Money was paid but the setting returns nothing.
  none,

  /// Nothing was charged (a free booking, or one still holding), so nothing
  /// comes back and nothing is owed.
  free,

  /// The cancellation cutoff has passed.
  closed,

  /// This status cannot be cancelled, or a payment is being confirmed (BR-47).
  notAllowed,
}

/// What cancelling would mean right now, computed once and shared by the
/// dialog, the reminder and the repository (research R3). The UI chooses its
/// wording from [kind]; every amount and time here comes from the booking and
/// the resolved settings, never from text.
class CancelPreview {
  const CancelPreview({
    required this.kind,
    required this.paidAmount,
    required this.refundAmount,
    required this.refundPercent,
    required this.cancelUntil,
  });

  final CancelKind kind;

  /// What the booker actually paid: the sum of succeeded payments.
  final int paidAmount;

  /// Whole Egyptian pounds that would come back.
  final int refundAmount;

  /// The resolved `refundPercent` setting.
  final int refundPercent;

  /// `start - cancellationCutoffHours`.
  final DateTime cancelUntil;

  bool get canCancel =>
      kind != CancelKind.closed && kind != CancelKind.notAllowed;

  /// Whether a money line belongs in the confirmation and the result.
  bool get showsRefund => kind == CancelKind.full || kind == CancelKind.partial;
}
