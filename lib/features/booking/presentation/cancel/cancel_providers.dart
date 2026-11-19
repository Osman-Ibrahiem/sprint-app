import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/cancel_preview.dart';

/// What a cancel attempt came to: the screen only shows this.
sealed class CancelOutcome {
  const CancelOutcome();
}

class CancelDone extends CancelOutcome {
  const CancelDone(this.booking);
  final Booking booking;
}

/// The cutoff passed while the dialog was open (BR-30): nothing changed.
class CancelClosed extends CancelOutcome {
  const CancelClosed();
}

/// Cancelled a moment ago by somebody else, or by the same person elsewhere.
class CancelAlready extends CancelOutcome {
  const CancelAlready();
}

class CancelRefused extends CancelOutcome {
  const CancelRefused();
}

/// The cancel dialog's two calls: [preview] on open, [confirm] on accept. The
/// repository re-checks everything, so a stale dialog can never cancel late.
class CancelActions {
  const CancelActions(this._ref);

  final Ref _ref;

  Future<CancelPreview> preview(String bookingId) {
    final user = _ref.read(currentSessionProvider).user!;
    return _ref.read(bookingRepositoryProvider).previewCancel(bookingId, user.id);
  }

  Future<CancelOutcome> confirm(String bookingId) async {
    final user = _ref.read(currentSessionProvider).user!;
    final repo = _ref.read(bookingRepositoryProvider);
    final before = await repo.get(bookingId);
    final wasCancelled =
        before is Ok<Booking> && before.value.status == BookingStatus.cancelled;
    final result = await repo.cancel(bookingId, user.id);
    return switch (result) {
      Ok(:final value) =>
        wasCancelled ? const CancelAlready() : CancelDone(value),
      Err(:final failure) => failure is CancellationClosed
          ? const CancelClosed()
          : const CancelRefused(),
    };
  }
}

final cancelActionsProvider = Provider<CancelActions>(CancelActions.new);
