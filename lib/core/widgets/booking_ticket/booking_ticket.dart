import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/adaptive/adaptive_pressable.dart';
import 'package:sprint/core/l10n/ltr_isolate.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/motion/skeleton.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/reduced_motion.dart';
import 'package:sprint/core/tokens/sprint_colors.g.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_motion.g.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/booking_ticket/qr_painter.dart';
import 'package:sprint/core/widgets/status_badge/sprint_status.dart';
import 'package:sprint/core/widgets/status_badge/status_badge.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

enum BookingTicketState { upcoming, today, past }

/// The booking pass: status, facility, time band, QR and code
/// (BookingTicket README, FR-041 – FR-047, FR-064). Plain values only; the
/// caller applies the cancellation cut-off setting and passes [cancelUntil].
class BookingTicket extends StatefulWidget {
  const BookingTicket({
    required this.state,
    required this.status,
    required this.facilityName,
    required this.unitName,
    required this.start,
    required this.end,
    required this.code,
    required this.paid,
    this.trainerName,
    this.qrToken,
    this.cancelUntil,
    this.onCodeCopied,
    this.priceLabel,
    super.key,
  }) : isLoading = false;

  const BookingTicket.loading({super.key})
    : state = BookingTicketState.upcoming,
      status = SprintStatus.confirmed,
      facilityName = '',
      unitName = '',
      trainerName = null,
      start = null,
      end = null,
      qrToken = null,
      code = '',
      paid = '',
      cancelUntil = null,
      onCodeCopied = null,
      priceLabel = null,
      isLoading = true;

  final BookingTicketState state;
  final SprintStatus status;
  final String facilityName;
  final String unitName;
  final String? trainerName;
  final DateTime? start;
  final DateTime? end;
  final String? qrToken;
  final String code;

  /// Display string from `SprintFormat.price`.
  final String paid;

  /// Cairo-local; null means "الإلغاء مش متاح".
  final DateTime? cancelUntil;
  final VoidCallback? onCodeCopied;

  /// Replaces "المدفوع" for a booking that cost nothing ("السعر" with
  /// "مجاني" as [paid]).
  final String? priceLabel;
  final bool isLoading;

  static const bandKey = ValueKey<String>('ticket-band');
  static const qrKey = ValueKey<String>('ticket-qr');
  static const qrUnavailableKey = ValueKey<String>('ticket-qr-unavailable');
  static const dividerKey = ValueKey<String>('ticket-divider');
  static const codeKey = ValueKey<String>('ticket-code');
  static const copiedKey = ValueKey<String>('ticket-copied');
  static const loadingKey = ValueKey<String>('ticket-loading');
  static const cardKey = ValueKey<String>('ticket-card');

  @override
  State<BookingTicket> createState() => _BookingTicketState();
}

class _BookingTicketState extends State<BookingTicket> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    widget.onCodeCopied?.call();
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(SprintMotion.durationSlow * 4);
    if (mounted) setState(() => _copied = false);
  }

  bool get _showQr =>
      widget.state != BookingTicketState.past &&
      widget.status != SprintStatus.cancelled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final width = MediaQuery.sizeOf(context).width;
    final ticketWidth = SprintExtras.ticketWidth;

    final inner = widget.isLoading
        ? _loading(colors)
        : _content(context, colors);

    final card = SizedBox(
      width: width < ticketWidth ? null : ticketWidth,
      child: inner,
    );
    return Align(alignment: AlignmentDirectional.topCenter, child: card);
  }

  Widget _loading(SprintColors colors) => ExcludeSemantics(
    child: DecoratedBox(
      key: BookingTicket.loadingKey,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: SprintRadius.lgBorder,
        boxShadow: colors.shadowCard,
      ),
      child: const Padding(
        padding: EdgeInsetsDirectional.all(SprintSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Skeleton(
              height: SprintSpacing.space6,
              borderRadius: SprintRadius.smBorder,
            ),
            SizedBox(height: SprintSpacing.space3),
            Skeleton(
              height: SprintSpacing.space8,
              borderRadius: SprintRadius.smBorder,
            ),
            SizedBox(height: SprintSpacing.space3),
            Skeleton(
              height: SprintExtras.ticketWidth / 2,
              borderRadius: SprintRadius.smBorder,
            ),
            SizedBox(height: SprintSpacing.space3),
            Skeleton(
              height: SprintSpacing.space6,
              borderRadius: SprintRadius.smBorder,
            ),
          ],
        ),
      ),
    ),
  );

  Widget _content(BuildContext context, SprintColors colors) {
    final l10n = AppLocalizations.of(context);
    final format = SprintFormat(Localizations.localeOf(context).languageCode);
    final past = widget.state == BookingTicketState.past;
    final dateLine = format.dateTimeLine(widget.start!, widget.end!);
    final bandBg = past ? colors.surfaceSunken : colors.volt;
    final bandFg = past ? colors.inkMuted : colors.onVolt;
    final spokenCode = widget.code.split('').join(' ');
    final spoken = l10n.ticketSpoken(
      widget.facilityName,
      dateLine,
      widget.status.label(l10n),
      spokenCode,
    );
    final reduced = ReducedMotion.of(context);

    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatusBadge(status: widget.status),
              const SizedBox(height: SprintSpacing.space3),
              Text(widget.facilityName, style: context.text.title),
              Text(
                widget.unitName,
                style: context.text.body.copyWith(color: colors.inkMuted),
              ),
              if (widget.trainerName != null)
                Text(
                  widget.trainerName!,
                  style: context.text.body.copyWith(color: colors.inkMuted),
                ),
            ],
          ),
        ),
        Container(
          key: BookingTicket.bandKey,
          color: bandBg,
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: SprintSpacing.space4,
            vertical: SprintSpacing.space3,
          ),
          child: Row(
            children: [
              SprintIcon(
                PhosphorIconsRegular.clock,
                size: SprintSize.iconMd,
                color: bandFg,
              ),
              const SizedBox(width: SprintSpacing.space2),
              Expanded(
                child: Text(
                  dateLine,
                  style: context.text.headline.copyWith(color: bandFg),
                ),
              ),
            ],
          ),
        ),
        _Divider(
          key: BookingTicket.dividerKey,
          lineColor: colors.line,
          notch: colors.bg,
        ),
        Padding(
          padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _qrOrStatus(context, colors, l10n),
              const SizedBox(height: SprintSpacing.space3),
              _codeRow(context, colors, l10n),
              if (_showQr) ...[
                Text(
                  l10n.ticketShowTrainer,
                  style: context.text.caption.copyWith(color: colors.inkMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: SprintSpacing.space3),
              ] else
                const SizedBox(height: SprintSpacing.space3),
              _row(context, widget.priceLabel ?? l10n.ticketPaid, widget.paid),
              const SizedBox(height: SprintSpacing.space2),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  widget.cancelUntil == null
                      ? l10n.ticketCancelUnavailable
                      : l10n.ticketCancelUntil(
                          '${format.date(widget.cancelUntil!)} ${format.time(widget.cancelUntil!)}',
                        ),
                  style: context.text.caption.copyWith(color: colors.inkMuted),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final decorated = DecoratedBox(
      key: BookingTicket.cardKey,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: SprintRadius.lgBorder,
        boxShadow: colors.shadowCard,
      ),
      child: ClipRRect(borderRadius: SprintRadius.lgBorder, child: body),
    );

    return Semantics(
      container: true,
      label: spoken,
      child: _Reveal(reduced: reduced, child: decorated),
    );
  }

  Widget _row(BuildContext context, String label, String value) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: context.text.body.copyWith(color: context.colors.inkMuted),
        ),
      ),
      Text(value, style: context.text.bodyStrong),
    ],
  );

  Widget _qrOrStatus(
    BuildContext context,
    SprintColors colors,
    AppLocalizations l10n,
  ) {
    final token = widget.qrToken ?? '';
    if (!_showQr) {
      return Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          vertical: SprintSpacing.space4,
        ),
        child: ExcludeSemantics(child: StatusBadge(status: widget.status)),
      );
    }
    final side = SprintExtras.ticketWidth / 2 + SprintExtras.qrQuietMargin * 2;
    if (token.isEmpty || !SprintQrPainter.canEncode(token)) {
      return SizedBox(
        key: BookingTicket.qrUnavailableKey,
        height: side,
        child: Center(
          child: Text(
            l10n.ticketQrUnavailable,
            style: context.text.body.copyWith(color: colors.inkMuted),
          ),
        ),
      );
    }
    return Semantics(
      image: true,
      label: l10n.ticketQrLabel,
      child: SizedBox(
        key: BookingTicket.qrKey,
        width: side,
        height: side,
        child: CustomPaint(
          painter: SprintQrPainter(
            token: token,
            ink: colors.qrInk,
            ground: colors.qrGround,
            margin: SprintExtras.qrQuietMargin,
          ),
        ),
      ),
    );
  }

  Widget _codeRow(
    BuildContext context,
    SprintColors colors,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        Text(
          l10n.ticketCodeLabel,
          style: context.text.caption.copyWith(color: colors.inkMuted),
        ),
        AdaptivePressable(
          label: '${l10n.ticketCodeLabel} ${widget.code.split('').join(' ')}',
          onTap: _copy,
          borderRadius: SprintRadius.smBorder,
          hoverColor: colors.surfaceSunken,
          builder: (context, s) => Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: SprintSpacing.space3,
              vertical: SprintSpacing.space2,
            ),
            child: LtrIsolate(
              child: Text(
                widget.code,
                key: BookingTicket.codeKey,
                style: context.text.code,
              ),
            ),
          ),
        ),
        Semantics(
          liveRegion: true,
          label: _copied ? l10n.ticketCopied : '',
          child: ExcludeSemantics(
            child: SizedBox(
              height: SprintSpacing.space5,
              child: _copied
                  ? Text(
                      l10n.ticketCopied,
                      key: BookingTicket.copiedKey,
                      style: context.text.caption.copyWith(
                        color: colors.success,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

/// Fades and rises once at `duration-slow` (fade only under reduced motion).
class _Reveal extends StatelessWidget {
  const _Reveal({required this.reduced, required this.child});

  final bool reduced;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const from = 0.0;
    const to = 1.0;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: from, end: to),
      duration: ReducedMotion.fade(context, SprintMotion.durationSlow),
      curve: SprintMotion.easeEnter,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: reduced
            ? child
            : Transform.translate(
                offset: Offset(0, (1 - t) * SprintSpacing.space4),
                child: child,
              ),
      ),
      child: child,
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.lineColor, required this.notch, super.key});

  final Color lineColor;
  final Color notch;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: SprintExtras.ticketNotchRadius * 2,
    child: CustomPaint(
      painter: _NotchPainter(line: lineColor, notch: notch),
    ),
  );
}

class _NotchPainter extends CustomPainter {
  _NotchPainter({required this.line, required this.notch});

  final Color line;
  final Color notch;

  @override
  void paint(Canvas canvas, Size size) {
    const r = SprintExtras.ticketNotchRadius;
    final fill = Paint()..color = notch;
    canvas.drawCircle(Offset(0, size.height / 2), r, fill);
    canvas.drawCircle(Offset(size.width, size.height / 2), r, fill);
    final stroke = Paint()
      ..color = line
      ..strokeWidth = SprintExtras.hairlineWidth;
    const dash = SprintSpacing.space2;
    var x = r + SprintSpacing.space2;
    while (x < size.width - r - SprintSpacing.space2) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(x + dash, size.height / 2),
        stroke,
      );
      x += dash * 2;
    }
  }

  @override
  bool shouldRepaint(_NotchPainter old) =>
      old.line != line || old.notch != notch;
}
