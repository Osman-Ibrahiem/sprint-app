import 'package:flutter/material.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_colors.g.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/tokens/sprint_text.g.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

// Token names are code identifiers, not user-facing copy, so they are shown as
// they are in tokens.json and are not translated.

typedef _Swatch = (String name, Color light, Color dark);

List<_Swatch> get _swatches {
  const l = SprintColors.light;
  const d = SprintColors.dark;
  return <_Swatch>[
    ('bg', l.bg, d.bg),
    ('surface', l.surface, d.surface),
    ('surface-raised', l.surfaceRaised, d.surfaceRaised),
    ('surface-sunken', l.surfaceSunken, d.surfaceSunken),
    ('line', l.line, d.line),
    ('control-border', l.controlBorder, d.controlBorder),
    ('ink', l.ink, d.ink),
    ('ink-muted', l.inkMuted, d.inkMuted),
    ('ink-disabled', l.inkDisabled, d.inkDisabled),
    ('primary', l.primary, d.primary),
    ('primary-hover', l.primaryHover, d.primaryHover),
    ('primary-pressed', l.primaryPressed, d.primaryPressed),
    ('on-primary', l.onPrimary, d.onPrimary),
    ('primary-soft', l.primarySoft, d.primarySoft),
    ('on-primary-soft', l.onPrimarySoft, d.onPrimarySoft),
    ('volt', l.volt, d.volt),
    ('on-volt', l.onVolt, d.onVolt),
    ('success', l.success, d.success),
    ('success-soft', l.successSoft, d.successSoft),
    ('warning', l.warning, d.warning),
    ('warning-soft', l.warningSoft, d.warningSoft),
    ('danger', l.danger, d.danger),
    ('danger-soft', l.dangerSoft, d.dangerSoft),
    ('on-danger', l.onDanger, d.onDanger),
    ('focus-ring', l.focusRing, d.focusRing),
    ('scrim', l.scrim, d.scrim),
    ('qr-ink', l.qrInk, d.qrInk),
    ('qr-ground', l.qrGround, d.qrGround),
  ];
}

const _spacing = <(String, double)>[
  ('space-1', SprintSpacing.space1),
  ('space-2', SprintSpacing.space2),
  ('space-3', SprintSpacing.space3),
  ('space-4', SprintSpacing.space4),
  ('space-5', SprintSpacing.space5),
  ('space-6', SprintSpacing.space6),
  ('space-8', SprintSpacing.space8),
  ('space-10', SprintSpacing.space10),
  ('space-12', SprintSpacing.space12),
  ('space-16', SprintSpacing.space16),
];

const _radii = <(String, double)>[
  ('radius-sm', SprintRadius.sm),
  ('radius-md', SprintRadius.md),
  ('radius-lg', SprintRadius.lg),
  ('radius-xl', SprintRadius.xl),
  ('radius-full', SprintRadius.full),
];

const _types = <(String, TextStyle)>[
  ('display', SprintText.display),
  ('title-lg', SprintText.titleLg),
  ('title', SprintText.title),
  ('headline', SprintText.headline),
  ('button', SprintText.button),
  ('number-lg', SprintText.numberLg),
  ('number', SprintText.number),
  ('body', SprintText.body),
  ('body-strong', SprintText.bodyStrong),
  ('label', SprintText.label),
  ('caption', SprintText.caption),
  ('micro', SprintText.micro),
  ('code', SprintText.code),
];

/// Colours in both themes side by side, type, spacing and radius, straight from
/// the generated tokens (FR-020).
class TokenGallery extends StatelessWidget {
  const TokenGallery({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    Widget heading(String text) => Padding(
          padding: const EdgeInsetsDirectional.only(
            top: SprintSpacing.space6,
            bottom: SprintSpacing.space3,
          ),
          child: Text(text, style: context.text.title),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading(l10n.demoColours),
        Wrap(
          spacing: SprintSpacing.space3,
          runSpacing: SprintSpacing.space3,
          children: [
            for (final (name, light, dark) in _swatches)
              _SwatchCard(name: name, light: light, dark: dark),
          ],
        ),
        heading(l10n.demoTypography),
        for (final (name, style) in _types)
          Padding(
            padding: const EdgeInsetsDirectional.only(
              bottom: SprintSpacing.space3,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: context.text.caption.copyWith(color: colors.inkMuted)),
                Text(
                  l10n.demoTypeSample,
                  style: style.copyWith(color: colors.ink),
                ),
              ],
            ),
          ),
        heading(l10n.demoSpacing),
        for (final (name, value) in _spacing)
          Padding(
            padding: const EdgeInsetsDirectional.only(
              bottom: SprintSpacing.space2,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: SprintSize.railWidth,
                  child: Text(name, style: context.text.caption),
                ),
                Container(
                  width: value,
                  height: SprintSpacing.space3,
                  color: colors.primary,
                ),
              ],
            ),
          ),
        heading(l10n.demoRadius),
        Wrap(
          spacing: SprintSpacing.space3,
          runSpacing: SprintSpacing.space3,
          children: [
            for (final (name, value) in _radii)
              Column(
                children: [
                  Container(
                    width: SprintSize.railWidth,
                    height: SprintSize.railWidth,
                    decoration: BoxDecoration(
                      color: colors.primarySoft,
                      border: Border.all(color: colors.controlBorder),
                      borderRadius: BorderRadius.circular(value),
                    ),
                  ),
                  const SizedBox(height: SprintSpacing.space1),
                  Text(name, style: context.text.caption),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class _SwatchCard extends StatelessWidget {
  const _SwatchCard({
    required this.name,
    required this.light,
    required this.dark,
  });

  final String name;
  final Color light;
  final Color dark;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Widget chip(Color c) => Expanded(
          child: Container(
            height: SprintSize.controlHeight,
            decoration: BoxDecoration(
              color: c,
              border: Border.all(color: colors.controlBorder),
              borderRadius: SprintRadius.smBorder,
            ),
          ),
        );
    return SizedBox(
      width: SprintSize.sidebarWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              chip(light),
              const SizedBox(width: SprintSpacing.space1),
              chip(dark),
            ],
          ),
          const SizedBox(height: SprintSpacing.space1),
          Text(name, style: context.text.caption),
        ],
      ),
    );
  }
}
