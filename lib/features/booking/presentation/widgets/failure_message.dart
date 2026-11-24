import 'package:flutter/widgets.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/features/booking/domain/schedule_notice.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The one mapping from a refusal to words (FR-032, contracts/providers.md).
/// Says what happened and what to do next, never a technical text.
String bookingFailureMessage(
  BuildContext context,
  Failure failure, {
  OverlapInfo? overlap,
}) {
  final l10n = AppLocalizations.of(context);
  final format = SprintFormat.of(context);
  String hour(DateTime at) => format.time(at);

  return switch (failure) {
    SlotTaken(:final at) =>
      at == null
          ? l10n.bookingFailSlotTaken
          : l10n.bookingFailSlotTakenAt(hour(at)),
    SlotFull(:final at) =>
      at == null
          ? l10n.bookingFailSlotFull
          : l10n.bookingFailSlotFullAt(hour(at)),
    SlotPast() => l10n.bookingFailSlotPast,
    OutsideWindow() => l10n.bookingFailOutsideWindow,
    ClosedSlot(:final at) =>
      at == null ? l10n.bookingFailClosed : l10n.bookingFailClosedAt(hour(at)),
    RangeTooLong(:final maxHours) =>
      maxHours == null
          ? l10n.bookingFailRangeTooLongGeneric
          : l10n.bookingFailRangeTooLong(maxHours),
    OverlapsOwnBooking() =>
      overlap == null
          ? l10n.bookingFailOverlapGeneric
          : l10n.bookingFailOverlap(
              overlap.facilityName,
              '${format.date(overlap.start)} · '
              '${format.instantRange(overlap.start, overlap.end)}',
            ),
    TooManyActiveBookings(:final max) =>
      max == null
          ? l10n.bookingFailTooManyGeneric
          : l10n.bookingFailTooMany(max),
    NotPermitted() => l10n.bookingFailNotPermitted,
    NotFound() => l10n.bookingFailNotFound,
    _ => l10n.bookingFailGeneric,
  };
}

/// The words of a [ScheduleNotice].
String scheduleNoticeMessage(BuildContext context, ScheduleNotice notice) {
  if (notice.choiceGone) {
    return AppLocalizations.of(context).bookingChoiceGone;
  }
  return bookingFailureMessage(
    context,
    notice.failure!,
    overlap: notice.overlap,
  );
}
