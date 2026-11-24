import 'package:flutter/material.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_text_field/sprint_text_field.dart';
import 'package:sprint/features/demo/presentation/component_gallery/gallery_section.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Every field type with default, error (not on search) and disabled
/// examples.
class TextFieldSection extends StatelessWidget {
  const TextFieldSection({required this.l10n, super.key});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: l10n.galleryTextFieldSection,
      caption: l10n.gallerySampleNote,
      children: [
        for (final type in SprintTextFieldType.values)
          SizedBox(
            width: SprintExtras.ticketWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SprintTextField(
                  label: l10n.galleryTextFieldSection,
                  placeholder: l10n.fieldSearchHint,
                  type: type,
                  helper: l10n.gallerySampleNote,
                ),
                // Search has no error state: "no results" shows where the
                // results would be (decision U2).
                if (type != SprintTextFieldType.search) ...[
                  const SizedBox(height: SprintSpacing.space2),
                  SprintTextField(
                    label: l10n.galleryTextFieldSection,
                    type: type,
                    error: l10n.fieldSearchHint,
                  ),
                ],
                const SizedBox(height: SprintSpacing.space2),
                SprintTextField(
                  label: l10n.galleryTextFieldSection,
                  type: type,
                  enabled: false,
                  placeholder: l10n.gallerySampleNote,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
