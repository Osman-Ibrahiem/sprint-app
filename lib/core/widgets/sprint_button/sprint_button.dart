import 'package:flutter/material.dart';
import 'package:sprint/core/adaptive/adaptive_loader.dart';
import 'package:sprint/core/adaptive/adaptive_pressable.dart';
import 'package:sprint/core/l10n/directional_icon.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

enum SprintButtonVariant { primary, secondary, tonal, ghost, danger }

enum SprintButtonSize { md, sm }

enum SprintButtonIconPosition { start, end }

/// An optional icon and where it sits; directional icons mirror in RTL.
@immutable
class SprintButtonIcon {
  const SprintButtonIcon(
    this.icon, {
    this.position = SprintButtonIconPosition.start,
    this.mirrorInRtl = false,
  });

  final IconData icon;
  final SprintButtonIconPosition position;
  final bool mirrorInRtl;
}

/// The design system's action button (Button README, FR-013 – FR-017).
class SprintButton extends StatelessWidget {
  const SprintButton({
    required this.label,
    this.variant = SprintButtonVariant.primary,
    this.size = SprintButtonSize.md,
    this.icon,
    this.loading = false,
    this.loadingLabel,
    this.onPressed,
    this.expand = false,
    super.key,
  });

  /// A full-width action (a bottom bar, a form): fills the width it is given.
  final bool expand;

  final String label;
  final SprintButtonVariant variant;
  final SprintButtonSize size;
  final SprintButtonIcon? icon;
  final bool loading;
  final String? loadingLabel;
  final VoidCallback? onPressed;

  static const visualKey = ValueKey<String>('sprint-button-visual');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    final (
      variantBackground,
      variantForeground,
      variantBorder,
    ) = switch (variant) {
      SprintButtonVariant.primary => (colors.primary, colors.onPrimary, null),
      SprintButtonVariant.secondary => (
        colors.surface,
        colors.ink,
        Border.all(
          color: colors.controlBorder,
          width: SprintExtras.hairlineWidth,
        ),
      ),
      SprintButtonVariant.tonal => (
        colors.primarySoft,
        colors.onPrimarySoft,
        null,
      ),
      SprintButtonVariant.ghost => (null, colors.primary, null),
      SprintButtonVariant.danger => (colors.danger, colors.onDanger, null),
    };

    final busy = loading;
    final enabled = onPressed != null && !busy;
    // Disabled (no action, not loading): `surface-sunken` with `ink-disabled`
    // for every variant (Button README); the semantics still say why.
    final disabled = onPressed == null && !busy;
    final background = disabled ? colors.surfaceSunken : variantBackground;
    final foreground = disabled ? colors.inkDisabled : variantForeground;
    final border = disabled ? null : variantBorder;
    final spokenLabel = busy
        ? (loadingLabel ?? l10n.buttonBusy)
        : enabled
        ? label
        : '$label${l10n.buttonDisabledSuffix}';

    final showIcon = icon != null && !busy;
    final leading = busy
        ? AdaptiveLoader(
            semanticLabel: loadingLabel ?? l10n.buttonBusy,
            size: SprintSize.iconMd,
          )
        : showIcon && icon!.position == SprintButtonIconPosition.start
        ? DirectionalIcon(
            icon!.icon,
            mirror: icon!.mirrorInRtl,
            size: SprintSize.iconMd,
            color: foreground,
          )
        : null;
    final trailing = showIcon && icon!.position == SprintButtonIconPosition.end
        ? DirectionalIcon(
            icon!.icon,
            mirror: icon!.mirrorInRtl,
            size: SprintSize.iconMd,
            color: foreground,
          )
        : null;

    // Figma: `md` = radius-md and space-5 sides; `sm` = radius-sm and space-3
    // sides (decision 12, refactor 000).
    final md = size == SprintButtonSize.md;
    final radius = md ? SprintRadius.mdBorder : SprintRadius.smBorder;

    return AdaptivePressable(
      label: spokenLabel,
      onTap: enabled ? onPressed : null,
      restingColor: background,
      // Every variant changes on hover and press in its own colour family
      // (decision U1, refactor 000).
      pressedColor: switch (variant) {
        SprintButtonVariant.primary => colors.primaryPressed,
        SprintButtonVariant.secondary ||
        SprintButtonVariant.ghost => colors.surfaceSunken,
        SprintButtonVariant.tonal => colors.primarySoftPressed,
        SprintButtonVariant.danger => colors.dangerPressed,
      },
      hoverColor: switch (variant) {
        SprintButtonVariant.primary => colors.primaryHover,
        SprintButtonVariant.secondary ||
        SprintButtonVariant.ghost => colors.surfaceSunken,
        SprintButtonVariant.tonal => colors.primarySoftHover,
        SprintButtonVariant.danger => colors.dangerHover,
      },
      borderRadius: radius,
      expand: expand,
      builder: (context, state) => ConstrainedBox(
        key: visualKey,
        constraints: BoxConstraints(
          minHeight: md ? SprintSize.controlHeight : SprintSize.controlHeightSm,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(border: border, borderRadius: radius),
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: md ? SprintSpacing.space5 : SprintSpacing.space3,
              vertical: md ? SprintSpacing.space2 : SprintSpacing.space1,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leading != null) ...[
                  leading,
                  const SizedBox(width: SprintSpacing.space2),
                ],
                Flexible(
                  child: Text(
                    busy ? (loadingLabel ?? l10n.buttonBusy) : label,
                    style: context.text.button.copyWith(color: foreground),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: SprintSpacing.space2),
                  trailing,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
