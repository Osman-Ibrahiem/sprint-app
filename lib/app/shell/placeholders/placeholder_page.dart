import 'package:flutter/material.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/window/window_size.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Shared body of the shell placeholders: a scrollable page with a title, an
/// intro and decorative blocks standing in for the future content. Replaced
/// feature by feature; the skeleton primitive (T042) takes over the blocks.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({
    required this.title,
    this.intro,
    this.leading = const [],
    this.showNote = true,
    this.blocks = 8,
    super.key,
  });

  final String title;
  final String? intro;
  final List<Widget> leading;
  final bool showNote;
  final int blocks;

  static double margin(WindowSize size) => switch (size) {
        WindowSize.compact => SprintSpacing.space4,
        WindowSize.medium => SprintSpacing.space6,
        _ => SprintSpacing.space8,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final m = margin(WindowSize.of(context));

    return SafeArea(
      bottom: false,
      child: ListView(
        key: PageStorageKey<String>('placeholder-$title'),
        padding: EdgeInsetsDirectional.fromSTEB(
          m,
          SprintSpacing.space6,
          m,
          SprintSpacing.space6,
        ),
        children: [
          Text(title, style: context.text.titleLg),
          if (intro != null) ...[
            const SizedBox(height: SprintSpacing.space2),
            Text(intro!, style: context.text.body),
          ],
          ...leading,
          if (showNote) ...[
            const SizedBox(height: SprintSpacing.space4),
            Text(
              l10n.placeholderNote,
              style: context.text.caption.copyWith(color: colors.inkMuted),
            ),
          ],
          const SizedBox(height: SprintSpacing.space6),
          for (var i = 0; i < blocks; i++)
            Padding(
              padding: const EdgeInsetsDirectional.only(
                bottom: SprintSpacing.space4,
              ),
              child: ExcludeSemantics(
                child: Container(
                  height: SprintSize.controlHeight * 2,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: SprintRadius.lgBorder,
                    border: Border.all(color: colors.line),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
