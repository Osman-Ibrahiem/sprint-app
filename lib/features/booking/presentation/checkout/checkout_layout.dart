import 'package:flutter/material.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/window/display_feature_layout.dart';
import 'package:sprint/core/window/window_size.dart';

/// The checkout screen's layout by window width (design-pack adaptive.md):
///
/// - compact: one column in the order banner, summary, method, with the action
///   in a fixed bar at the bottom;
/// - from 600: two columns, payment (title, banner, method, action at its end)
///   and booking summary (title, rows, policy), with no fixed bar. A hinge
///   moves each column to its own half.
///
/// The Hold's state lives in providers, so resizing or folding never restarts
/// the countdown.
class CheckoutLayout extends StatelessWidget {
  const CheckoutLayout({
    required this.title,
    required this.summaryTitle,
    required this.banner,
    required this.summary,
    required this.method,
    required this.action,
    this.lead,
    super.key,
  });

  /// The payment column's heading, shown inside the column from medium up
  /// (compact has the app bar).
  final String title;
  final String summaryTitle;

  /// A state header above the banner: the failure placeholder or the
  /// cancelled notice.
  final Widget? lead;
  final Widget banner;
  final Widget summary;
  final Widget method;

  /// The single primary action.
  final Widget action;

  static const barKey = ValueKey<String>('checkout-action-bar');
  static const paymentColumnKey = ValueKey<String>('checkout-payment-column');
  static const summaryColumnKey = ValueKey<String>('checkout-summary-column');

  @override
  Widget build(BuildContext context) =>
      WindowSize.of(context).isCompact ? _compact(context) : _wide(context);

  Widget _compact(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
            children: [
              if (lead != null) ...[lead!, const SizedBox(height: SprintSpacing.space4)],
              banner,
              const SizedBox(height: SprintSpacing.space4),
              summary,
              const SizedBox(height: SprintSpacing.space4),
              method,
            ],
          ),
        ),
        Container(
          key: barKey,
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(
              top: BorderSide(color: colors.line, width: SprintExtras.hairlineWidth),
            ),
          ),
          padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [action],
            ),
          ),
        ),
      ],
    );
  }

  Widget _wide(BuildContext context) {
    final payment = Column(
      key: paymentColumnKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Heading(title),
        const SizedBox(height: SprintSpacing.space3),
        if (lead != null) ...[lead!, const SizedBox(height: SprintSpacing.space4)],
        banner,
        const SizedBox(height: SprintSpacing.space4),
        method,
        const SizedBox(height: SprintSpacing.space4),
        action,
      ],
    );
    final summaryColumn = Column(
      key: summaryColumnKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Heading(summaryTitle),
        const SizedBox(height: SprintSpacing.space3),
        summary,
      ],
    );

    final hinge = MediaQuery.of(context).displayFeatures
        .any(DisplayFeatureLayout.separates);
    if (hinge) {
      return DisplayFeatureLayout(
        start: _scroll(payment),
        end: _scroll(summaryColumn),
      );
    }
    return LayoutBuilder(
      builder: (context, box) {
        const gap = SprintSpacing.space6;
        final room = box.maxWidth - SprintSpacing.space6 * 2 - gap;
        // The payment column keeps its width; below that the two share the
        // room in the same proportion, and the summary column takes the rest.
        final paymentWidth = room * SprintExtras.checkoutPaymentColumn /
            (SprintExtras.checkoutPaymentColumn +
                SprintExtras.checkoutSummaryColumnMin);
        final paymentW = paymentWidth < SprintExtras.checkoutPaymentColumn
            ? paymentWidth
            : SprintExtras.checkoutPaymentColumn;
        return _scroll(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: paymentW, child: payment),
              const SizedBox(width: gap),
              Expanded(child: summaryColumn),
            ],
          ),
        );
      },
    );
  }

  Widget _scroll(Widget child) => SingleChildScrollView(
    padding: const EdgeInsetsDirectional.all(SprintSpacing.space6),
    child: child,
  );
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) =>
      Semantics(header: true, child: Text(text, style: context.text.title));
}
