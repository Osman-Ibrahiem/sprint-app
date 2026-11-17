import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/adaptive/adaptive_app_bar.dart';
import 'package:sprint/core/l10n/ltr_isolate.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';
import 'package:sprint/core/motion/skeleton.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/core/widgets/status_badge/sprint_status.dart';
import 'package:sprint/core/widgets/status_badge/status_badge.dart';
import 'package:sprint/features/booking/presentation/providers/booking_providers.dart';
import 'package:sprint/features/booking/presentation/widgets/booking_error_view.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The simple success screen of a free booking (FR-030, clarify): a
/// confirmation in words, the code, and the details. No QR and no ticket (that
/// is feature 6), and going back from it lands on the schedule, never on the
/// summary, so the booking cannot be confirmed twice.
class BookingDoneScreen extends ConsumerWidget {
  const BookingDoneScreen({
    required this.facilityId,
    required this.bookingId,
    super.key,
  });

  final String facilityId;
  final String bookingId;

  static const codeKey = ValueKey<String>('done-code');
  static const homeKey = ValueKey<String>('done-home');
  static const notFoundKey = ValueKey<String>('done-not-found');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(bookingDoneProvider(bookingId));

    final Widget body;
    if (async.hasError && !async.hasValue) {
      body = BookingErrorView(
        onRetry: () => ref.invalidate(bookingDoneProvider(bookingId)),
      );
    } else if (!async.hasValue) {
      body = ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
        children: const [
          Skeleton(height: SprintExtras.dayPillHeight * 3),
        ],
      );
    } else if (async.value == null) {
      body = _NotFound(key: notFoundKey);
    } else {
      body = _Done(view: async.value!);
    }

    return Column(
      children: [
        AdaptiveAppBar(title: l10n.bookingDoneTitle),
        Expanded(child: body),
      ],
    );
  }
}

class _Done extends StatelessWidget {
  const _Done({required this.view});

  final BookingDoneView view;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final format = SprintFormat.of(context);
    final b = view.booking;
    final rows = <(String, String)>[
      (l10n.bookingRowFacility, view.facilityName),
      (l10n.bookingRowUnit, view.unitName),
      (l10n.bookingRowDate, format.date(b.start)),
      (
        l10n.bookingRowTime,
        '${format.time(b.start)} – ${format.time(b.end)}',
      ),
    ];
    return ListView(
      padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
      children: [
        Column(
          children: [
            SprintIcon(
              PhosphorIconsRegular.checkCircle,
              size: SprintSize.iconLg,
              color: colors.success,
            ),
            const SizedBox(height: SprintSpacing.space2),
            Text(
              l10n.bookingDoneTitle,
              style: context.text.titleLg,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SprintSpacing.space2),
            const StatusBadge(status: SprintStatus.confirmed),
            const SizedBox(height: SprintSpacing.space2),
            Text(
              l10n.bookingDoneBody,
              style: context.text.body.copyWith(color: colors.inkMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        const SizedBox(height: SprintSpacing.space4),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: SprintRadius.lgBorder,
            border: Border.all(color: colors.line),
          ),
          padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                container: true,
                label: '${l10n.bookingDoneCode}: ${b.code}',
                child: ExcludeSemantics(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.bookingDoneCode,
                        style: context.text.label.copyWith(
                          color: colors.inkMuted,
                        ),
                      ),
                      LtrIsolate(
                        child: Text(
                          b.code,
                          key: BookingDoneScreen.codeKey,
                          style: context.text.code,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: SprintSpacing.space3),
              for (final (label, value) in rows)
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    bottom: SprintSpacing.space3,
                  ),
                  child: Semantics(
                    container: true,
                    label: '$label: $value',
                    child: ExcludeSemantics(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: context.text.label.copyWith(
                              color: colors.inkMuted,
                            ),
                          ),
                          Text(value, style: context.text.bodyStrong),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: SprintSpacing.space4),
        SprintButton(
          key: BookingDoneScreen.homeKey,
          label: l10n.bookingDoneHome,
          onPressed: () => context.go(AppPaths.home),
        ),
      ],
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.all(SprintSpacing.space6),
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
              l10n.bookingDoneNotFoundTitle,
              style: context.text.headline,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SprintSpacing.space2),
            Text(
              l10n.bookingDoneNotFoundBody,
              style: context.text.body.copyWith(color: colors.inkMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SprintSpacing.space4),
            SprintButton(
              label: l10n.bookingDoneHome,
              variant: SprintButtonVariant.secondary,
              onPressed: () => context.go(AppPaths.home),
            ),
          ],
        ),
      ),
    );
  }
}
