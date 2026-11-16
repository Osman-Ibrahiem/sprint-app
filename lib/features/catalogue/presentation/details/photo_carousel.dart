import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';

/// Swipeable photos with a position indicator; a labelled placeholder when
/// there are none; no controls for one photo (R6).
class PhotoCarousel extends StatefulWidget {
  const PhotoCarousel({required this.photos, this.name = '', super.key});

  final List<ImageProvider> photos;
  final String name;

  static const placeholderKey = ValueKey<String>('photo-placeholder');
  static const indicatorKey = ValueKey<String>('photo-indicator');

  @override
  State<PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<PhotoCarousel> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final count = widget.photos.length;

    final Widget body;
    if (count == 0) {
      body = Container(
        key: PhotoCarousel.placeholderKey,
        color: colors.surfaceSunken,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SprintIcon(
              PhosphorIconsRegular.image,
              size: SprintSize.iconLg,
              color: colors.inkMuted,
            ),
            const SizedBox(height: SprintSpacing.space2),
            Text(
              l10n.cataloguePhotoPlaceholder,
              style: context.text.caption.copyWith(color: colors.inkMuted),
            ),
          ],
        ),
      );
    } else {
      body = PageView.builder(
        itemCount: count,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (context, i) => Semantics(
          image: true,
          label: l10n.cataloguePhotoPosition(i + 1, count),
          child: Image(image: widget.photos[i], fit: BoxFit.cover),
        ),
      );
    }

    return ClipRRect(
      borderRadius: SprintRadius.lgBorder,
      child: AspectRatio(
        aspectRatio: SprintExtras.facilityPhotoAspect,
        child: Stack(
          fit: StackFit.expand,
          children: [
            body,
            if (count > 1)
              PositionedDirectional(
                bottom: SprintSpacing.space2,
                end: SprintSpacing.space2,
                child: Container(
                  key: PhotoCarousel.indicatorKey,
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: SprintSpacing.space2,
                    vertical: SprintSpacing.space1,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: SprintRadius.fullBorder,
                  ),
                  child: Text(
                    l10n.cataloguePhotoPosition(_index + 1, count),
                    style: context.text.caption,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
