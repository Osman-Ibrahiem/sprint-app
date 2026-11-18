import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// "الدفع اتلغى": the booker backed out on the provider page (BR-47). Not a
/// failure: an information banner, the place is still held, and trying again
/// is offered below.
class CancelledNotice extends StatelessWidget {
  const CancelledNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return Container(
      padding: const EdgeInsetsDirectional.all(SprintSpacing.space3),
      decoration: BoxDecoration(
        color: colors.primarySoft,
        borderRadius: SprintRadius.mdBorder,
      ),
      child: Semantics(
        liveRegion: true,
        container: true,
        label: '${l10n.checkoutCancelledTitle}. ${l10n.checkoutCancelledBody}',
        child: ExcludeSemantics(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SprintIcon(
                PhosphorIconsRegular.hourglass,
                size: SprintSize.iconMd,
                color: colors.onPrimarySoft,
              ),
              const SizedBox(width: SprintSpacing.space2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.checkoutCancelledTitle,
                      style: context.text.bodyStrong.copyWith(
                        color: colors.onPrimarySoft,
                      ),
                    ),
                    Text(
                      l10n.checkoutCancelledBody,
                      style: context.text.body.copyWith(
                        color: colors.onPrimarySoft,
                      ),
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
