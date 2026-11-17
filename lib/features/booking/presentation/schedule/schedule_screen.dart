import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/adaptive/adaptive_app_bar.dart';
import 'package:sprint/core/adaptive/adaptive_back_button.dart';
import 'package:sprint/core/adaptive/adaptive_refresh.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';
import 'package:sprint/core/motion/skeleton.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/features/booking/domain/facility_schedule.dart';
import 'package:sprint/features/booking/domain/schedule_notice.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';
import 'package:sprint/features/booking/domain/selection_resolver.dart';
import 'package:sprint/features/booking/presentation/providers/booking_providers.dart';
import 'package:sprint/features/booking/presentation/schedule/price_line.dart';
import 'package:sprint/features/booking/presentation/schedule/schedule_day_section.dart';
import 'package:sprint/features/booking/presentation/schedule/schedule_notice_view.dart';
import 'package:sprint/features/booking/presentation/schedule/slot_grid.dart';
import 'package:sprint/features/booking/presentation/schedule/unit_picker.dart';
import 'package:sprint/features/booking/presentation/widgets/booking_error_view.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The schedule of one facility: days, units and slots over the booking
/// window (feature 005, FR-001 – FR-012). The selection lives in the address,
/// so this screen only reads it, shows its resolved form, and writes changes
/// back without growing the back stack.
class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({
    required this.facilityId,
    required this.selection,
    this.notFound,
    super.key,
  });

  final String facilityId;
  final ScheduleSelection selection;

  /// What to show for a missing or unpublished facility. The app layer hands
  /// the catalogue's screen in, so features do not import each other's
  /// presentation code.
  final WidgetBuilder? notFound;

  static const refreshKey = ValueKey<String>('schedule-refresh');
  static const gridKey = ValueKey<String>('schedule-grid');
  static const emptyKey = ValueKey<String>('schedule-empty');
  static const nothingLeftKey = ValueKey<String>('schedule-nothing-left');
  static const loadingKey = ValueKey<String>('schedule-loading');

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  ScheduleNotice? _notice;
  bool _replacing = false;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _reload);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  FacilityScheduleProvider get _provider => facilityScheduleProvider(
    widget.facilityId,
    widget.selection.trainerId,
  );

  void _reload() {
    if (!mounted) return;
    ref.invalidate(_provider);
    ref.invalidate(myUpcomingBookingsProvider);
  }

  Future<void> _refresh() async {
    _reload();
    await ref.read(_provider.future);
  }

  /// Writes [selection] into the address in place: the same screen updates,
  /// the back stack does not grow, and the browser does not get a history
  /// entry per tap (contracts/routes.md).
  void _write(ScheduleSelection selection) {
    final location = AppPaths.facilitySchedule(widget.facilityId, selection);
    Router.neglect(context, () => context.go(location));
  }

  void _back() => context.canPop()
      ? context.pop()
      : context.go(AppPaths.facilityDetails(widget.facilityId));

  void _clearNotice() {
    if (_notice != null) setState(() => _notice = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(_provider);
    final schedule = async.hasValue ? async.value : null;
    final title = schedule?.facility.name ?? l10n.bookingScheduleHeading;

    final Widget body;
    if (async.hasError && !async.hasValue) {
      body = BookingErrorView(onRetry: _reload);
    } else if (!async.hasValue) {
      body = const _Loading();
    } else if (schedule == null) {
      body =
          widget.notFound?.call(context) ??
          Center(child: Text(l10n.bookingFailNotFound));
    } else {
      body = _Loaded(
        schedule: schedule,
        asked: widget.selection,
        notice: _notice,
        onDismissNotice: _clearNotice,
        onRefresh: _refresh,
        onChange: (s) {
          _clearNotice();
          _write(s);
        },
        onChoiceDropped: _onChoiceDropped,
        onBack: _back,
      );
    }

    return Column(
      children: [
        AdaptiveAppBar(
          title: title,
          leading: AdaptiveBackButton(onPressed: _back),
          actions: [
            if (schedule != null)
              IconButton(
                key: ScheduleScreen.refreshKey,
                tooltip: l10n.bookingRefreshAction,
                constraints: const BoxConstraints(
                  minWidth: SprintSize.controlHeight,
                  minHeight: SprintSize.controlHeight,
                ),
                icon: const SprintIcon(PhosphorIconsRegular.arrowsClockwise),
                onPressed: _reload,
              ),
          ],
        ),
        Expanded(child: body),
      ],
    );
  }

  /// Something the address carried is not valid any more: use the defaults,
  /// say so, and replace the address once (FR-010, FR-012).
  void _onChoiceDropped(ScheduleSelection resolved) {
    if (_replacing) return;
    _replacing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _replacing = false;
      if (!mounted) return;
      setState(() => _notice = const ScheduleNotice.choiceNoLongerAvailable());
      _write(resolved);
    });
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) => ListView(
    key: ScheduleScreen.loadingKey,
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
    children: [
      const Skeleton(height: SprintExtras.dayPillHeight),
      const SizedBox(height: SprintSpacing.space4),
      const Skeleton(height: SprintSize.controlHeight),
      const SizedBox(height: SprintSpacing.space4),
      Wrap(
        spacing: SprintSpacing.space2,
        runSpacing: SprintSpacing.space2,
        children: [
          for (var i = 0; i < 8; i++)
            const Skeleton(
              width: SprintExtras.slotChipMinWidth,
              height: SprintExtras.slotChipMinHeight,
            ),
        ],
      ),
    ],
  );
}

class _Loaded extends ConsumerWidget {
  const _Loaded({
    required this.schedule,
    required this.asked,
    required this.notice,
    required this.onDismissNotice,
    required this.onRefresh,
    required this.onChange,
    required this.onChoiceDropped,
    required this.onBack,
  });

  final FacilitySchedule schedule;
  final ScheduleSelection asked;
  final ScheduleNotice? notice;
  final VoidCallback onDismissNotice;
  final Future<void> Function() onRefresh;
  final ValueChanged<ScheduleSelection> onChange;
  final ValueChanged<ScheduleSelection> onChoiceDropped;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final session = ref.watch(currentSessionProvider);

    final resolved = SelectionResolver.resolve(asked, schedule);
    if (resolved.droppedChoice) onChoiceDropped(resolved.selection);
    final selection = resolved.selection;

    // The trainer step is built with the trainer path.
    if (schedule.needsTrainer) return const SizedBox.shrink();

    if (schedule.units.isEmpty || schedule.days.every((d) => d.isClosed)) {
      return _Empty(
        key: ScheduleScreen.emptyKey,
        title: l10n.bookingNoUnitsTitle,
        body: l10n.bookingNoUnitsBody,
        actionLabel: l10n.bookingBackToFacility,
        onAction: onBack,
      );
    }

    final day = selection.day ?? schedule.defaultDay;
    final unit = schedule.unit(selection.unitId);
    final grid = schedule.gridFor(selection);
    final anyBookable = grid.any((s) => s.isBookable);
    final anyDayHasRoom = schedule.days.any((d) => d.hasAvailability);

    return AdaptiveRefresh(
      onRefresh: onRefresh,
      child: ListView(
        key: ScheduleScreen.gridKey,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
        children: [
          if (notice != null) ...[
            ScheduleNoticeView(notice: notice!, onDismiss: onDismissNotice),
            const SizedBox(height: SprintSpacing.space3),
          ],
          ScheduleDaySection(
            days: schedule.days,
            today: schedule.today,
            selected: day,
            onSelected: (d) => onChange(selection.withDay(d)),
          ),
          const SizedBox(height: SprintSpacing.space4),
          UnitPicker(
            units: schedule.units,
            selectedId: unit?.id,
            hasPlaces: (id) => schedule.unitHasPlacesOn(id, day),
            onSelected: (id) => onChange(selection.withUnit(id)),
          ),
          const SizedBox(height: SprintSpacing.space3),
          PriceLine(
            unit: unit,
            isFree: schedule.facility.isFree,
            session: session,
          ),
          const SizedBox(height: SprintSpacing.space4),
          if (!anyBookable) ...[
            Row(
              children: [
                SprintIcon(
                  PhosphorIconsRegular.calendarX,
                  size: SprintSize.iconMd,
                  color: colors.inkMuted,
                ),
                const SizedBox(width: SprintSpacing.space2),
                Expanded(
                  child: Text(
                    key: ScheduleScreen.nothingLeftKey,
                    anyDayHasRoom
                        ? l10n.bookingNothingLeftDay
                        : l10n.bookingNothingLeftWindow,
                    style: context.text.body.copyWith(color: colors.inkMuted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SprintSpacing.space3),
          ],
          SlotGrid(
            slots: grid,
            units: {for (final u in schedule.units) u.id: u},
            selection: selection,
            tier: session.isGuest ? null : session.tier,
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
    super.key,
  });

  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.all(SprintSpacing.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SprintIcon(
              PhosphorIconsRegular.calendarBlank,
              size: SprintSize.iconLg,
              color: colors.inkMuted,
            ),
            const SizedBox(height: SprintSpacing.space3),
            Text(
              title,
              style: context.text.headline,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SprintSpacing.space2),
            Text(
              body,
              style: context.text.body.copyWith(color: colors.inkMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SprintSpacing.space4),
            SprintButton(
              label: actionLabel,
              variant: SprintButtonVariant.secondary,
              onPressed: onAction,
            ),
          ],
        ),
      ),
    );
  }
}
