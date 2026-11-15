import 'package:flutter/material.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';

/// The shared frame every gallery section uses: title, an optional caption and
/// the variants laid out in a responsive wrap. Kept deliberately plain so the
/// widgets, not the frame, are what a reviewer looks at.
class GallerySection extends StatelessWidget {
  const GallerySection({
    required this.title,
    required this.children,
    this.caption,
    super.key,
  });

  final String title;
  final String? caption;
  final List<Widget> children;

  /// The heading's key, so tests can tell it apart from sample button labels.
  static ValueKey<String> titleKey(String title) =>
      ValueKey<String>('gallery-section-$title');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, key: titleKey(title), style: context.text.title),
        if (caption != null) ...[
          const SizedBox(height: SprintSpacing.space1),
          Text(
            caption!,
            style: context.text.caption
                .copyWith(color: context.colors.inkMuted),
          ),
        ],
        const SizedBox(height: SprintSpacing.space3),
        Wrap(
          spacing: SprintSpacing.space3,
          runSpacing: SprintSpacing.space3,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: children,
        ),
      ],
    );
  }
}

/// A labelled row inside a section ("available", "selected", …).
class GalleryRow extends StatelessWidget {
  const GalleryRow({
    required this.label,
    required this.child,
    super.key,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: context.text.caption.copyWith(color: context.colors.inkMuted),
        ),
        const SizedBox(height: SprintSpacing.space1),
        child,
      ],
    );
  }
}
