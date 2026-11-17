import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/features/auth/presentation/account_gate.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/booking_path.dart';
import 'package:sprint/features/booking/domain/own_overlap.dart';
import 'package:sprint/features/booking/domain/range_selection.dart';
import 'package:sprint/features/booking/domain/slot_selection.dart';
import 'package:sprint/features/booking/presentation/schedule/selection_bar.dart';
import 'package:sprint/features/booking/presentation/schedule/selection_panel.dart';
import 'package:sprint/core/window/window_size.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
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
import 'package:sprint/features/booking/domain/slot.dart';
import 'package:sprint/features/booking/domain/selection_resolver.dart';
import 'package:sprint/features/booking/presentation/providers/booking_providers.dart';
import 'package:sprint/features/booking/presentation/schedule/price_line.dart';
import 'package:sprint/features/booking/presentation/schedule/schedule_day_section.dart';
import 'package:sprint/features/booking/presentation/schedule/schedule_notice_view.dart';
import 'package:sprint/features/booking/presentation/schedule/slot_grid.dart';
import 'package:sprint/features/booking/presentation/schedule/trainer_step.dart';
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
    this.initialNotice,
    super.key,
  });

  final String facilityId;
  final ScheduleSelection selection;

  /// A notice carried by the route, for when another screen sends the person
  /// back here (the summary, after a refusal).
  final ScheduleNotice? initialNotice;

  /// What to show for a missing or unpublished facility. The app layer hands
  /// the catalogue's screen in, so features do not import each other's
  /// presentation code.
  final WidgetBuilder? notFound;

  static const refreshKey = ValueKey<String>('schedule-refresh');
  static const gridKey = ValueKey<String>('schedule-grid');
  static const emptyKey = ValueKey<String>('schedule-empty');
  static const nothingLeftKey = ValueKey<String>('schedule-nothing-left');
  static const loadingKey = ValueKey<String>('schedule-loading');
  static const trainerStepKey = ValueKey<String>('schedule-trainer-step');

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  late ScheduleNotice? _notice = widget.initialNotice;
  bool _replacing = false;
  bool _continuing = false;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _reload);
  }

  @override
  void didUpdateWidget(ScheduleScreen old) {
    super.didUpdateWidget(old);
    final n = widget.initialNotice;
    if (n != null && !identical(n, old.initialNotice)) _notice = n;
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
    // Kept loaded so the overlap hint at the tap needs no wait (FR-033).
    ref.watch(myUpcomingBookingsProvider);
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
        onTap: _tap,
        onContinue: _continue,
        continuing: _continuing,
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

  Future<OverlapInfo?> _overlapInfo(Booking b) async {
    final f = await ref.read(catalogueRepositoryProvider).getFacility(b.facilityId);
    return OverlapInfo(
      facilityName: f?.name ?? '',
      start: b.start,
      end: b.end,
    );
  }

  /// A tap on a slot: moves the selection, or says why it cannot (FR-014 –
  /// FR-016, FR-033). A signed-in booker is told at once when the time
  /// overlaps one of their own bookings; the slot is then not selected.
  Future<void> _tap(
    FacilitySchedule schedule,
    ScheduleSelection selection,
    ScheduleSlot slot,
  ) async {
    final ScheduleSelection next;
    if (schedule.path == BookingPath.range) {
      final unit = schedule.unit(slot.unitId);
      final result = RangeSelection.tap(
        selection,
        slot,
        schedule.gridFor(selection),
        unit?.maxRangeHours ?? 1,
      );
      switch (result) {
        case Err(:final failure):
          setState(() => _notice = ScheduleNotice.failure(failure));
          return;
        case Ok(:final value):
          next = value;
      }
    } else {
      next = SlotSelection.tap(selection, slot);
    }

    if (next.hasTime && ref.read(currentSessionProvider).user != null) {
      final mine = await ref.read(myUpcomingBookingsProvider.future);
      if (!mounted) return;
      final overlap = OwnOverlap.find(
        mine,
        next.startInstant!,
        next.endInstant!,
        ref.read(appClockProvider).now(),
      );
      if (overlap != null) {
        final info = await _overlapInfo(overlap);
        if (!mounted) return;
        setState(
          () => _notice = ScheduleNotice.failure(
            OverlapsOwnBooking(bookingId: overlap.id),
            overlap: info,
          ),
        );
        return;
      }
    }
    _clearNotice();
    _write(next);
  }

  /// The amount the schedule shows for this selection: the unit's price for
  /// the booker's tier, or 0 for a free facility.
  int? _shownAmount(FacilitySchedule schedule, ScheduleSelection selection) {
    if (schedule.facility.isFree) return 0;
    final tier = ref.read(currentSessionProvider).tier;
    return schedule.unit(selection.unitId)?.priceFor(tier);
  }

  /// "متابعة": a guest meets the account gate and comes back to the same
  /// selection (FR-021, FR-022); a signed-in booker's choice is checked and
  /// the summary opens (FR-024).
  Future<void> _continue(ScheduleSelection selection) async {
    final l10n = AppLocalizations.of(context);
    var session = ref.read(currentSessionProvider);

    if (session.isGuest) {
      final signedIn = await requireAccount(
        context,
        ref,
        l10n.bookingGateReason,
      );
      if (!mounted || !signedIn) return;
      await ref.read(sessionProvider.future);
      session = ref.read(currentSessionProvider);
      if (session.user == null) return;
      // Back on the same selection, ready to continue. Check it now, so a
      // slot taken meanwhile, or an overlap of the new account, is said.
      await _check(selection, session.user!.id, openSummary: false);
      return;
    }
    await _check(selection, session.user!.id, openSummary: true);
  }

  Future<void> _check(
    ScheduleSelection selection,
    String userId, {
    required bool openSummary,
  }) async {
    final request = selection.toRequest(userId);
    if (request == null) return;
    setState(() => _continuing = true);
    final result = await ref.read(bookingRepositoryProvider).quote(request);
    if (!mounted) return;
    setState(() => _continuing = false);
    switch (result) {
      case Err(:final failure):
        _reload();
        OverlapInfo? info;
        if (failure is OverlapsOwnBooking && failure.bookingId != null) {
          final b = await ref.read(bookingRepositoryProvider).get(failure.bookingId!);
          if (b is Ok<Booking>) info = await _overlapInfo(b.value);
        }
        if (!mounted) return;
        setState(() => _notice = ScheduleNotice.failure(failure, overlap: info));
        _write(selection.clearTime());
      case Ok():
        _clearNotice();
        if (!openSummary) return;
        final schedule = ref.read(_provider).value;
        final shown = schedule == null ? null : _shownAmount(schedule, selection);
        context.push(
          AppPaths.bookingSummary(widget.facilityId, selection, shown: shown),
        );
    }
  }

  /// Something the address carried is not valid any more: use the defaults,
  /// say so, and replace the address once (FR-010, FR-012).
  void _onChoiceDropped(ScheduleSelection resolved, ScheduleNotice notice) {
    if (_replacing) return;
    _replacing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _replacing = false;
      if (!mounted) return;
      setState(() => _notice ??= notice);
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
    required this.onTap,
    required this.onContinue,
    required this.continuing,
  });

  final FacilitySchedule schedule;
  final ScheduleSelection asked;
  final ScheduleNotice? notice;
  final VoidCallback onDismissNotice;
  final Future<void> Function() onRefresh;
  final ValueChanged<ScheduleSelection> onChange;
  final void Function(ScheduleSelection resolved, ScheduleNotice notice)
  onChoiceDropped;
  final VoidCallback onBack;
  final void Function(
    FacilitySchedule schedule,
    ScheduleSelection selection,
    ScheduleSlot slot,
  )
  onTap;
  final ValueChanged<ScheduleSelection> onContinue;
  final bool continuing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final session = ref.watch(currentSessionProvider);

    final resolved = SelectionResolver.resolve(asked, schedule);
    if (resolved.droppedChoice) {
      onChoiceDropped(resolved.selection, _whyDropped(schedule, asked));
    }
    final selection = resolved.selection;

    final isTrainerPath = schedule.path == BookingPath.trainer;

    // The trainer path starts with who gives the session (FR-017).
    if (schedule.needsTrainer) {
      if (schedule.trainers.isEmpty) {
        return _Empty(
          key: ScheduleScreen.emptyKey,
          title: l10n.bookingNoTrainersTitle,
          body: l10n.bookingNoTrainersBody,
          actionLabel: l10n.bookingBackToFacility,
          onAction: onBack,
        );
      }
      return ListView(
        key: ScheduleScreen.trainerStepKey,
        padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
        children: [
          if (notice != null) ...[
            ScheduleNoticeView(notice: notice!, onDismiss: onDismissNotice),
            const SizedBox(height: SprintSpacing.space3),
          ],
          TrainerList(
            trainers: schedule.trainers,
            onSelected: (t) => onChange(selection.withTrainer(t.id)),
          ),
        ],
      );
    }

    final chosenTrainer = isTrainerPath
        ? ChosenTrainerRow(
            trainer: schedule.trainer!,
            onChange: () => onChange(selection.withTrainer(null)),
          )
        : null;

    if (schedule.units.isEmpty || schedule.days.every((d) => d.isClosed)) {
      if (chosenTrainer != null) {
        return ListView(
          key: ScheduleScreen.emptyKey,
          padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
          children: [
            chosenTrainer,
            const SizedBox(height: SprintSpacing.space4),
            Text(
              l10n.bookingTrainerNoSessionsBody,
              style: context.text.body.copyWith(color: colors.inkMuted),
            ),
          ],
        );
      }
      return _Empty(
        key: ScheduleScreen.emptyKey,
        title: l10n.bookingNoUnitsTitle,
        body: l10n.bookingNoUnitsBody,
        actionLabel: l10n.bookingBackToFacility,
        onAction: onBack,
      );
    }

    final day = selection.day ?? schedule.defaultDay;
    final grid = schedule.gridFor(selection);
    final unit = schedule.unit(
      selection.unitId ?? (isTrainerPath && grid.isNotEmpty ? grid.first.unitId : null),
    );
    final anyBookable = grid.any((s) => s.isBookable);
    final anyDayHasRoom = schedule.days.any((d) => d.hasAvailability);

    final list = AdaptiveRefresh(
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
          if (chosenTrainer != null) ...[
            chosenTrainer,
            const SizedBox(height: SprintSpacing.space3),
          ],
          ScheduleDaySection(
            days: schedule.days,
            today: schedule.today,
            selected: day,
            onSelected: (d) => onChange(selection.withDay(d)),
          ),
          const SizedBox(height: SprintSpacing.space4),
          if (!isTrainerPath) ...[
            UnitPicker(
              units: schedule.units,
              selectedId: unit?.id,
              hasPlaces: (id) => schedule.unitHasPlacesOn(id, day),
              onSelected: (id) => onChange(selection.withUnit(id)),
            ),
            const SizedBox(height: SprintSpacing.space3),
          ],
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
          if (schedule.path == BookingPath.range && unit != null) ...[
            Text(
              l10n.bookingRangeHint(unit.maxRangeHours),
              style: context.text.body.copyWith(color: colors.inkMuted),
            ),
            const SizedBox(height: SprintSpacing.space3),
          ],
          SlotGrid(
            slots: grid,
            units: {for (final u in schedule.units) u.id: u},
            selection: selection,
            tier: session.isGuest ? null : session.tier,
            onTap: (slot) => onTap(schedule, selection, slot),
          ),
        ],
      ),
    );

    final String? priceText = schedule.facility.isFree
        ? l10n.bookingFree
        : session.isGuest
        ? null
        : unit?.priceFor(session.tier) == null
        ? null
        : SprintFormat.of(context).price(unit!.priceFor(session.tier)!);

    // Expanded and large windows keep the selection beside the grid; compact
    // and medium ones use the bottom bar (FR-042). The window decides, but a
    // pane too narrow for both (a hinge, a split) keeps the bar.
    final view = View.of(context);
    final windowWidth = view.physicalSize.width / view.devicePixelRatio;
    final paneWidth = MediaQuery.sizeOf(context).width;
    final sidePanel =
        WindowSize.fromWidth(windowWidth).isWide &&
        paneWidth >= SprintExtras.bookingPanelMinPaneWidth;

    if (sidePanel) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: list),
          SizedBox(
            width: SprintExtras.bookingPanelWidth,
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.only(
                top: SprintSpacing.space4,
                end: SprintSpacing.space4,
                bottom: SprintSpacing.space4,
              ),
              child: SelectionPanel(
                start: selection.hasTime ? selection.startInstant : null,
                end: selection.hasTime ? selection.endInstant : null,
                unitName: unit?.name,
                trainerName: schedule.trainer?.name,
                priceText: priceText,
                loading: continuing,
                onContinue: () => onContinue(selection),
              ),
            ),
          ),
        ],
      );
    }
    if (!selection.hasTime) return list;
    return Column(
      children: [
        Expanded(child: list),
        SelectionBar(
          start: selection.startInstant!,
          end: selection.endInstant!,
          priceText: priceText,
          loading: continuing,
          onContinue: () => onContinue(selection),
        ),
      ],
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

/// Why the chosen time is gone, when the schedule can tell: the first slot of
/// the choice that is now taken, full or past (FR-010). Otherwise only that
/// the earlier choice is no longer available. A single slot is named plainly;
/// only a range names the hour that broke it.
ScheduleNotice _whyDropped(FacilitySchedule schedule, ScheduleSelection asked) {
  const gone = ScheduleNotice.choiceNoLongerAvailable();
  final day = asked.day;
  final unitId = asked.unitId;
  if (!asked.hasTime || day == null || unitId == null) return gone;
  final unit = schedule.unit(unitId);
  final isRange = unit != null && asked.lengthMinutes! > unit.granularityMinutes;
  for (final slot in schedule.slotsFor(unitId, day)) {
    final start = cairoMinutesOf(slot.start);
    if (start < asked.startMinutes! || start >= asked.endMinutes!) continue;
    final at = isRange ? slot.start : null;
    switch (slot.state) {
      case SlotState.full:
        return ScheduleNotice.failure(
          unit != null && unit.isShared ? SlotFull(at: at) : SlotTaken(at: at),
        );
      case SlotState.past:
        return ScheduleNotice.failure(SlotPast(at: at));
      default:
        break;
    }
  }
  return gone;
}
