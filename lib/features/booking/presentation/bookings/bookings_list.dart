import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/adaptive/adaptive_refresh.dart';
import 'package:sprint/core/motion/skeleton.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/booking_row/booking_row.dart';
import 'package:sprint/features/booking/presentation/bookings/booking_row_data.dart';
import 'package:sprint/features/booking/presentation/providers/my_bookings_providers.dart';
import 'package:sprint/features/booking/presentation/widgets/empty_state.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The rows of one segment, or its empty state (US-14, FR-MYB-02): skeletons
/// while loading, never a spinner. [header] scrolls with the list.
class BookingsList extends ConsumerWidget {
  const BookingsList({
    required this.segment,
    required this.selectedId,
    required this.hasUpcoming,
    required this.hasPast,
    required this.onOpen,
    this.header = const [],
    super.key,
  });

  final BookingSegment segment;

  /// The selected row (wide only); null draws none.
  final String? selectedId;
  final bool hasUpcoming;
  final bool hasPast;
  final ValueChanged<String> onOpen;
  final List<Widget> header;

  static const emptyKey = ValueKey<String>('bookings-empty');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final rows = ref.watch(myBookingRowsProvider(segment));
    final now = ref.watch(appClockProvider).now();

    Future<void> refresh() async {
      ref.invalidate(myBookingsProvider(segment));
      await ref.read(myBookingRowsProvider(segment).future);
    }

    Widget body(List<Widget> children) => AdaptiveRefresh(
      onRefresh: refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsetsDirectional.only(
          bottom: SprintExtras.screenBottomPadding,
        ),
        children: [...header, ...children],
      ),
    );

    return rows.when(
      loading: () => body([
        for (var i = 0; i < 3; i++) ...[
          const Skeleton(height: SprintExtras.bookingRowHeight),
          const SizedBox(height: SprintSpacing.space5),
        ],
      ]),
      error: (_, _) => body([
        EmptyState(
          icon: PhosphorIconsRegular.warningCircle,
          title: l10n.bookingsLoadError,
          actionLabel: l10n.bookingsRetry,
          onAction: refresh,
        ),
      ]),
      data: (list) {
        if (list.isEmpty) return body([_empty(context, l10n)]);
        return body([
          for (final info in list) ...[
            _row(context, info, now),
            const SizedBox(height: SprintSpacing.space5),
          ],
        ]);
      },
    );
  }

  Widget _row(BuildContext context, BookingRowInfo info, DateTime now) {
    final t = BookingRowTexts.of(context, info, now);
    final b = info.booking;
    return BookingRow(
      status: sprintStatusOf(b.status),
      facilityName: info.facilityName,
      notes: t.notes,
      dateLabel: t.dateLabel,
      isToday: t.isToday,
      code: b.code,
      action: t.action,
      selected: b.id == selectedId,
      semanticLabel: t.spoken,
      onTap: () => onOpen(b.id),
    );
  }

  Widget _empty(BuildContext context, AppLocalizations l10n) {
    final nothing = !hasUpcoming && !hasPast;
    final (title, body) = nothing
        ? (l10n.bookingsEmptyTitle, l10n.bookingsEmptyBody)
        : segment == BookingSegment.upcoming
        ? (l10n.bookingsUpcomingEmptyTitle, l10n.bookingsUpcomingEmptyBody)
        : (l10n.bookingsPastEmptyTitle, null);
    final browse = segment == BookingSegment.upcoming;
    return SizedBox(
      key: emptyKey,
      child: EmptyState(
        icon: PhosphorIconsRegular.ticket,
        title: title,
        body: body,
        actionLabel: browse ? l10n.bookingsBrowse : null,
        actionVariant: SprintButtonVariant.primary,
        onAction: browse ? () => context.go(AppPaths.facilities) : null,
      ),
    );
  }
}
