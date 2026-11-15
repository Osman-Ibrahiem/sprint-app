import 'package:flutter/material.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/features/demo/presentation/component_gallery/gallery_section.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Every button variant and size, with the states a widget cannot enforce.
class ButtonSection extends StatelessWidget {
  const ButtonSection({required this.l10n, super.key});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: l10n.galleryButtonSection,
      caption: l10n.gallerySampleNote,
      children: [
        for (final variant in SprintButtonVariant.values)
          GalleryRow(
            label: variant.name,
            child: Wrap(
              spacing: SprintSpacing.space2,
              runSpacing: SprintSpacing.space2,
              children: [
                for (final size in SprintButtonSize.values)
                  SprintButton(
                    label: l10n.galleryButtonSection,
                    variant: variant,
                    size: size,
                    onPressed: () {},
                  ),
              ],
            ),
          ),
        GalleryRow(
          label: l10n.buttonBusy,
          child: Wrap(
            spacing: SprintSpacing.space2,
            runSpacing: SprintSpacing.space2,
            children: [
              for (final variant in SprintButtonVariant.values)
                SprintButton(
                  label: l10n.galleryButtonSection,
                  variant: variant,
                  loading: true,
                  loadingLabel: l10n.buttonBusy,
                  onPressed: () {},
                ),
            ],
          ),
        ),
        GalleryRow(
          label: l10n.buttonDisabledSuffix,
          child: Wrap(
            spacing: SprintSpacing.space2,
            runSpacing: SprintSpacing.space2,
            children: [
              for (final variant in SprintButtonVariant.values)
                SprintButton(
                  label: l10n.galleryButtonSection,
                  variant: variant,
                ),
            ],
          ),
        ),
        GalleryRow(
          label: l10n.galleryTextFieldSection,
          child: Wrap(
            spacing: SprintSpacing.space2,
            runSpacing: SprintSpacing.space2,
            children: [
              SprintButton(
                label: l10n.galleryButtonSection,
                icon: const SprintButtonIcon(Icons.add),
                onPressed: () {},
              ),
              SprintButton(
                label: l10n.galleryButtonSection,
                variant: SprintButtonVariant.secondary,
                icon: const SprintButtonIcon(
                  Icons.arrow_forward,
                  position: SprintButtonIconPosition.end,
                  mirrorInRtl: true,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}
