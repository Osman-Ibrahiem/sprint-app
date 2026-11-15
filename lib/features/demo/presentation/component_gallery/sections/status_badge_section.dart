import 'package:flutter/material.dart';
import 'package:sprint/core/widgets/status_badge/sprint_status.dart';
import 'package:sprint/core/widgets/status_badge/status_badge.dart';
import 'package:sprint/features/demo/presentation/component_gallery/gallery_section.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// All twelve statuses.
class StatusBadgeSection extends StatelessWidget {
  const StatusBadgeSection({required this.l10n, super.key});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: l10n.galleryStatusBadgeSection,
      caption: l10n.gallerySampleNote,
      children: [
        for (final status in SprintStatus.values)
          GalleryRow(
            label: status.label(l10n),
            child: StatusBadge(status: status),
          ),
      ],
    );
  }
}
