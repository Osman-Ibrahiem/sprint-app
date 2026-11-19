import 'package:flutter/widgets.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart' show cairoDayOf;
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/core/widgets/status_badge/sprint_status.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The status chip of a booking: always read from the booking itself, never
/// assumed (FR-MYB-02).
SprintStatus sprintStatusOf(BookingStatus status) => switch (status) {
  BookingStatus.confirmed => SprintStatus.confirmed,
  BookingStatus.pendingPayment => SprintStatus.pendingPayment,
  BookingStatus.cancelled => SprintStatus.cancelled,
  BookingStatus.attended => SprintStatus.attended,
  BookingStatus.noShow => SprintStatus.noShow,
  BookingStatus.expired => SprintStatus.expired,
};

/// A booking with the names its row and details show.
class BookingRowInfo {
  const BookingRowInfo({
    required this.booking,
    required this.facilityName,
    required this.unitName,
    this.trainerName,
  });

  final Booking booking;
  final String facilityName;
  final String unitName;
  final String? trainerName;
}

/// Everything a `BookingRow` takes, already worded (FR-MYB-02).
class BookingRowTexts {
  const BookingRowTexts({
    required this.dateLabel,
    required this.isToday,
    required this.notes,
    required this.action,
    required this.spoken,
  });

  final String dateLabel;
  final bool isToday;
  final String notes;
  final String action;
  final String spoken;

  /// [now] is the app clock's instant, so "today" and the hold countdown follow
  /// the demo clock.
  factory BookingRowTexts.of(
    BuildContext context,
    BookingRowInfo info,
    DateTime now,
  ) {
    final l10n = AppLocalizations.of(context);
    final format = SprintFormat.of(context);
    final b = info.booking;
    final start = CairoTime.toCairo(b.start);
    final end = CairoTime.toCairo(b.end);
    final isToday = cairoDayOf(b.start) == cairoDayOf(now);
    final date = isToday
        ? '${l10n.bookingsToday} · ${format.timeRange(start, end)}'
        : format.dateTimeLine(start, end);

    final notes = <String>[
      info.unitName,
      if (info.trainerName != null)
        l10n.bookingsNoteTrainer(info.trainerName!),
      if (b.priceAtBooking == 0) l10n.bookingsNoteFree,
      if (b.status == BookingStatus.pendingPayment && b.holdExpiresAt != null)
        l10n.bookingsNoteHold(_minutesLeft(b.holdExpiresAt!, now)),
    ];
    final action = switch (b.status) {
      BookingStatus.confirmed => l10n.bookingsActionTicket,
      BookingStatus.pendingPayment => l10n.bookingsActionPay,
      _ => l10n.bookingsActionDetails,
    };
    final status = sprintStatusOf(b.status).label(l10n);
    return BookingRowTexts(
      dateLabel: date,
      isToday: isToday,
      notes: notes.join(' · '),
      action: action,
      spoken: l10n.bookingsRowSpoken(
        status,
        date,
        info.facilityName,
        notes.join('، '),
        b.code.split('').join(' '),
        action,
      ),
    );
  }

  static int _minutesLeft(DateTime holdEnd, DateTime now) {
    final left = holdEnd.difference(now);
    return left.isNegative ? 0 : (left.inSeconds / 60).ceil();
  }
}
