import 'package:flutter/material.dart';
import 'package:sprint/app/shell/placeholders/placeholder_page.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Facilities placeholder. The search field stands in for the catalogue search
/// (FR-CAT) and lets the shell prove it keeps typed text across a resize.
class FacilitiesPlaceholder extends StatefulWidget {
  const FacilitiesPlaceholder({super.key});

  @override
  State<FacilitiesPlaceholder> createState() => _FacilitiesPlaceholderState();
}

class _FacilitiesPlaceholderState extends State<FacilitiesPlaceholder> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return PlaceholderPage(
      title: l10n.facilitiesTitle,
      intro: l10n.facilitiesIntro,
      leading: [
        const SizedBox(height: SprintSpacing.space4),
        ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: SprintSize.controlHeight,
          ),
          child: TextField(
            controller: _controller,
            style: context.text.body,
            decoration: InputDecoration(
              hintText: l10n.facilitiesSearchHint,
              hintStyle: context.text.body.copyWith(color: colors.inkMuted),
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: colors.surfaceSunken,
              border: OutlineInputBorder(
                borderRadius: SprintRadius.smBorder,
                borderSide: BorderSide(color: colors.controlBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: SprintRadius.smBorder,
                borderSide: BorderSide(color: colors.controlBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: SprintRadius.smBorder,
                borderSide: BorderSide(
                  color: colors.focusRing,
                  width: SprintExtras.focusRingWidth,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
