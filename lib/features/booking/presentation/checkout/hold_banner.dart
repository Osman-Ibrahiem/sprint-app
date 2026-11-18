import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/features/booking/domain/checkout_view.dart';
import 'package:sprint/features/booking/presentation/checkout/countdown_text.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Where the Hold banner sits: on the checkout screen or on the provider page.
enum HoldBannerKind { checkout, gateway }

/// The Hold in words and a clock icon: `warning-soft` normally and
/// `danger-soft` in the last minute (FR-003, FR-031). Never colour alone: the
/// icon and the words change too.
///
/// The visible time updates every second but is hidden from the screen
/// reader; a separate live region speaks only every 30 seconds and once on
/// entering the last minute.
class HoldBanner extends StatefulWidget {
  const HoldBanner({
    required this.remaining,
    this.kind = HoldBannerKind.checkout,
    super.key,
  });

  final Duration remaining;
  final HoldBannerKind kind;

  static const liveRegionKey = ValueKey<String>('hold-banner-live');
  static const titleKey = ValueKey<String>('hold-banner-title');
  static const bodyKey = ValueKey<String>('hold-banner-body');

  @override
  State<HoldBanner> createState() => _HoldBannerState();
}

class _HoldBannerState extends State<HoldBanner> {
  int? _boundary;
  String _spoken = '';

  bool get _last => widget.remaining < lastMinuteWindow;

  (String, String) _lines(AppLocalizations l10n) {
    final left = widget.remaining;
    if (_last) {
      return (
        l10n.checkoutLastMinuteTitle,
        l10n.checkoutLastMinuteBody(left.isNegative ? 0 : left.inSeconds),
      );
    }
    final time = countdownText(left);
    return widget.kind == HoldBannerKind.gateway
        ? (l10n.gatewayHoldTitle, l10n.gatewayHoldBody(time))
        : (l10n.checkoutHoldTitle, l10n.checkoutHoldRemaining(time));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final (title, body) = _lines(l10n);
    // Text and icon take the banner's own colour (`warning` on
    // `warning-soft`, `danger` on `danger-soft`), as the design has it.
    final ink = _last ? colors.danger : colors.warning;

    final boundary = announcementBoundary(
      widget.remaining,
      lastMinute: lastMinuteWindow,
    );
    if (boundary != _boundary) {
      _boundary = boundary;
      _spoken = '$title. $body';
    }

    return Container(
      padding: const EdgeInsetsDirectional.all(SprintSpacing.space3),
      decoration: BoxDecoration(
        color: _last ? colors.dangerSoft : colors.warningSoft,
        borderRadius: SprintRadius.mdBorder,
      ),
      // The banner itself is the live region: its words are hidden from the
      // reader and `_spoken` stands in for them, changing only every 30
      // seconds and once at the last minute.
      child: Semantics(
        key: HoldBanner.liveRegionKey,
        liveRegion: true,
        container: true,
        label: _spoken,
        child: ExcludeSemantics(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SprintIcon(
                PhosphorIconsRegular.hourglass,
                size: SprintSize.iconMd,
                color: _last ? colors.danger : colors.warning,
              ),
              const SizedBox(width: SprintSpacing.space2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      key: HoldBanner.titleKey,
                      style: context.text.bodyStrong.copyWith(color: ink),
                    ),
                    Text(
                      body,
                      key: HoldBanner.bodyKey,
                      style: context.text.body.copyWith(color: ink),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
