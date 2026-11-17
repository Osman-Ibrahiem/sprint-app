import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/adaptive/adaptive_app_bar.dart';
import 'package:sprint/core/adaptive/adaptive_back_button.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';
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
import 'package:sprint/features/booking/domain/booking_summary_view.dart';
import 'package:sprint/features/booking/domain/schedule_notice.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';
import 'package:sprint/features/booking/presentation/providers/booking_providers.dart';
import 'package:sprint/features/booking/presentation/summary/summary_rows.dart';
import 'package:sprint/features/booking/presentation/widgets/booking_error_view.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The summary before anything is created or paid (FR-024 – FR-031). A paid
/// booking ends here with "متابعة للدفع", which checks again and opens the
/// checkout placeholder; nothing is stored and no place is held (BR-12 is
/// feature 6).
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

  BookingSummaryProvider get _provider => bookingSummaryProvider(
    widget.facilityId,
    widget.selection,
    widget.shown,
  );

  /// Back to the schedule with the time cleared and the refusal explained.
  void _backWithNotice(Failure failure) {
    final location = AppPaths.facilitySchedule(
      widget.facilityId,
      widget.selection.clearTime(),
    );
    context.go(location, extra: ScheduleNotice.failure(failure));
  }

  void _back() => context.canPop()
      ? context.pop()
      : context.go(
          AppPaths.facilitySchedule(widget.facilityId, widget.selection),
        );

  /// Quotes again right before leaving the summary (FR-009, FR-028): someone
  /// may have taken the place since it opened.
  Future<void> _continueToPayment() async {
    final user = ref.read(currentSessionProvider).user;
    final request = user == null ? null : widget.selection.toRequest(user.id);
    if (request == null) return;
    setState(() => _busy = true);
    final result = await ref.read(bookingRepositoryProvider).quote(request);
    if (!mounted) return;
    setState(() => _busy = false);
    switch (result) {
      case Err(:final failure):
        _backWithNotice(failure);
      case Ok():
        context.push(
          AppPaths.bookingCheckout(widget.facilityId, widget.selection),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(_provider);

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
        case Err(:final failure):
          // A refusal (the place was taken, a limit was reached): back to the
          // schedule, which says what happened.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _backWithNotice(failure);
          });
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
            label: l10n.bookingPayAction,
            busy: _busy,
            onPressed: _continueToPayment,
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
          _Banner(
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
                  style: context.text.body.copyWith(color: colors.onPrimarySoft),
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

class _Banner extends StatelessWidget {
  const _Banner({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      liveRegion: true,
      container: true,
      label: text,
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsetsDirectional.all(SprintSpacing.space3),
          decoration: BoxDecoration(
            color: colors.warningSoft,
            borderRadius: SprintRadius.mdBorder,
          ),
          child: Row(
            children: [
              SprintIcon(
                PhosphorIconsRegular.info,
                size: SprintSize.iconMd,
                color: colors.ink,
              ),
              const SizedBox(width: SprintSpacing.space2),
              Expanded(child: Text(text, style: context.text.body)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.label,
    required this.busy,
    required this.onPressed,
  });

  final String label;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.line, width: SprintExtras.hairlineWidth),
        ),
      ),
      padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: SprintButton(
            key: BookingSummaryScreen.actionKey,
            label: label,
            loading: busy,
            onPressed: busy ? null : onPressed,
          ),
        ),
      ),
    );
  }
}
