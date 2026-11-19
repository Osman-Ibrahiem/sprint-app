import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/adaptive/adaptive_app_bar.dart';
import 'package:sprint/core/adaptive/adaptive_back_button.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/motion/skeleton.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/booking_ticket/booking_ticket.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';
import 'package:sprint/features/booking/presentation/bookings/booking_row_data.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/booking/presentation/details/details_actions.dart';
import 'package:sprint/features/booking/presentation/details/receipt_link.dart';
import 'package:sprint/features/booking/presentation/details/status_banner.dart';
import 'package:sprint/features/booking/presentation/providers/my_bookings_providers.dart';
import 'package:sprint/features/booking/presentation/widgets/empty_state.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The details of one booking of the signed-in person for every status
/// (US-13, US-14, FR-MYB-02, BR-17, BR-30). Pushed on compact; the detail pane
/// of "حجوزاتي" from the medium class. Another person's booking id shows the
/// not-found state and reveals nothing (FR-009).
class BookingDetailsScreen extends StatelessWidget {
  const BookingDetailsScreen({required this.bookingId, super.key});

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        AdaptiveAppBar(
          title: l10n.bookingDetailsTitle,
          leading: AdaptiveBackButton(
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go(AppPaths.bookings),
          ),
        ),
        Expanded(child: BookingDetailsView(bookingId: bookingId)),
      ],
    );
  }
}

/// The body of the details, with no app bar: used as the pane too.
class BookingDetailsView extends ConsumerStatefulWidget {
  const BookingDetailsView({required this.bookingId, super.key});

  final String bookingId;

  static const notFoundKey = ValueKey<String>('details-not-found');
  static const tierKey = ValueKey<String>('details-tier');

  @override
  ConsumerState<BookingDetailsView> createState() => _BookingDetailsViewState();
}

class _BookingDetailsViewState extends ConsumerState<BookingDetailsView> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    // The hold countdown and the cutoff follow the clock; the repository
    // writes (no-show, expiry) already refresh the provider.
    _tick = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) {
        ref.invalidate(bookingDetailsProvider(widget.bookingId));
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(bookingDetailsProvider(widget.bookingId));
    final now = ref.watch(appClockProvider).now();

    return async.when(
      loading: () => const Padding(
        padding: EdgeInsetsDirectional.all(SprintSpacing.space4),
        child: Skeleton(height: SprintExtras.bookingRowHeight),
      ),
      error: (_, _) => EmptyState(
        icon: PhosphorIconsRegular.warningCircle,
        title: l10n.bookingsLoadError,
        actionLabel: l10n.bookingsRetry,
        onAction: () => ref.invalidate(bookingDetailsProvider(widget.bookingId)),
      ),
      data: (details) {
        if (details == null) return _notFound(context, l10n);
        return _content(context, l10n, details, now);
      },
    );
  }

  Widget _notFound(BuildContext context, AppLocalizations l10n) => EmptyState(
    key: BookingDetailsView.notFoundKey,
    icon: PhosphorIconsRegular.ticket,
    title: l10n.bookingDetailsNotFoundTitle,
    body: l10n.bookingDetailsNotFoundBody,
    actionLabel: l10n.bookingDetailsBackToBookings,
    onAction: () => context.go(AppPaths.bookings),
  );

  Widget _content(
    BuildContext context,
    AppLocalizations l10n,
    BookingDetails d,
    DateTime now,
  ) {
    final format = SprintFormat.of(context);
    final b = d.booking;
    final free = b.priceAtBooking == 0;
    final live = b.status == BookingStatus.confirmed;
    final today = cairoDayOf(b.start) == cairoDayOf(now);
    final price = format.price(b.priceAtBooking);

    // The amount row follows the status: paid, still due, or never paid.
    final (label, value) = switch (b.status) {
      _ when free => (l10n.bookingDetailsPrice, l10n.bookingDetailsFree),
      BookingStatus.pendingPayment => (l10n.bookingDetailsRequired, price),
      BookingStatus.expired => (
        l10n.bookingDetailsAmount,
        '$price · ${l10n.bookingDetailsNotPaid}',
      ),
      _ when d.paidAmount == 0 => (
        l10n.bookingDetailsAmount,
        '$price · ${l10n.bookingDetailsNotPaid}',
      ),
      _ => (l10n.bookingDetailsPaid, format.price(d.paidAmount)),
    };

    final trainer = d.trainerUser?.name;
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.fromSTEB(
        SprintSpacing.space4,
        SprintSpacing.space4,
        SprintSpacing.space4,
        SprintSpacing.space6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StatusBanner(details: d, now: now),
          const SizedBox(height: SprintSpacing.space3),
          BookingTicket(
            state: live
                ? (today
                      ? BookingTicketState.today
                      : BookingTicketState.upcoming)
                : BookingTicketState.past,
            status: sprintStatusOf(b.status),
            facilityName: d.facility.name,
            unitName: d.unit.name,
            trainerName: trainer,
            start: CairoTime.toCairo(b.start),
            end: CairoTime.toCairo(b.end),
            code: b.code,
            qrToken: live ? b.qrToken : null,
            paid: value,
            priceLabel: label,
            cancelUntil: live && d.cancelPreview.canCancel
                ? CairoTime.toCairo(d.cancelPreview.cancelUntil)
                : null,
          ),
          const SizedBox(height: SprintSpacing.space3),
          _TierRow(tier: b.tierAtBooking),
          if (d.hasSucceededPayment) ...[
            const SizedBox(height: SprintSpacing.space3),
            ReceiptLink(bookingId: b.id),
          ],
          const SizedBox(height: SprintSpacing.space4),
          DetailsActions(details: d),
          const SizedBox(height: SprintSpacing.space4),
        ],
      ),
    );
  }
}

class _TierRow extends StatelessWidget {
  const _TierRow({required this.tier});

  final PriceTier tier;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final internal = tier == PriceTier.internal;
    return Row(
      key: BookingDetailsView.tierKey,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.bookingDetailsTier,
          style: context.text.body.copyWith(color: colors.inkMuted),
        ),
        Text(
          internal
              ? l10n.bookingDetailsTierInternal
              : l10n.bookingDetailsTierExternal,
          style: context.text.bodyStrong.copyWith(color: colors.ink),
        ),
      ],
    );
  }
}
