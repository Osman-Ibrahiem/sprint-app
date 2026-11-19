import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/app/shell/placeholders/placeholder_page.dart';
import 'package:sprint/app/shell/placeholders/sign_in_prompt.dart';
import 'package:sprint/app/shell/root_header.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/segmented_control/segmented_control.dart';
import 'package:sprint/core/window/display_feature_layout.dart';
import 'package:sprint/core/window/window_size.dart';
import 'package:sprint/features/booking/presentation/bookings/bookings_list.dart';
import 'package:sprint/features/booking/presentation/details/booking_details_screen.dart';
import 'package:sprint/features/booking/presentation/providers/my_bookings_providers.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// "حجوزاتي" (US-14, FR-MYB-02): the upcoming and past lists. Compact shows
/// the list, and a row pushes the details; from the medium class the list sits
/// beside the details of the selected booking (the first row is selected when
/// none is), and the selection lives in the address so folding keeps it. A
/// guest sees the account gate, as before.
class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({this.selectedId, this.segment, super.key});

  /// The booking in the address (`/bookings/<id>`), if any.
  final String? selectedId;

  /// The segment in the address (`?seg=`); upcoming by default.
  final BookingSegment? segment;

  static const segmentKey = ValueKey<String>('bookings-segments');
  static const listPaneKey = ValueKey<String>('bookings-list-pane');
  static const detailPaneKey = ValueKey<String>('bookings-detail-pane');
  static const noneSelectedKey = ValueKey<String>('bookings-none-selected');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(currentSessionProvider);
    if (session.isGuest) {
      return PlaceholderPage(
        title: l10n.bookingsTitle,
        leading: const [SizedBox(height: SprintSpacing.space4), SignInPrompt()],
        showNote: false,
        blocks: 0,
      );
    }

    final size = WindowSize.of(context);
    final upcoming = ref.watch(myBookingsProvider(BookingSegment.upcoming));
    final past = ref.watch(myBookingsProvider(BookingSegment.past));
    final seg =
        segment ??
        (GoRouterState.of(context).uri.queryParameters['seg'] == 'past'
            ? BookingSegment.past
            : BookingSegment.upcoming);
    final active = seg == BookingSegment.upcoming ? upcoming : past;
    final hasUpcoming = (upcoming.value ?? const []).isNotEmpty;
    final hasPast = (past.value ?? const []).isNotEmpty;
    final firstId = (active.value ?? const []).isEmpty
        ? null
        : active.value!.first.id;
    // Wide: the address wins; otherwise the first row of the segment.
    final wide = !size.isCompact;
    final inSegment = (active.value ?? const []).any((b) => b.id == selectedId);
    final selected = wide ? (inSegment ? selectedId : firstId) : null;

    void open(String id) => context.go(_location(id, seg));
    void setSegment(int i) {
      final next = i == 0 ? BookingSegment.upcoming : BookingSegment.past;
      context.go(
        wide ? _location(null, next) : _location(null, next),
      );
    }

    final upcomingCount = upcoming.value?.length ?? 0;
    final labels = [
      upcomingCount > 0
          ? l10n.bookingsSegmentUpcoming(upcomingCount)
          : l10n.bookingsSegmentUpcomingPlain,
      l10n.bookingsSegmentPast,
    ];
    final list = Padding(
      key: listPaneKey,
      padding: EdgeInsetsDirectional.only(
        start: wide ? SprintSpacing.space6 : SprintSpacing.space4,
        end: wide ? SprintSpacing.space6 : SprintSpacing.space4,
        top: SprintSpacing.space2,
      ),
      child: SafeArea(
        bottom: false,
        child: BookingsList(
          segment: seg,
          selectedId: selected,
          hasUpcoming: hasUpcoming,
          hasPast: hasPast,
          onOpen: open,
          header: [
            const SizedBox(height: SprintSpacing.space4),
            RootHeader(
              title: Text(l10n.bookingsTitle, style: context.text.titleLg),
            ),
            const SizedBox(height: SprintSpacing.space5),
            SegmentedControl(
              key: segmentKey,
              labels: labels,
              semanticLabels: [
                upcomingCount > 0
                    ? l10n.bookingsSegmentUpcomingSpoken(upcomingCount)
                    : l10n.bookingsSegmentUpcomingPlain,
                l10n.bookingsSegmentPast,
              ],
              selected: seg == BookingSegment.upcoming ? 0 : 1,
              onChanged: setSegment,
            ),
            const SizedBox(height: SprintSpacing.space5),
          ],
        ),
      ),
    );

    if (!wide) return list;

    final listWidth = switch (size) {
      WindowSize.expanded => SprintExtras.bookingsListPaneExpanded,
      WindowSize.large => SprintExtras.bookingsListPaneLarge,
      _ => SprintExtras.medium007ListPane,
    };
    final detail = KeyedSubtree(
      key: detailPaneKey,
      child: _DetailPane(bookingId: selected),
    );
    final features = MediaQuery.of(context).displayFeatures.where(
      DisplayFeatureLayout.separates,
    );
    if (features.isNotEmpty) return DisplayFeatureLayout(start: list, end: detail);
    return Row(
      children: [
        SizedBox(width: listWidth, child: list),
        Expanded(child: detail),
      ],
    );
  }

  static String _location(String? id, BookingSegment seg) {
    final path = id == null ? AppPaths.bookings : AppPaths.bookingDetails(id);
    return seg == BookingSegment.past ? '$path?seg=past' : path;
  }
}

class _DetailPane extends StatelessWidget {
  const _DetailPane({required this.bookingId});

  final String? bookingId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    if (bookingId == null) {
      return Center(
        key: MyBookingsScreen.noneSelectedKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SprintIcon(
              PhosphorIconsRegular.ticket,
              size: SprintSize.iconLg,
              color: colors.inkMuted,
            ),
            const SizedBox(height: SprintSpacing.space3),
            Text(
              l10n.bookingsNoneSelected,
              style: context.text.body.copyWith(color: colors.inkMuted),
            ),
          ],
        ),
      );
    }
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              SprintSpacing.space6,
              SprintSpacing.space6,
              SprintSpacing.space6,
              0,
            ),
            child: Semantics(
              header: true,
              child: Text(
                l10n.bookingDetailsTitle,
                style: context.text.title.copyWith(color: colors.ink),
              ),
            ),
          ),
          Expanded(child: BookingDetailsView(bookingId: bookingId!)),
        ],
      ),
    );
  }
}
