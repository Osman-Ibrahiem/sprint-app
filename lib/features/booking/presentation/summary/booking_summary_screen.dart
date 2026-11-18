import 'package:flutter/material.dart' hide Banner;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/adaptive/adaptive_app_bar.dart';
import 'package:sprint/core/adaptive/adaptive_back_button.dart';
import 'package:sprint/core/motion/skeleton.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/booking_summary_view.dart';
import 'package:sprint/features/booking/domain/schedule_notice.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';
import 'package:sprint/features/booking/presentation/providers/booking_providers.dart';
import 'package:sprint/features/booking/presentation/summary/summary_rows.dart';
import 'package:sprint/features/booking/presentation/widgets/booking_error_view.dart';
import 'package:sprint/core/widgets/banner/banner.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The summary before anything is created or paid (FR-024 – FR-031). "متابعة
/// للدفع" creates the booking with its Hold and opens its checkout (feature
/// 006, BR-12); a free booking is confirmed at once and opens its ticket
/// (BR-19).
class BookingSummaryScreen extends ConsumerStatefulWidget {
  const BookingSummaryScreen({
    required this.facilityId,
    required this.selection,
    this.shown,
    super.key,
  });

  final String facilityId;
  final ScheduleSelection selection;

  /// The amount the schedule displayed, to say when the price changed.
  final int? shown;

  static const actionKey = ValueKey<String>('summary-action');
  static const priceChangedKey = ValueKey<String>('summary-price-changed');
  static const verifyKey = ValueKey<String>('summary-verify');

  @override
  ConsumerState<BookingSummaryScreen> createState() =>
      _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends ConsumerState<BookingSummaryScreen> {
  bool _busy = false;
  bool _failed = false;

  /// Set when this screen sends the person back, so it does so only once.
  bool _left = false;

  BookingSummaryProvider get _provider =>
      bookingSummaryProvider(widget.facilityId, widget.selection, widget.shown);

  @override
  void initState() {
    super.initState();
    // The answer may already be here (a cached family): the listener in build
    // only hears changes.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final current = ref.read(_provider);
      final result = current.hasValue ? current.value : null;
      if (result is Err<BookingSummaryView> &&
          !ref.read(currentSessionProvider).isGuest) {
        _backWithNotice(result.failure);
      }
    });
  }

  /// Back to the schedule with the time cleared and the refusal explained.
  void _backWithNotice(Failure failure) {
    if (_left) return;
    _left = true;
    ref
        .read(pendingScheduleNoticeProvider.notifier)
        .put(ScheduleNotice.failure(failure));
    context.go(
      AppPaths.facilitySchedule(
        widget.facilityId,
        widget.selection.clearTime(),
      ),
    );
  }

  void _back() => context.canPop()
      ? context.pop()
      : context.go(
          AppPaths.facilitySchedule(widget.facilityId, widget.selection),
        );

  /// Creates the booking, once (BR-11, BR-19, FR-002, FR-029). Every check
  /// runs again inside `create`, so someone may have taken the place since the
  /// summary opened. A paid booking starts its Hold and goes to checkout; a
  /// free one is confirmed at once and goes to its ticket. The flag is set
  /// before the first await, so a second tap while this runs does nothing and
  /// at most one booking is created.
  Future<void> _submit() async {
    if (_busy) return;
    final user = ref.read(currentSessionProvider).user;
    final request = user == null ? null : widget.selection.toRequest(user.id);
    if (request == null) return;
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      final result = await ref.read(bookingRepositoryProvider).create(request);
      if (!mounted) return;
      switch (result) {
        case Err(:final failure):
          setState(() => _busy = false);
          _backWithNotice(failure);
        case Ok(:final value):
          // Stay busy: this screen is being left, and back from the next one
          // must not offer to create a second booking.
          context.go(
            value.status == BookingStatus.pendingPayment
                ? AppPaths.bookingCheckoutFor(widget.facilityId, value.id)
                : AppPaths.bookingConfirmed(value.id),
          );
      }
    } on Object {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(_provider);
    // A refusal sends the person back once, from the provider's answer and not
    // from build, so a rebuild cannot navigate twice.
    ref.listen(_provider, (_, next) {
      final result = next.hasValue ? next.value : null;
      // A signed-out person is the router's to send to sign-in.
      if (result is Err<BookingSummaryView> &&
          mounted &&
          !ref.read(currentSessionProvider).isGuest) {
        _backWithNotice(result.failure);
      }
    });

    Widget body;
    BookingSummaryView? view;
    if (ref.watch(currentSessionProvider).isGuest) {
      // Signed out while here: the router sends the person to sign-in and back
      // to this location, so this screen only waits (contracts/routes.md).
      body = const _Loading();
    } else if (async.hasError && !async.hasValue) {
      body = BookingErrorView(onRetry: () => ref.invalidate(_provider));
    } else if (!async.hasValue) {
      body = const _Loading();
    } else {
      final result = async.value!;
      switch (result) {
        case Err():
          // The listener above sends the person back to the schedule.
          body = const _Loading();
        case Ok(:final value):
          view = value;
          body = _Body(view: value);
      }
    }

    return Column(
      children: [
        AdaptiveAppBar(
          title: l10n.bookingSummaryTitle,
          leading: AdaptiveBackButton(onPressed: _back),
        ),
        Expanded(child: body),
        if (view != null)
          _ActionBar(
            label: view.isFree
                ? l10n.bookingConfirmAction
                : l10n.bookingPayAction,
            busy: _busy,
            failedText: _failed ? l10n.bookingFailGeneric : null,
            onPressed: _submit,
          ),
      ],
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) => ListView(
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
    children: const [
      Skeleton(height: SprintExtras.dayPillHeight * 3),
      SizedBox(height: SprintSpacing.space4),
      Skeleton(height: SprintSize.controlHeight),
    ],
  );
}

class _Body extends StatelessWidget {
  const _Body({required this.view});

  final BookingSummaryView view;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return ListView(
      padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
      children: [
        if (view.priceChanged) ...[
          Banner(
      tone: BannerTone.hold,
            key: BookingSummaryScreen.priceChangedKey,
            text: l10n.bookingPriceChanged,
          ),
          const SizedBox(height: SprintSpacing.space3),
        ],
        SummaryRows(view: view),
        if (view.verificationHint != VerificationHint.none) ...[
          const SizedBox(height: SprintSpacing.space4),
          Container(
            padding: const EdgeInsetsDirectional.all(SprintSpacing.space3),
            decoration: BoxDecoration(
              color: colors.primarySoft,
              borderRadius: SprintRadius.mdBorder,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  view.verificationHint == VerificationHint.underReview
                      ? l10n.bookingVerifyPending
                      : l10n.bookingVerifyHint,
                  style: context.text.body.copyWith(
                    color: colors.onPrimarySoft,
                  ),
                ),
                if (view.verificationHint == VerificationHint.canVerify) ...[
                  const SizedBox(height: SprintSpacing.space2),
                  SprintButton(
                    key: BookingSummaryScreen.verifyKey,
                    label: l10n.bookingVerifyAction,
                    variant: SprintButtonVariant.secondary,
                    size: SprintButtonSize.sm,
                    onPressed: () => context.push(AppPaths.profileVerification),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.label,
    required this.busy,
    required this.onPressed,
    this.failedText,
  });

  final String label;
  final bool busy;
  final VoidCallback onPressed;

  /// A failure that is not a booking rule: said above the action, which stays
  /// ready to retry.
  final String? failedText;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(
            color: colors.line,
            width: SprintExtras.hairlineWidth,
          ),
        ),
      ),
      padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (failedText != null) ...[
              Semantics(
                liveRegion: true,
                child: Text(
                  failedText!,
                  style: context.text.body.copyWith(color: colors.danger),
                ),
              ),
              const SizedBox(height: SprintSpacing.space2),
            ],
            SprintButton(
              key: BookingSummaryScreen.actionKey,
              label: label,
              loading: busy,
              onPressed: busy ? null : onPressed,
            ),
          ],
        ),
      ),
    );
  }
}
