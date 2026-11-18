import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The one payment method: online payment on the provider's secure page, with
/// a `primary-soft` test-mode tag when the provider is the fake or the
/// sandbox (FR-005, BR-29). The text wraps at any width and text scale.
class PaymentMethodCard extends StatelessWidget {
  const PaymentMethodCard({required this.showTestTag, super.key});

  final bool showTestTag;

  static const testTagKey = ValueKey<String>('payment-test-tag');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return Container(
      padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: SprintRadius.lgBorder,
        border: Border.all(color: colors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SprintIcon(
                PhosphorIconsRegular.creditCard,
                size: SprintSize.iconLg,
                color: colors.ink,
              ),
              const SizedBox(width: SprintSpacing.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.checkoutMethodTitle,
                      style: context.text.bodyStrong,
                    ),
                    Text(
                      l10n.checkoutMethodSubtitle,
                      style: context.text.body.copyWith(color: colors.inkMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showTestTag) ...[
            const SizedBox(height: SprintSpacing.space3),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Container(
                key: testTagKey,
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
                        l10n.checkoutSandboxTag,
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
        ],
      ),
    );
  }
}
