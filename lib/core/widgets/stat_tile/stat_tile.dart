import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/adaptive/adaptive_pressable.dart';
import 'package:sprint/core/motion/skeleton.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/stat_tile/stat_delta.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';

export 'package:sprint/core/widgets/stat_tile/stat_delta.dart';

/// A single report figure with its period and an optional comparison
/// (StatTile README, FR-058 – FR-061, FR-064). No chart. Width is flexible.
class StatTile extends StatelessWidget {
  const StatTile({
    required this.label,
    required this.period,
    required this.value,
    this.unit,
    this.delta,
    this.onTap,
    super.key,
  }) : isLoading = false;

  const StatTile.loading({super.key})
      : label = '',
        period = '',
        value = '',
        unit = null,
        delta = null,
        onTap = null,
        isLoading = true;

  final String label;
  final String period;
  final String value;
  final String? unit;
  final StatDelta? delta;
  final VoidCallback? onTap;
  final bool isLoading;

  static const valueKey = ValueKey<String>('stat-tile-value');
  static const unitKey = ValueKey<String>('stat-tile-unit');
  static const deltaKey = ValueKey<String>('stat-tile-delta');
  static const loadingKey = ValueKey<String>('stat-tile-loading');

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    if (isLoading) {
      const bar = Skeleton(
        height: SprintSpacing.space4,
        borderRadius: SprintRadius.smBorder,
      );
      return ExcludeSemantics(
        child: DecoratedBox(
          key: loadingKey,
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
                bar,
                SizedBox(height: SprintSpacing.space3),
                Skeleton(
                  height: SprintSpacing.space8,
                  borderRadius: SprintRadius.smBorder,
                ),
                SizedBox(height: SprintSpacing.space3),
                bar,
              ],
            ),
          ),
        ),
      );
    }

    final deltaSentence = delta == null
        ? l10n.statNoComparison
        : switch (delta!.trend) {
            StatTrend.flat => l10n.statDeltaFlat,
            StatTrend.up =>
              '${l10n.statDeltaUp(delta!.text)} ${delta!.comparison}',
            StatTrend.down =>
              '${l10n.statDeltaDown(delta!.text)} ${delta!.comparison}',
          };
    final deltaColor = delta?.colorIn(colors) ?? colors.inkMuted;
    final deltaIcon = switch (delta?.trend) {
      StatTrend.up => PhosphorIconsRegular.arrowUp,
      StatTrend.down => PhosphorIconsRegular.arrowDown,
      _ => PhosphorIconsRegular.minus,
    };
    final unitText = unit == null ? '' : ' $unit';
    final spoken = '$label، $period، $value$unitText، $deltaSentence';

    final content = Padding(
      padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: context.text.caption.copyWith(color: colors.inkMuted),
          ),
          Text(
            period,
            style: context.text.caption.copyWith(color: colors.inkMuted),
          ),
          const SizedBox(height: SprintSpacing.space2),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: value, style: context.text.numberLg),
                if (unit != null)
                  TextSpan(
                    text: unitText,
                    style: context.text.label.copyWith(color: colors.inkMuted),
                  ),
              ],
            ),
            key: valueKey,
          ),
          const SizedBox(height: SprintSpacing.space2),
          Row(
            key: deltaKey,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SprintIcon(deltaIcon, size: SprintSize.iconSm, color: deltaColor),
              const SizedBox(width: SprintSpacing.space1),
              Expanded(
                child: Text(
                  deltaSentence,
                  style: context.text.caption.copyWith(color: deltaColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final decorated = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: SprintRadius.lgBorder,
        boxShadow: colors.shadowCard,
      ),
      child: content,
    );

    if (onTap == null) {
      return Semantics(
        container: true,
        label: spoken,
        child: ExcludeSemantics(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: SprintRadius.lgBorder,
              boxShadow: colors.shadowCard,
            ),
            child: content,
          ),
        ),
      );
    }
    return AdaptivePressable(
      label: spoken,
      onTap: onTap,
      borderRadius: SprintRadius.lgBorder,
      restingColor: colors.surface,
      hoverColor: colors.surfaceSunken,
      builder: (context, state) => ExcludeSemantics(child: decorated),
    );
  }
}
