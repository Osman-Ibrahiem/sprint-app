import 'package:flutter/material.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_logo/sprint_logo.dart';
import 'package:sprint/features/demo/presentation/component_gallery/gallery_section.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The five logo variants on the four backgrounds the README names.
class LogoSection extends StatelessWidget {
  const LogoSection({required this.l10n, super.key});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final onInk = Theme.of(context).brightness == Brightness.dark
        ? colors.bg
        : colors.ink;
    return GallerySection(
      title: l10n.galleryLogoSection,
      caption: l10n.gallerySampleNote,
      children: [
        _box(colors.bg, colors.ink),
        _box(colors.surface, colors.ink),
        _box(colors.ink, colors.onPrimary),
        _box(onInk, colors.ink),
      ],
    );
  }

  Widget _box(Color background, Color foreground) {
    return DecoratedBox(
      decoration: BoxDecoration(color: background),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(SprintSpacing.space3),
        child: Wrap(
          spacing: SprintSpacing.space4,
          runSpacing: SprintSpacing.space4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final variant in LogoVariant.values)
              SprintLogo(
                variant: variant,
                size: 32,
                backgroundColor: background,
              ),
          ],
        ),
      ),
    );
  }
}
