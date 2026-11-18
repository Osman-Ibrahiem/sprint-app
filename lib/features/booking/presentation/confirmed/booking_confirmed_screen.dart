import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/adaptive/adaptive_app_bar.dart';
import 'package:sprint/core/adaptive/adaptive_pressable.dart';
import 'package:sprint/core/l10n/directional_icon.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/motion/skeleton.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/booking_ticket/booking_ticket.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/core/widgets/status_badge/sprint_status.dart';
import 'package:sprint/core/window/window_size.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';
import 'package:sprint/features/booking/presentation/checkout/moment_placeholder.dart';
import 'package:sprint/features/booking/presentation/lead_time_text.dart';
import 'package:sprint/features/booking/presentation/providers/checkout_providers.dart';
import 'package:sprint/features/booking/presentation/widgets/empty_state.dart';
import 'package:sprint/features/payments/domain/payment.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The confirmation ticket of a paid or a free booking (US-12, BR-19, BR-28):
/// the success moment, the reminder lead, the ticket with its QR and code, the
/// cancellation line, a link to the receipt (paid only) and the way home. It
/// is reached with `go`, so there is no way back to payment. A booking that is
/// not confirmed (yet) is sent to its checkout.
class BookingConfirmedScreen extends ConsumerStatefulWidget {
  const BookingConfirmedScreen({required this.bookingId, super.key});

  final String bookingId;

  static const homeKey = ValueKey<String>('confirmed-home');
  static const receiptKey = ValueKey<String>('confirmed-receipt');
  static const notFoundKey = ValueKey<String>('confirmed-not-found');
  static const subtitleKey = ValueKey<String>('confirmed-subtitle');

  @override
  ConsumerState<BookingConfirmedScreen> createState() =>
      _BookingConfirmedScreenState();
}

class _BookingConfirmedScreenState
    extends ConsumerState<BookingConfirmedScreen> {
  bool _redirected = false;

  void _redirect(String location) {
    if (_redirected) return;
    _redirected = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go(location);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final id = widget.bookingId;
    final async = ref.watch(bookingCheckoutProvider(id));
    final summary = ref.watch(checkoutSummaryProvider(id));
    final settings = ref.watch(checkoutSettingsProvider(id)).value;

    final state = async.value;
    if (state == null && !async.isLoading) return _notFound(context);
    if (state == null || summary.value == null || settings == null) {
      return _loading(context);
    }
    final b = state.booking;
    if (b.status == BookingStatus.pendingPayment ||
        b.status == BookingStatus.expired) {
      _redirect(AppPaths.bookingCheckoutFor(b.facilityId, b.id));
      return _loading(context);
    }
    if (b.status != BookingStatus.confirmed &&
        b.status != BookingStatus.attended &&
        b.status != BookingStatus.noShow) {
      return _notFound(context);
    }

    final view = summary.value!;
    final paid = state.latestPayment?.status == PaymentStatus.succeeded
        ? state.latestPayment
        : null;
    final now = ref.read(appClockProvider).now();
    final format = SprintFormat.of(context);
    final free = b.priceAtBooking == 0;
    final cancelUntil = b.start.subtract(
      Duration(hours: settings.cancellationCutoffHours),
    );

    final message = _Message(
      lead: leadTimeText(l10n, settings.reminderLeadMinutes),
    );
    final ticket = BookingTicket(
      state: cairoDayOf(b.start) == cairoDayOf(now)
          ? BookingTicketState.today
          : BookingTicketState.upcoming,
      status: SprintStatus.confirmed,
      facilityName: view.facilityName,
      unitName: view.unitName,
      trainerName: view.trainerName,
      // The ticket formats Cairo wall-clock times (as the schedule does);
      // the booking stores UTC instants.
      start: CairoTime.toCairo(b.start),
      end: CairoTime.toCairo(b.end),
      code: b.code,
      qrToken: b.qrToken,
      paid: free ? l10n.bookingFree : format.price(b.priceAtBooking),
      priceLabel: free ? l10n.bookingRowPrice : null,
      cancelUntil: now.isBefore(cancelUntil) ? cancelUntil : null,
      onCodeCopied: () {
        SemanticsService.sendAnnouncement(
          View.of(context),
          l10n.ticketCopied,
          Directionality.of(context),
        );
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text(l10n.ticketCopied)),
        );
      },
    );
    final receipt = paid == null ? null : _ReceiptRow(bookingId: id);
    final home = SprintButton(
      key: BookingConfirmedScreen.homeKey,
      label: l10n.backToHome,
      variant: SprintButtonVariant.ghost,
      onPressed: () => context.go(AppPaths.home),
    );

    return Column(
      children: [
        AdaptiveAppBar(
          title: l10n.confirmedTitle,
          leading: const SizedBox.shrink(),
        ),
        Expanded(
          // Two columns need the room for both (358 + 48 + 358 and the
          // margins): a sidebar leaves less than the window class suggests.
          child: LayoutBuilder(
            builder: (context, box) =>
                box.maxWidth >= SprintExtras.confirmationTwoColumnsMinWidth
                ? _wide(message, ticket, receipt, home)
                : _narrow(context, message, ticket, receipt, home),
          ),
        ),
      ],
    );
  }

  /// Compact and medium: one column; on compact the way home sits in a fixed
  /// bar, from medium it ends the column.
  Widget _narrow(
    BuildContext context,
    Widget message,
    Widget ticket,
    Widget? receipt,
    Widget home,
  ) {
    final compact = WindowSize.of(context).isCompact;
    final colors = context.colors;
    final content = ListView(
      padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: SprintExtras.centredColumn,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                message,
                const SizedBox(height: SprintSpacing.space4),
                ticket,
                if (receipt != null) ...[
                  const SizedBox(height: SprintSpacing.space4),
                  receipt,
                ],
                if (!compact) ...[
                  const SizedBox(height: SprintSpacing.space4),
                  home,
                ],
              ],
            ),
          ),
        ),
      ],
    );
    if (!compact) return content;
    return Column(
      children: [
        Expanded(child: content),
        Container(
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
          child: SafeArea(top: false, child: home),
        ),
      ],
    );
  }

  /// From expanded: the ticket beside the message and the buttons.
  Widget _wide(Widget message, Widget ticket, Widget? receipt, Widget home) {
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.all(SprintSpacing.space6),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: SprintExtras.confirmationColumn, child: ticket),
            const SizedBox(width: SprintExtras.confirmationGap),
            SizedBox(
              width: SprintExtras.confirmationColumn,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  message,
                  if (receipt != null) ...[
                    const SizedBox(height: SprintSpacing.space4),
                    receipt,
                  ],
                  const SizedBox(height: SprintSpacing.space4),
                  home,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loading(BuildContext context) => Column(
    children: [
      AdaptiveAppBar(
        title: AppLocalizations.of(context).confirmedTitle,
        leading: const SizedBox.shrink(),
      ),
      Expanded(
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
          children: const [
            Skeleton(height: SprintExtras.dayPillHeight * 3),
            SizedBox(height: SprintSpacing.space4),
            Skeleton(height: SprintSize.controlHeight),
          ],
        ),
      ),
    ],
  );

  Widget _notFound(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        AdaptiveAppBar(title: l10n.confirmedTitle),
        Expanded(
          child: EmptyState(
            key: BookingConfirmedScreen.notFoundKey,
            icon: PhosphorIconsRegular.ticket,
            title: l10n.bookingDoneNotFoundTitle,
            body: l10n.bookingDoneNotFoundBody,
            actionLabel: l10n.backToHome,
            onAction: () => context.go(AppPaths.home),
          ),
        ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.lead});

  final String lead;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return Column(
      children: [
        MomentPlaceholder(
          kind: MomentKind.success,
          title: l10n.confirmedTitle,
          announce: true,
        ),
        const SizedBox(height: SprintSpacing.space2),
        Text(
          l10n.confirmedSubtitle(lead),
          key: BookingConfirmedScreen.subtitleKey,
          style: context.text.body.copyWith(color: colors.inkMuted),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// "إيصال الدفع": a row that opens the receipt (paid bookings only).
class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return AdaptivePressable(
      key: BookingConfirmedScreen.receiptKey,
      label: l10n.confirmedReceiptRow,
      onTap: () => context.push(AppPaths.bookingReceipt(bookingId)),
      restingColor: colors.surface,
      hoverColor: colors.surfaceSunken,
      borderRadius: SprintRadius.lgBorder,
      builder: (context, s) => Container(
        constraints: const BoxConstraints(minHeight: SprintSize.controlHeight),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: SprintSpacing.space4,
          vertical: SprintSpacing.space3,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                l10n.confirmedReceiptRow,
                style: context.text.bodyStrong,
              ),
            ),
            DirectionalIcon(
              PhosphorIconsRegular.caretRight,
              size: SprintSize.iconMd,
              color: colors.inkMuted,
            ),
          ],
        ),
      ),
    );
  }
}
