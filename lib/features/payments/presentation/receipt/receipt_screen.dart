import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/adaptive/adaptive_app_bar.dart';
import 'package:sprint/core/adaptive/adaptive_back_button.dart';
import 'package:sprint/core/l10n/ltr_isolate.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/motion/skeleton.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/features/booking/presentation/providers/checkout_providers.dart';
import 'package:sprint/features/booking/presentation/widgets/empty_state.dart';
import 'package:sprint/features/payments/domain/receipt.dart';
import 'package:sprint/features/payments/presentation/receipt/receipt_document.dart';
import 'package:sprint/features/payments/presentation/receipt/receipt_providers.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The receipt of a paid booking (US-6, FR-PAY-03): its rows, the total, the
/// test-mode note, and two ways to keep it: an on-device PDF (saved or shared;
/// downloaded on the web) and a text share. When the PDF cannot be made the
/// text is shared instead and the booker is told. Not found unless a
/// `succeeded` payment exists.
class ReceiptScreen extends ConsumerStatefulWidget {
  const ReceiptScreen({required this.bookingId, super.key});

  final String bookingId;

  static const saveKey = ValueKey<String>('receipt-save');
  static const shareKey = ValueKey<String>('receipt-share');
  static const numberKey = ValueKey<String>('receipt-number');
  static const notFoundKey = ValueKey<String>('receipt-not-found');
  static const testTagKey = ValueKey<String>('receipt-test-tag');

  @override
  ConsumerState<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends ConsumerState<ReceiptScreen> {
  bool _saving = false;

  void _say(String text) {
    ScaffoldMessenger.maybeOf(context)
        ?.showSnackBar(SnackBar(content: Text(text)));
    SemanticsService.sendAnnouncement(
      View.of(context),
      text,
      Directionality.of(context),
    );
  }

  Future<void> _save(ReceiptDocument doc) async {
    if (_saving) return;
    setState(() => _saving = true);
    final l10n = AppLocalizations.of(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final sharer = ref.read(receiptSharerProvider);
    try {
      final bytes = await ref.read(receiptPdfBuilderProvider)(doc, rtl: rtl);
      await sharer.shareFile(bytes, name: '${doc.number}.pdf');
    } on Object {
      // The PDF could not be made or saved: the text goes out instead, and
      // the booker is told (FR-PAY-03).
      try {
        await sharer.shareText(doc.toText());
      } on Object {
        await sharer.copy(doc.toText());
      }
      if (mounted) _say(l10n.receiptPdfFailed);
    }
    if (mounted) setState(() => _saving = false);
  }

  Future<void> _share(ReceiptDocument doc) async {
    final l10n = AppLocalizations.of(context);
    final sharer = ref.read(receiptSharerProvider);
    try {
      await sharer.shareText(doc.toText());
    } on Object {
      // No share sheet here: copy it instead.
      await sharer.copy(doc.toText());
      if (mounted) _say(l10n.ticketCopied);
    }
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppPaths.bookingConfirmed(widget.bookingId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(receiptProvider(widget.bookingId));
    final Widget body;
    if (async.hasError && !async.hasValue) {
      body = _notFound(l10n);
    } else if (!async.hasValue) {
      body = ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
        children: const [Skeleton(height: SprintExtras.dayPillHeight * 3)],
      );
    } else if (async.value == null) {
      body = _notFound(l10n);
    } else {
      body = _Body(
        receipt: async.value!,
        saving: _saving,
        onSave: _save,
        onShare: _share,
      );
    }
    return Column(
      children: [
        AdaptiveAppBar(
          title: l10n.receiptNavTitle,
          leading: AdaptiveBackButton(onPressed: _back),
        ),
        Expanded(child: body),
      ],
    );
  }

  Widget _notFound(AppLocalizations l10n) => EmptyState(
    key: ReceiptScreen.notFoundKey,
    icon: PhosphorIconsRegular.ticket,
    title: l10n.receiptNotFoundTitle,
    body: l10n.receiptNotFoundBody,
    actionLabel: l10n.backToHome,
    onAction: () => context.go(AppPaths.home),
  );
}

class _Body extends StatelessWidget {
  const _Body({
    required this.receipt,
    required this.saving,
    required this.onSave,
    required this.onShare,
  });

  final Receipt receipt;
  final bool saving;
  final Future<void> Function(ReceiptDocument) onSave;
  final Future<void> Function(ReceiptDocument) onShare;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final doc = ReceiptDocument.of(l10n, SprintFormat.of(context), receipt);

    // Codes and numbers keep their order inside Arabic text.
    final isolated = {
      l10n.receiptNumber,
      l10n.receiptBookingCode,
      l10n.receiptMethod,
    };

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: SprintExtras.centredColumn),
        child: ListView(
          padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
          children: [
            Container(
              padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: SprintRadius.lgBorder,
                border: Border.all(color: colors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    header: true,
                    child: Text(doc.title, style: context.text.title),
                  ),
                  const SizedBox(height: SprintSpacing.space3),
                  for (final (label, value) in doc.rows)
                    _Row(
                      label: label,
                      value: value,
                      isolate: isolated.contains(label),
                      valueKey: label == l10n.receiptNumber
                          ? ReceiptScreen.numberKey
                          : null,
                    ),
                  Divider(
                    height: SprintSpacing.space4,
                    thickness: SprintExtras.hairlineWidth,
                    color: colors.line,
                  ),
                  _Row(label: doc.totalLabel, value: doc.total, strong: true),
                ],
              ),
            ),
            if (doc.isTest) ...[
              const SizedBox(height: SprintSpacing.space3),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Container(
                  key: ReceiptScreen.testTagKey,
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: SprintSpacing.space3,
                    vertical: SprintSpacing.space1,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primarySoft,
                    borderRadius: SprintRadius.fullBorder,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SprintIcon(
                        PhosphorIconsRegular.info,
                        size: SprintSize.iconSm,
                        color: colors.onPrimarySoft,
                      ),
                      const SizedBox(width: SprintSpacing.space1),
                      Flexible(
                        child: Text(
                          doc.testTag,
                          style: context.text.caption.copyWith(
                            color: colors.onPrimarySoft,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: SprintSpacing.space6),
            SprintButton(
              key: ReceiptScreen.saveKey,
              label: l10n.receiptSave,
              loading: saving,
              expand: true,
              onPressed: saving ? null : () => onSave(doc),
            ),
            const SizedBox(height: SprintSpacing.space2),
            SprintButton(
              key: ReceiptScreen.shareKey,
              label: l10n.receiptShare,
              variant: SprintButtonVariant.ghost,
              expand: true,
              onPressed: () => onShare(doc),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.strong = false,
    this.isolate = false,
    this.valueKey,
  });

  final String label;
  final String value;
  final bool strong;
  final bool isolate;
  final Key? valueKey;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = strong ? context.text.bodyStrong : context.text.body;
    final text = Text(
      value,
      key: valueKey,
      style: style,
      textAlign: TextAlign.end,
    );
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: SprintSpacing.space2),
      child: Semantics(
        container: true,
        label: '$label: $value',
        child: ExcludeSemantics(
          child: LayoutBuilder(
            builder: (context, box) {
              // The label keeps its own width up to under half the row, so the
              // value gets the rest instead of an even split.
              final labelMax = box.maxWidth * SprintExtras.rowLabelShare;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: labelMax),
                    child: Text(
                      label,
                      style: context.text.body.copyWith(color: colors.inkMuted),
                    ),
                  ),
                  const SizedBox(width: SprintSpacing.space3),
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: isolate ? LtrIsolate(child: text) : text,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
