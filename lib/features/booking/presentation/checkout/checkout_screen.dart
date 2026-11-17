import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/adaptive/adaptive_app_bar.dart';
import 'package:sprint/core/adaptive/adaptive_back_button.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/motion/skeleton.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/booking_repository.dart';
import 'package:sprint/features/booking/domain/booking_summary_view.dart';
import 'package:sprint/features/booking/domain/checkout_view.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';
import 'package:sprint/features/booking/presentation/checkout/awaiting_view.dart';
import 'package:sprint/features/booking/presentation/checkout/cancelled_notice.dart';
import 'package:sprint/features/booking/presentation/checkout/checkout_layout.dart';
import 'package:sprint/features/booking/presentation/checkout/checkout_policy_card.dart';
import 'package:sprint/features/booking/presentation/checkout/expired_view.dart';
import 'package:sprint/features/booking/presentation/checkout/failed_header.dart';
import 'package:sprint/features/booking/presentation/checkout/hold_banner.dart';
import 'package:sprint/features/booking/presentation/checkout/leave_checkout_dialog.dart';
import 'package:sprint/features/booking/presentation/checkout/payment_method_card.dart';
import 'package:sprint/features/booking/presentation/checkout/processing_view.dart';
import 'package:sprint/features/booking/presentation/providers/checkout_providers.dart';
import 'package:sprint/features/booking/presentation/summary/summary_rows.dart';
import 'package:sprint/features/booking/presentation/widgets/empty_state.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Checkout of one booking (feature 006). One screen whose state comes from
/// the booking and its latest payment, never from the route (FR-024):
/// holding, last minute, processing, awaiting, failed, cancelled, expired.
/// It only asks the provider to start and watches the booking; only the
/// provider's answer confirms (BR-28).
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({
    required this.facilityId,
    required this.bookingId,
    super.key,
  });

  final String facilityId;
  final String bookingId;

  static const payKey = ValueKey<String>('checkout-pay');
  static const errorKey = ValueKey<String>('checkout-error');
  static const notFoundKey = ValueKey<String>('checkout-not-found');

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _starting = false;
  bool _refreshing = false;
  bool _leaving = false;
  bool _wentToTicket = false;
  String? _error;

  String get _id => widget.bookingId;

  Future<void> _pay() async {
    if (_starting) return;
    final user = ref.read(currentSessionProvider).user;
    if (user == null) return;
    setState(() {
      _starting = true;
      _error = null;
    });
    final result = await ref
        .read(bookingRepositoryProvider)
        .startPayment(_id, user.id);
    if (!mounted) return;
    switch (result) {
      case Err(:final failure):
        // The Hold is unchanged. An expired Hold shows the expired state by
        // itself; anything else says so in words and stays ready to retry.
        setState(() {
          _starting = false;
          _error = failure is HoldExpired
              ? null
              : AppLocalizations.of(context).checkoutStartError;
        });
      case Ok(:final value):
        setState(() => _starting = false);
        await context.push(value.checkoutLocation.toString());
        if (!mounted) return;
        // Processing is counted from the return, or from the payment's start,
        // whichever is later.
        ref
            .read(checkoutReturnedAtProvider(_id).notifier)
            .mark(ref.read(appClockProvider).now());
    }
  }

  Future<void> _refresh() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    await ref.read(bookingRepositoryProvider).refreshPayment(_id);
    if (mounted) setState(() => _refreshing = false);
  }

  /// BR-47: one handler for the app-bar back, the system back and the browser
  /// back. Leaving releases the place and returns to the same summary.
  Future<void> _askLeave(Booking booking) async {
    if (_leaving) return;
    final leave = await confirmLeaveCheckout(context);
    if (!leave || !mounted) return;
    final user = ref.read(currentSessionProvider).user;
    if (user == null) return;
    setState(() => _leaving = true);
    await ref.read(bookingRepositoryProvider).leaveCheckout(_id, user.id);
    if (!mounted) return;
    context.go(
      AppPaths.bookingSummary(
        booking.facilityId,
        ScheduleSelection(
          day: cairoDayOf(booking.start),
          unitId: booking.unitId,
          trainerId: booking.trainerId,
          startMinutes: cairoMinutesOf(booking.start),
          endMinutes:
              cairoMinutesOf(booking.start) +
              booking.end.difference(booking.start).inMinutes,
        ),
      ),
    );
  }

  void _goToTicket() {
    if (_wentToTicket) return;
    _wentToTicket = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go(AppPaths.bookingConfirmed(_id));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final view = ref.watch(checkoutViewProvider(_id));
    final state = ref.watch(bookingCheckoutProvider(_id)).value;
    final summary = ref.watch(checkoutSummaryProvider(_id)).value;
    final remaining = ref.watch(holdCountdownProvider(_id));

    if (view == CheckoutView.confirmed) {
      _goToTicket();
      return const _Loading();
    }
    if (view == null || (summary == null && view != CheckoutView.notFound)) {
      return Column(
        children: [
          AdaptiveAppBar(title: l10n.checkoutTitle),
          const Expanded(child: _Loading()),
        ],
      );
    }
    switch (view) {
      case CheckoutView.notFound:
        return Column(
          children: [
            AdaptiveAppBar(title: l10n.checkoutTitle),
            Expanded(
              child: EmptyState(
                key: CheckoutScreen.notFoundKey,
                icon: PhosphorIconsRegular.ticket,
                title: l10n.bookingDoneNotFoundTitle,
                body: l10n.bookingDoneNotFoundBody,
                actionLabel: l10n.backToHome,
                onAction: () => context.go(AppPaths.home),
              ),
            ),
          ],
        );
      case CheckoutView.expired:
        return ExpiredView(facilityId: widget.facilityId, summary: summary);
      case CheckoutView.processing:
        return ProcessingView(summary: summary!, remaining: remaining);
      case CheckoutView.awaiting:
        return AwaitingView(
          summary: summary!,
          remaining: remaining,
          refreshing: _refreshing,
          onRefresh: _refresh,
        );
      case CheckoutView.holding ||
          CheckoutView.lastMinute ||
          CheckoutView.failed ||
          CheckoutView.cancelled:
        return _form(context, view, state!, summary!, remaining);
      case CheckoutView.confirmed:
        return const _Loading();
    }
  }

  Widget _form(
    BuildContext context,
    CheckoutView view,
    BookingCheckoutState state,
    BookingSummaryView summary,
    Duration? remaining,
  ) {
    final l10n = AppLocalizations.of(context);
    final format = SprintFormat.of(context);
    final settings = ref.watch(checkoutSettingsProvider(_id)).value;
    final failed = view == CheckoutView.failed;
    final amount = format.price(summary.amount);

    final button = Semantics(
      container: true,
      explicitChildNodes: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_error != null) ...[
            Semantics(
              liveRegion: true,
              child: Text(
                _error!,
                key: CheckoutScreen.errorKey,
                style: context.text.body.copyWith(color: context.colors.danger),
              ),
            ),
            const SizedBox(height: SprintSpacing.space2),
          ],
          Semantics(
            button: true,
            enabled: !_starting,
            label: failed
                ? l10n.checkoutRetry(amount)
                : l10n.checkoutPaySpoken(summary.amount),
            excludeSemantics: true,
            onTap: _starting ? null : _pay,
            child: SprintButton(
              key: CheckoutScreen.payKey,
              label: failed ? l10n.checkoutRetry(amount) : l10n.checkoutPay(amount),
              loading: _starting,
              onPressed: _starting ? null : _pay,
            ),
          ),
        ],
      ),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _askLeave(state.booking);
      },
      child: Column(
        children: [
          AdaptiveAppBar(
            title: failed ? l10n.bookingSummaryTitle : l10n.checkoutTitle,
            leading: AdaptiveBackButton(onPressed: () => _askLeave(state.booking)),
          ),
          Expanded(
            child: CheckoutLayout(
              title: failed ? l10n.bookingSummaryTitle : l10n.checkoutTitle,
              summaryTitle: l10n.bookingSummaryTitle,
              lead: failed
                  ? const FailedHeader()
                  : view == CheckoutView.cancelled
                  ? const CancelledNotice()
                  : null,
              banner: HoldBanner(remaining: remaining ?? Duration.zero),
              summary: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SummaryRows(view: summary, showPolicy: false),
                  const SizedBox(height: SprintSpacing.space4),
                  CheckoutPolicyCard(
                    start: summary.start,
                    cutoffHours: summary.quote.cancellationCutoffHours,
                    refundPercent: summary.quote.refundPercent,
                  ),
                ],
              ),
              method: PaymentMethodCard(showTestTag: settings?.isTestProvider ?? false),
              action: button,
            ),
          ),
        ],
      ),
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
