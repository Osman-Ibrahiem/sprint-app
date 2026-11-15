import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/adaptive/adaptive_pressable.dart';
import 'package:sprint/core/motion/skeleton.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_colors.g.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/facility_card/facility_card_data.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

export 'package:sprint/core/widgets/facility_card/facility_card_data.dart';

/// A facility in the catalogue: photo, name, owner, tags, availability and the
/// one price that applies. The whole card is one pressable target
/// (FacilityCard README, FR-035 – FR-040, FR-064).
class FacilityCard extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  FacilityCard({
    required this.kind,
    required this.name,
    required this.owningUnit,
    required this.unitCount,
    required this.tags,
    required this.availability,
    required this.price,
    required this.onTap,
    this.layout = FacilityCardLayout.vertical,
    this.availableCount,
    this.photo,
    this.heroTag,
    super.key,
  })  : assert(tags.length <= 3, 'A facility card shows at most three tags'),
        isLoading = false;

  const FacilityCard.loading({
    this.layout = FacilityCardLayout.vertical,
    super.key,
  })  : kind = FacilityKind.paid,
        name = '',
        owningUnit = '',
        unitCount = 0,
        tags = const [],
        availability = AvailabilityLevel.none,
        availableCount = null,
        price = const FacilityPrice(),
        photo = null,
        heroTag = null,
        onTap = null,
        isLoading = true;

  final FacilityKind kind;
  final FacilityCardLayout layout;
  final String name;
  final String owningUnit;
  final int unitCount;
  final List<FacilityTag> tags;
  final AvailabilityLevel availability;
  final int? availableCount;
  final FacilityPrice price;
  final ImageProvider? photo;
  final Object? heroTag;
  final VoidCallback? onTap;
  final bool isLoading;

  static const photoKey = ValueKey<String>('facility-card-photo');
  static const placeholderKey = ValueKey<String>('facility-card-placeholder');
  static const oldPriceKey = ValueKey<String>('facility-card-old-price');
  static const loadingKey = ValueKey<String>('facility-card-loading');

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final horizontal = layout == FacilityCardLayout.horizontal;

    if (isLoading) return _buildLoading(colors, horizontal);

    final availabilityWord = switch (availability) {
      AvailabilityLevel.plenty => l10n.facilityAvailabilityPlenty,
      AvailabilityLevel.few => l10n.facilityAvailabilityFew,
      AvailabilityLevel.none => l10n.facilityAvailabilityNone,
    };
    final priceWords = _priceSentence(l10n);
    final spoken = l10n.facilitySpoken(
      name,
      owningUnit,
      availabilityWord,
      priceWords,
    );

    final details = Padding(
      padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(name, style: context.text.headline),
          const SizedBox(height: SprintSpacing.space1),
          Text(
            '$owningUnit · ${l10n.facilityUnitCount(unitCount)}',
            style: context.text.caption.copyWith(color: colors.inkMuted),
          ),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: SprintSpacing.space2),
            Wrap(
              spacing: SprintSpacing.space1,
              runSpacing: SprintSpacing.space1,
              children: [for (final tag in tags) _TagPill(tag: tag)],
            ),
          ],
          const SizedBox(height: SprintSpacing.space2),
          _availabilityRow(context, availabilityWord),
          const SizedBox(height: SprintSpacing.space3),
          Divider(
            height: SprintExtras.hairlineWidth,
            thickness: SprintExtras.hairlineWidth,
            color: colors.line,
          ),
          const SizedBox(height: SprintSpacing.space3),
          _priceBlock(context, l10n),
        ],
      ),
    );

    final photoWidget = _photo(context, l10n, horizontal);

    return AdaptivePressable(
      label: spoken,
      onTap: onTap,
      borderRadius: SprintRadius.lgBorder,
      restingColor: colors.surface,
      hoverColor: colors.surfaceSunken,
      builder: (context, state) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: SprintRadius.lgBorder,
          boxShadow: colors.shadowCard,
        ),
        child: ClipRRect(
          borderRadius: SprintRadius.lgBorder,
          child: ExcludeSemantics(
            child: horizontal
                ? IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: SprintExtras.facilityPhotoWidth,
                          child: photoWidget,
                        ),
                        Expanded(child: details),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AspectRatio(
                        aspectRatio: SprintExtras.facilityPhotoAspect,
                        child: photoWidget,
                      ),
                      details,
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  String _priceSentence(AppLocalizations l10n) {
    if (kind == FacilityKind.free) return l10n.facilityFree;
    final parts = <String>[
      if (price.audienceLabel != null) price.audienceLabel!,
      if (price.amount != null) price.amount!,
      if (price.externalAmount != null)
        '${l10n.facilityPriceExternalLabel} ${price.externalAmount}',
    ];
    return parts.join('، ');
  }

  Widget _photo(BuildContext context, AppLocalizations l10n, bool horizontal) {
    final colors = context.colors;
    Widget content;
    if (photo == null) {
      content = Container(
        key: placeholderKey,
        color: colors.surfaceSunken,
        alignment: AlignmentDirectional.center,
        padding: const EdgeInsetsDirectional.all(SprintSpacing.space2),
        child: Text(
          l10n.facilityPhotoPlaceholder,
          textAlign: TextAlign.center,
          style: context.text.caption.copyWith(color: colors.inkMuted),
        ),
      );
    } else {
      content = Image(
        key: photoKey,
        image: photo!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) =>
            ColoredBox(color: colors.surfaceSunken),
      );
    }
    if (heroTag != null) content = Hero(tag: heroTag!, child: content);
    return content;
  }

  Widget _availabilityRow(BuildContext context, String word) {
    final colors = context.colors;
    final (color, icon) = switch (availability) {
      AvailabilityLevel.plenty => (colors.success, PhosphorIconsRegular.checkCircle),
      AvailabilityLevel.few => (colors.warning, PhosphorIconsRegular.clock),
      AvailabilityLevel.none => (colors.inkMuted, PhosphorIconsRegular.xCircle),
    };
    return Row(
      children: [
        Icon(icon, size: SprintSize.iconSm, color: color),
        const SizedBox(width: SprintSpacing.space1),
        Flexible(
          child: Text(word, style: context.text.caption.copyWith(color: color)),
        ),
      ],
    );
  }

  Widget _priceBlock(BuildContext context, AppLocalizations l10n) {
    final colors = context.colors;
    if (kind == FacilityKind.free) {
      return Text(
        l10n.facilityFree,
        style: context.text.number.copyWith(color: colors.success),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (price.offerLabel != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(
              bottom: SprintSpacing.space1,
            ),
            child: Text(
              price.offerLabel!,
              style: context.text.micro.copyWith(color: colors.inkMuted),
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            if (price.amount != null)
              Text(price.amount!, style: context.text.number),
            if (price.oldAmount != null) ...[
              const SizedBox(width: SprintSpacing.space2),
              Text(
                price.oldAmount!,
                key: oldPriceKey,
                style: context.text.caption.copyWith(
                  color: colors.inkMuted,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ],
        ),
        if (price.audienceLabel != null)
          Text(
            price.audienceLabel!,
            style: context.text.caption.copyWith(color: colors.inkMuted),
          ),
        if (price.externalAmount != null)
          Text(
            '${l10n.facilityPriceExternalLabel}: ${price.externalAmount}',
            style: context.text.caption.copyWith(color: colors.inkMuted),
          ),
      ],
    );
  }

  Widget _buildLoading(SprintColors colors, bool horizontal) {
    const line = Skeleton(
      height: SprintSpacing.space4,
      borderRadius: SprintRadius.smBorder,
    );
    final body = Padding(
      padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: const [
          line,
          SizedBox(height: SprintSpacing.space2),
          line,
          SizedBox(height: SprintSpacing.space2),
          line,
          SizedBox(height: SprintSpacing.space3),
          line,
        ],
      ),
    );
    return ExcludeSemantics(
      child: DecoratedBox(
        key: loadingKey,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: SprintRadius.lgBorder,
          boxShadow: colors.shadowCard,
        ),
        child: ClipRRect(
          borderRadius: SprintRadius.lgBorder,
          child: horizontal
              ? IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(
                        width: SprintExtras.facilityPhotoWidth,
                        child: Skeleton(borderRadius: BorderRadius.zero),
                      ),
                      Expanded(child: body),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AspectRatio(
                      aspectRatio: SprintExtras.facilityPhotoAspect,
                      child: const Skeleton(borderRadius: BorderRadius.zero),
                    ),
                    body,
                  ],
                ),
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.tag});

  final FacilityTag tag;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (fg, bg) = switch (tag.kind) {
      FacilityTagKind.trainer || FacilityTagKind.free => (
          colors.onPrimarySoft,
          colors.primarySoft,
        ),
      FacilityTagKind.offer => (colors.onVolt, colors.volt),
      FacilityTagKind.sport => (colors.inkMuted, colors.surfaceSunken),
    };
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: SprintSpacing.space2,
        vertical: SprintSpacing.space1,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: SprintRadius.fullBorder,
      ),
      child: Text(tag.label, style: context.text.micro.copyWith(color: fg)),
    );
  }
}
